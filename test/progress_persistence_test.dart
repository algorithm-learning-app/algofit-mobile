import 'package:algofit/services/daily_service.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('앱 재시작 후 XP·스트릭·하트가 유지된다', () async {
    SharedPreferences.setMockInitialValues({});

    final repo1 = await ProgressRepository.create();
    var session = repo1.startDailySession();
    for (var i = 0; i < dailyTotal; i++) {
      final recorded = repo1.recordDailyAnswer(session, true);
      session = recorded.session;
      if (i < dailyTotal - 1) {
        session = repo1.advanceAfterFeedback(session);
      }
    }
    repo1.completeDailyChallenge(session);
    await repo1.flushPersist();

    final savedXp = repo1.progress.xp;
    final savedStreak = repo1.progress.streakCount;
    final savedHearts = repo1.progress.hearts;

    expect(savedXp, greaterThan(0));
    expect(savedStreak, 1);
    expect(savedHearts, 5);

    final repo2 = await ProgressRepository.create();
    expect(repo2.progress.xp, savedXp);
    expect(repo2.progress.streakCount, savedStreak);
    expect(repo2.progress.hearts, savedHearts);
    expect(repo2.progress.todayDailyCompleted, isTrue);
  });
}
