import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/services/badge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('evaluateNewBadges unlocks first_daily on completion', () {
    final before = GuestProgress();
    final after = before.copyWith(todayDailyCompleted: true);
    expect(evaluateNewBadges(before, after), contains('first_daily'));
  });

  test('evaluateNewBadges unlocks streak_3 at 3 days', () {
    final before = GuestProgress(streakCount: 2);
    final after = before.copyWith(streakCount: 3);
    expect(evaluateNewBadges(before, after), contains('streak_3'));
  });

  test('applyUnlockedBadges merges ids', () {
    final p = GuestProgress();
    final next = applyUnlockedBadges(p, ['first_daily', 'first_daily']);
    expect(next.unlockedBadgeIds, ['first_daily']);
  });
}
