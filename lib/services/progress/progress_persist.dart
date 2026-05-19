import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/daily_session.dart';
import 'daily_session_store.dart';
import 'guest_progress_store.dart';

/// 게스트 진행도·Daily 세션 디스크 쓰기를 직렬화한다.
class ProgressPersistCoordinator {
  ProgressPersistCoordinator(
    SharedPreferences prefs, {
    GuestProgressStore? progressStore,
    DailySessionStore? sessionStore,
  })  : _progressStore = progressStore ?? GuestProgressStore(prefs),
        _sessionStore = sessionStore ?? DailySessionStore(prefs);

  final GuestProgressStore _progressStore;
  final DailySessionStore _sessionStore;
  Future<void> _chain = Future.value();

  GuestProgressStore get progressStore => _progressStore;
  DailySessionStore get sessionStore => _sessionStore;

  Future<void> flush() => _chain;

  void schedule({
    bool saveProgress = false,
    DailySession? dailySession,
    bool clearDailySession = false,
  }) {
    _chain = _chain.then((_) async {
      try {
        if (saveProgress) await _progressStore.persist();
        if (clearDailySession) {
          await _sessionStore.clear();
        } else if (dailySession != null) {
          await _sessionStore.persist(dailySession);
        }
      } catch (e, st) {
        developer.log(
          'Failed to persist algofit state',
          name: 'ProgressPersist',
          error: e,
          stackTrace: st,
        );
      }
    });
  }
}
