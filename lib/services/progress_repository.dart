import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/pc_handoff.dart';
import '../models/code_language.dart';
import '../models/daily_session.dart';
import '../models/guest_progress.dart';
import '../services/daily_service.dart';
import '../services/question_pool_cache.dart';
import 'progress/daily_session_store.dart';
import 'progress/guest_progress_store.dart';
import 'progress/progress_math.dart';
import 'progress/progress_persist.dart';
import 'progress/world_progress_service.dart';

export 'progress/guest_progress_store.dart' show getTodaySeoul;
export '../data/world_catalog.dart' show world2UnlockClearedCount;

class ProgressRepository extends ChangeNotifier {
  ProgressRepository._(
    this._persist, {
    WorldProgressService? worldProgress,
  }) : _worldProgress = worldProgress ?? const WorldProgressService();

  final ProgressPersistCoordinator _persist;
  final WorldProgressService _worldProgress;

  GuestProgressStore get _progressStore => _persist.progressStore;
  DailySessionStore get _sessionStore => _persist.sessionStore;

  GuestProgress get progress => _progressStore.value;
  DailySession? get dailySession => _sessionStore.value;

  static Future<ProgressRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final persist = ProgressPersistCoordinator(prefs);
    final repo = ProgressRepository._(persist);
    await repo._load();
    return repo;
  }

  Future<void> _load() async {
    await _progressStore.loadAndNormalize();
    _sessionStore.loadFromDisk();
    notifyListeners();
  }

  @visibleForTesting
  Future<void> flushPersist() => _persist.flush();

  DailySession startDailySession() {
    final session = DailySession.initial();
    _sessionStore.value = session;
    _persist.schedule(dailySession: session);
    notifyListeners();
    return session;
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
    );

    var nextProgress = addXp(_progressStore.value, xpGain);
    nextProgress = nextProgress.copyWith(
      dailyProgress: nextSession.answers.length,
    );
    if (questionId != null) {
      if (isCorrect) {
        nextProgress = withQuestionCleared(nextProgress, questionId);
      } else {
        final wrong = List<String>.from(nextProgress.wrongQuestionIds);
        if (!wrong.contains(questionId)) wrong.add(questionId);
        nextProgress = nextProgress.copyWith(wrongQuestionIds: wrong);
      }
    }

    final before = _progressStore.value;
    _progressStore.value = withBadges(before, nextProgress);
    _sessionStore.value = nextSession;
    _persist.schedule(saveProgress: true, dailySession: nextSession);
    notifyListeners();
    return (progress: _progressStore.value, session: nextSession);
  }

  DailySession advanceAfterFeedback(DailySession session) {
    final next = session.copyWith(
      questionIndex: session.questionIndex + 1,
      awaitingFeedback: false,
      clearLastAnswerCorrect: true,
    );
    _sessionStore.value = next;
    _persist.schedule(dailySession: next);
    notifyListeners();
    return next;
  }

  GuestProgress completeDailyChallenge(DailySession session) {
    final today = getTodaySeoul();
    final completed = session.answers.length == dailyTotal;
    final allCorrect = completed && session.answers.every((a) => a);

    var next = _progressStore.value.copyWith(
      todayDailyCompleted: true,
      todayAllCorrect: allCorrect,
      dailyProgress: dailyTotal,
      lastDailyDate: today,
    );

    final alreadyCountedToday =
        _progressStore.value.lastDailyDate == today &&
        _progressStore.value.todayDailyCompleted;

    if (completed && !alreadyCountedToday) {
      next = next.copyWith(streakCount: _progressStore.value.streakCount + 1);
      if (allCorrect) {
        next = addXp(next, dailyPerfectBonusXp);
      }
    }

    final before = _progressStore.value;
    _progressStore.value = withBadges(before, next);
    _sessionStore.value = null;
    _persist.schedule(saveProgress: true, clearDailySession: true);
    notifyListeners();
    return _progressStore.value;
  }

  int dailyResumeStep() {
    final session = _sessionStore.value;
    if (session == null) return 1;
    if (session.awaitingFeedback) {
      return session.questionIndex + 1;
    }
    return (session.questionIndex + 1).clamp(1, dailyTotal);
  }

  GuestProgress recordQuestionOutcome({
    required String questionId,
    required bool isCorrect,
    bool deductHeartOnWrong = false,
  }) {
    var cleared = List<String>.from(_progressStore.value.clearedQuestionIds);
    var wrong = List<String>.from(_progressStore.value.wrongQuestionIds);

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

    var next = _progressStore.value.copyWith(
      clearedQuestionIds: cleared,
      wrongQuestionIds: wrong,
    );
    if (!isCorrect && deductHeartOnWrong) {
      next = next.copyWith(hearts: (next.hearts - 1).clamp(0, 5));
    }

    final before = _progressStore.value;
    _progressStore.value = withBadges(before, next);
    _persist.schedule(saveProgress: true);
    notifyListeners();
    return _progressStore.value;
  }

  GuestProgress completeWorldStage({
    required int worldId,
    required int stageOrder,
    String? questionId,
  }) {
    final before = _progressStore.value;
    _progressStore.value = _worldProgress.completeStage(
      progress: before,
      worldId: worldId,
      stageOrder: stageOrder,
      questionId: questionId,
    );
    _persist.schedule(saveProgress: true);
    notifyListeners();
    return _progressStore.value;
  }

  @Deprecated('Use completeWorldStage(worldId: 1, ...)')
  GuestProgress completeWorld1Stage(int stageOrder) =>
      completeWorldStage(worldId: 1, stageOrder: stageOrder);

  String get effectiveCodeLanguage =>
      CodeLanguage.normalize(_progressStore.value.preferredCodeLanguage);

  Future<void> setPreferredCodeLanguage(String languageId) async {
    final normalized = CodeLanguage.normalize(languageId);
    _progressStore.value =
        _progressStore.value.copyWith(preferredCodeLanguage: normalized);
    QuestionPoolCache.instance.invalidateDailyPack();
    await _progressStore.persist();
    notifyListeners();
  }

  /// PC 웹 이어하기 URL (단기 handoff 토큰, guestId 직접 노출 없음).
  String createPcContinueUrl() {
    return pcContinueUrl(createHandoffToken(_progressStore.value.guestId));
  }
}
