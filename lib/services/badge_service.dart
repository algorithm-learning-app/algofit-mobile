import '../models/guest_progress.dart';

/// Evaluates MVP badge unlock rules against progress.
List<String> evaluateNewBadges(GuestProgress before, GuestProgress after) {
  final unlocked = Set<String>.from(after.unlockedBadgeIds);
  final newly = <String>[];

  void tryUnlock(String id, bool condition) {
    if (condition && !unlocked.contains(id)) {
      newly.add(id);
      unlocked.add(id);
    }
  }

  tryUnlock('first_daily', after.todayDailyCompleted && !before.todayDailyCompleted);
  tryUnlock('perfect_daily', after.todayAllCorrect && !before.todayAllCorrect);
  tryUnlock('streak_3', after.streakCount >= 3);
  tryUnlock('streak_7', after.streakCount >= 7);
  tryUnlock(
    'first_stage',
    after.world1ClearedCount + after.world2Nodes.where((n) => n == WorldNodeState.cleared).length >
        before.world1ClearedCount +
            before.world2Nodes.where((n) => n == WorldNodeState.cleared).length,
  );
  tryUnlock('world2_unlock', after.world2Unlocked && !before.world2Unlocked);
  tryUnlock('world1_clear', after.isWorld1Complete && !before.isWorld1Complete);
  tryUnlock('correct_10', after.clearedQuestionIds.length >= 10);

  return newly;
}

GuestProgress applyUnlockedBadges(GuestProgress progress, List<String> newIds) {
  if (newIds.isEmpty) return progress;
  final merged = List<String>.from(progress.unlockedBadgeIds);
  for (final id in newIds) {
    if (!merged.contains(id)) merged.add(id);
  }
  return progress.copyWith(unlockedBadgeIds: merged);
}
