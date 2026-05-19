import '../../models/guest_progress.dart';
import '../badge_service.dart';

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

GuestProgress withBadges(GuestProgress before, GuestProgress after) {
  final newIds = evaluateNewBadges(before, after);
  return applyUnlockedBadges(after, newIds);
}

GuestProgress withQuestionCleared(GuestProgress base, String? questionId) {
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
