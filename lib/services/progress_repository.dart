import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/daily_session.dart';
import '../models/guest_progress.dart';
import 'daily_service.dart';

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
  GuestProgress _progress = const GuestProgress();
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

    _progress = _resetDailyIfNewDay(_progress, today).copyWith(
      guestId: guestId,
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
    bool isCorrect,
  ) {
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

    _progress = nextProgress;
    _dailySession = nextSession;
    _saveProgress();
    _saveDailySession(nextSession);
    notifyListeners();
    return (progress: nextProgress, session: nextSession);
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

    _progress = next;
    _dailySession = null;
    _saveProgress();
    _saveDailySession(null);
    notifyListeners();
    return next;
  }

  int dailyResumeStep() {
    final session = _dailySession;
    if (session == null) return 1;
    if (session.awaitingFeedback) {
      return session.questionIndex + 1;
    }
    return (session.questionIndex + 1).clamp(1, dailyTotal);
  }
}
