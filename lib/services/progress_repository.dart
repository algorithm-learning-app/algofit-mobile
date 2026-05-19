import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/world1_stages.dart';
import '../data/world2_stages.dart';
import '../models/daily_session.dart';
import '../models/guest_progress.dart';
import '../models/world_stage.dart';
import 'badge_service.dart';
import 'daily_service.dart';
import 'stage_service.dart';

const world2UnlockClearedCount = 7;

const _progressKey = 'algofit:guestProgress';
const _guestIdKey = 'algofit:guestId';
const _dailySessionKey = 'algofit:dailySession';

String getTodaySeoul() {
  final now = DateTime.now().toUtc().add(const Duration(hours: 9));
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

class ProgressRepository extends ChangeNotifier {
  ProgressRepository(this._prefs);

  final SharedPreferences _prefs;
  GuestProgress _progress = GuestProgress();
  DailySession? _dailySession;

  GuestProgress get progress => _progress;
  DailySession? get dailySession => _dailySession;

  static Future<ProgressRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = ProgressRepository(prefs);
    await repo._load();
    return repo;
  }

  Future<void> _load() async {
    final guestId = _ensureGuestId();
    final today = getTodaySeoul();
    final raw = _prefs.getString(_progressKey);

    if (raw == null) {
      _progress = GuestProgress(guestId: guestId);
    } else {
      try {
        _progress = GuestProgress.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      } catch (_) {
        _progress = GuestProgress(guestId: guestId);
      }
    }

    _progress = _normalizeWorld2Nodes(
      _resetDailyIfNewDay(_progress, today).copyWith(
        guestId: guestId,
      ),
    );

    final sessionRaw = _prefs.getString(_dailySessionKey);
    if (sessionRaw != null) {
      try {
        _dailySession = DailySession.fromJson(
          jsonDecode(sessionRaw) as Map<String, dynamic>,
        );
      } catch (_) {
        _dailySession = null;
      }
    }

    await _saveProgress();
    notifyListeners();
  }

  String _ensureGuestId() {
    var id = _prefs.getString(_guestIdKey);
    if (id == null || id.isEmpty) {
      id = const Uuid().v4();
      _prefs.setString(_guestIdKey, id);
    }
    return id;
  }

  /// Pad or trim world2 node list when map stage count changes.
  GuestProgress _normalizeWorld2Nodes(GuestProgress p) {
    final target = world2MapStages.length;
    var nodes = List<WorldNodeState>.from(p.world2Nodes);
    if (nodes.length == target) return p;

    if (nodes.length > target) {
      return p.copyWith(world2Nodes: nodes.sublist(0, target));
    }

    final oldLen = nodes.length;
    final allOldCleared = oldLen > 0 &&
        nodes.every((n) => n == WorldNodeState.cleared);
    while (nodes.length < target) {
      nodes.add(WorldNodeState.locked);
    }
    if (allOldCleared && oldLen < target) {
      nodes[oldLen] = WorldNodeState.current;
    }
    return p.copyWith(world2Nodes: nodes);
  }

  /// Hearts MVP: max 5; wrong answers in Level/Algorithm cost 1; new local day refills to 5.
  GuestProgress _resetDailyIfNewDay(GuestProgress p, String today) {
    if (p.lastDailyDate == null || p.lastDailyDate == today) {
      return p;
    }
    return p.copyWith(
      todayDailyCompleted: false,
      todayAllCorrect: false,
      dailyProgress: 0,
      hearts: 5,
    );
  }

  GuestProgress _withBadges(GuestProgress before, GuestProgress after) {
    final newIds = evaluateNewBadges(before, after);
    return applyUnlockedBadges(after, newIds);
  }

  Future<void> _saveProgress() async {
    await _prefs.setString(_progressKey, jsonEncode(_progress.toJson()));
  }

  Future<void> _saveDailySession(DailySession? session) async {
    if (session == null) {
      await _prefs.remove(_dailySessionKey);
      _dailySession = null;
      return;
    }
    await _prefs.setString(_dailySessionKey, jsonEncode(session.toJson()));
    _dailySession = session;
  }

  DailySession startDailySession() {
    final session = DailySession.initial();
    _dailySession = session;
    _saveDailySession(session);
    notifyListeners();
    return session;
  }

  GuestProgress addXp(GuestProgress p, int amount) {
    var xp = p.xp + amount;
    var level = p.level;
    var xpToNext = p.xpToNextLevel;

    while (xp >= xpToNext) {
      xp -= xpToNext;
      level += 1;
      xpToNext = (xpToNext * 1.25).round();
    }

    return p.copyWith(xp: xp, level: level, xpToNextLevel: xpToNext);
  }

  ({GuestProgress progress, DailySession session}) recordDailyAnswer(
    DailySession session,
    bool isCorrect, {
    String? questionId,
  }) {
    const xpGain = dailyXpPerQuestion;
    final nextSession = session.copyWith(
      answers: [...session.answers, isCorrect],
      xpEarned: session.xpEarned + xpGain,
      awaitingFeedback: true,
      lastAnswerCorrect: isCorrect,
      hearts: isCorrect ? session.hearts : (session.hearts - 1).clamp(0, 5),
    );

    var nextProgress = addXp(_progress, xpGain);
    nextProgress = nextProgress.copyWith(
      dailyProgress: nextSession.answers.length,
      hearts: nextSession.hearts,
    );
    if (questionId != null) {
      if (isCorrect) {
        nextProgress = _withQuestionCleared(nextProgress, questionId);
      } else {
        final wrong = List<String>.from(nextProgress.wrongQuestionIds);
        if (!wrong.contains(questionId)) wrong.add(questionId);
        nextProgress = nextProgress.copyWith(wrongQuestionIds: wrong);
      }
    }

    final before = _progress;
    _progress = _withBadges(before, nextProgress);
    _dailySession = nextSession;
    _saveProgress();
    _saveDailySession(nextSession);
    notifyListeners();
    return (progress: _progress, session: nextSession);
  }

  DailySession advanceAfterFeedback(DailySession session) {
    final next = session.copyWith(
      questionIndex: session.questionIndex + 1,
      awaitingFeedback: false,
      clearLastAnswerCorrect: true,
    );
    _dailySession = next;
    _saveDailySession(next);
    notifyListeners();
    return next;
  }

  GuestProgress completeDailyChallenge(DailySession session) {
    final today = getTodaySeoul();
    final allCorrect = session.answers.length == dailyTotal &&
        session.answers.every((a) => a);

    var next = _progress.copyWith(
      todayDailyCompleted: true,
      todayAllCorrect: allCorrect,
      dailyProgress: dailyTotal,
      lastDailyDate: today,
    );

    final alreadyStreakedToday =
        _progress.lastDailyDate == today && _progress.todayAllCorrect;

    if (allCorrect && !alreadyStreakedToday) {
      next = next.copyWith(streakCount: _progress.streakCount + 1);
    }

    final before = _progress;
    _progress = _withBadges(before, next);
    _dailySession = null;
    _saveProgress();
    _saveDailySession(null);
    notifyListeners();
    return _progress;
  }

  int dailyResumeStep() {
    final session = _dailySession;
    if (session == null) return 1;
    if (session.awaitingFeedback) {
      return session.questionIndex + 1;
    }
    return (session.questionIndex + 1).clamp(1, dailyTotal);
  }

  GuestProgress _withQuestionCleared(GuestProgress base, String? questionId) {
    if (questionId == null) return base;
    final cleared = List<String>.from(base.clearedQuestionIds);
    if (!cleared.contains(questionId)) {
      cleared.add(questionId);
    }
    final wrong = List<String>.from(base.wrongQuestionIds)..remove(questionId);
    return base.copyWith(
      clearedQuestionIds: cleared,
      wrongQuestionIds: wrong,
    );
  }

  GuestProgress recordQuestionOutcome({
    required String questionId,
    required bool isCorrect,
  }) {
    var cleared = List<String>.from(_progress.clearedQuestionIds);
    var wrong = List<String>.from(_progress.wrongQuestionIds);

    if (isCorrect) {
      if (!cleared.contains(questionId)) {
        cleared.add(questionId);
      }
      wrong.remove(questionId);
    } else {
      if (!wrong.contains(questionId)) {
        wrong.add(questionId);
      }
    }

    final before = _progress;
    final next = _progress.copyWith(
      clearedQuestionIds: cleared,
      wrongQuestionIds: wrong,
    );
    _progress = _withBadges(before, next);
    _saveProgress();
    notifyListeners();
    return _progress;
  }

  GuestProgress completeWorldStage({
    required int worldId,
    required int stageOrder,
    String? questionId,
  }) {
    if (worldId == 1) {
      return _completeWorld1Stage(stageOrder, questionId);
    }
    if (worldId == 2) {
      return _completeWorld2Stage(stageOrder, questionId);
    }
    return _progress;
  }

  GuestProgress _completeWorld1Stage(int stageOrder, String? questionId) {
    var nodes = List<WorldNodeState>.from(_progress.world1Nodes);
    while (nodes.length < world1MapStages.length) {
      nodes.add(WorldNodeState.locked);
    }

    final idx = stageOrder - 1;
    final alreadyCleared =
        idx >= 0 && idx < nodes.length && nodes[idx] == WorldNodeState.cleared;

    final updatedNodes = alreadyCleared
        ? nodes
        : advanceWorldNodesAfterClear(
            nodes: nodes,
            clearedStageOrder: stageOrder,
            mapStageCount: world1MapStages.length,
          );

    var next = alreadyCleared
        ? _progress
        : addXp(_progress, stageXpPerQuestion);
    next = next.copyWith(world1Nodes: updatedNodes);
    next = _withQuestionCleared(next, questionId);

    final clearedCount =
        updatedNodes.where((n) => n == WorldNodeState.cleared).length;
    if (clearedCount >= world2UnlockClearedCount && !next.world2Unlocked) {
      next = next.copyWith(
        world2Unlocked: true,
        world2Nodes: defaultWorld2Nodes(unlocked: true),
      );
    }

    final before = _progress;
    _progress = _withBadges(before, next);
    _saveProgress();
    notifyListeners();
    return _progress;
  }

  GuestProgress _completeWorld2Stage(int stageOrder, String? questionId) {
    if (!_progress.world2Unlocked) return _progress;

    var nodes = List<WorldNodeState>.from(_progress.world2Nodes);
    while (nodes.length < world2MapStages.length) {
      nodes.add(WorldNodeState.locked);
    }

    final idx = stageOrder - 1;
    final alreadyCleared =
        idx >= 0 && idx < nodes.length && nodes[idx] == WorldNodeState.cleared;

    final updatedNodes = alreadyCleared
        ? nodes
        : advanceWorldNodesAfterClear(
            nodes: nodes,
            clearedStageOrder: stageOrder,
            mapStageCount: world2MapStages.length,
          );

    var next = alreadyCleared
        ? _progress
        : addXp(_progress, stageXpPerQuestion);
    next = next.copyWith(world2Nodes: updatedNodes);
    next = _withQuestionCleared(next, questionId);
    final before = _progress;
    _progress = _withBadges(before, next);
    _saveProgress();
    notifyListeners();
    return _progress;
  }

  @Deprecated('Use completeWorldStage(worldId: 1, ...)')
  GuestProgress completeWorld1Stage(int stageOrder) =>
      completeWorldStage(worldId: 1, stageOrder: stageOrder);
}
