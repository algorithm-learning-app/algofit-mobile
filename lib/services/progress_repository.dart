import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/pc_handoff.dart';
import '../models/code_language.dart';
import '../models/daily_session.dart';
import '../models/guest_progress.dart';
import '../services/daily_service.dart';
import '../services/question_pool_cache.dart';
import '../services/scenario_service.dart' show scenarioXpPerQuestion;
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

  /// 실전 시나리오 1문항 결과: 정답 시 XP만 지급한다.
  /// 시나리오는 별도 연습 모드라 전역 clearedQuestionIds/wrongQuestionIds(복습 풀·correct_10 뱃지)에는
  /// 섞지 않는다 — 복습 화면은 pick/blank만 렌더하므로 시나리오 id 유입 시 풀이가 불가하다.
  GuestProgress recordScenarioAnswer({required bool isCorrect}) {
    if (!isCorrect) return _progressStore.value;
    final before = _progressStore.value;
    _progressStore.value = withBadges(before, addXp(before, scenarioXpPerQuestion));
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

  Future<void> setDailyReminder({
    required bool enabled,
    int? hour,
    int? minute,
  }) async {
    _progressStore.value = _progressStore.value.copyWith(
      dailyReminderEnabled: enabled,
      reminderHour: hour,
      reminderMinute: minute,
    );
    await _progressStore.persist();
    notifyListeners();
  }

  /// 서버에서 받은 진행 JSON 으로 로컬 진행을 교체한다(동기화 채택용).
  /// 파싱 실패 시 아무것도 바꾸지 않는다.
  Future<void> adoptSyncedProgress(Map<String, dynamic> data) async {
    // 이종(異種) blob 거부: GuestProgress.fromJson 은 관대해서(누락 키를 기본값으로 채움)
    // 같은 guestId 로 푸시된 웹 클라이언트의 schema-v5 blob(또는 잘못된 형태)을 그대로
    // 채택해 모바일 전용 필드를 덮어쓸 수 있다. 모바일 스키마(>=6)만 허용한다(웹은 5).
    final schemaVersion = data['schemaVersion'];
    if (schemaVersion is! int || schemaVersion < 6) {
      debugPrint(
        'adoptSyncedProgress skipped: foreign/legacy blob '
        '(schemaVersion=$schemaVersion, mobile requires int>=6)',
      );
      return;
    }

    final GuestProgress next;
    try {
      next = GuestProgress.fromJson(data);
    } catch (_) {
      return;
    }
    // guestId 는 이 기기 값을 유지한다(서버 조회 키와 동일하므로 보통 같음).
    // 정규화 경로(daily 리셋 + world2 노드 보정)를 거쳐 교체한다.
    await _progressStore.replaceAndNormalize(
      next.copyWith(guestId: _progressStore.value.guestId),
    );
    notifyListeners();
  }

  /// PC 웹 이어하기 URL (단기 handoff 토큰, guestId 직접 노출 없음).
  String createPcContinueUrl() {
    return pcContinueUrl(createHandoffToken(_progressStore.value.guestId));
  }
}
