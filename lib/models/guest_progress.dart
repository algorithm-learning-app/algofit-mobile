enum WorldNodeState { locked, current, cleared }

class GuestProgress {
  const GuestProgress({
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.streakCount = 0,
    this.dailyProgress = 0,
    this.dailyTotal = 5,
    this.dailyPickCount = 3,
    this.dailyBlankCount = 2,
    this.todayDailyCompleted = false,
    this.world1Nodes = const [
      WorldNodeState.cleared,
      WorldNodeState.current,
      WorldNodeState.locked,
      WorldNodeState.locked,
      WorldNodeState.locked,
    ],
  });

  final int level;
  final int xp;
  final int xpToNextLevel;
  final int streakCount;
  final int dailyProgress;
  final int dailyTotal;
  final int dailyPickCount;
  final int dailyBlankCount;
  final bool todayDailyCompleted;
  final List<WorldNodeState> world1Nodes;

  double get xpPercent =>
      xpToNextLevel > 0 ? (xp / xpToNextLevel).clamp(0.0, 1.0) : 0.0;

  String get dailyCtaLabel {
    if (todayDailyCompleted) return '결과 보기';
    if (dailyProgress > 0) return '이어하기';
    return '시작하기';
  }
}
