enum WorldNodeState { locked, current, cleared }

class GuestProgress {
  const GuestProgress({
    this.schemaVersion = 2,
    this.guestId = '',
    this.level = 1,
    this.xp = 0,
    this.xpToNextLevel = 100,
    this.streakCount = 0,
    this.lastDailyDate,
    this.todayDailyCompleted = false,
    this.todayAllCorrect = false,
    this.dailyProgress = 0,
    this.dailyTotal = 5,
    this.dailyPickCount = 3,
    this.dailyBlankCount = 2,
    this.hearts = 5,
    this.world1Nodes = const [
      WorldNodeState.cleared,
      WorldNodeState.cleared,
      WorldNodeState.current,
      WorldNodeState.locked,
      WorldNodeState.locked,
      WorldNodeState.locked,
      WorldNodeState.locked,
    ],
  });

  final int schemaVersion;
  final String guestId;
  final int level;
  final int xp;
  final int xpToNextLevel;
  final int streakCount;
  final String? lastDailyDate;
  final bool todayDailyCompleted;
  final bool todayAllCorrect;
  final int dailyProgress;
  final int dailyTotal;
  final int dailyPickCount;
  final int dailyBlankCount;
  final int hearts;
  final List<WorldNodeState> world1Nodes;

  double get xpPercent =>
      xpToNextLevel > 0 ? (xp / xpToNextLevel).clamp(0.0, 1.0) : 0.0;

  String get dailyCtaLabel {
    if (todayDailyCompleted) return '결과 보기';
    if (dailyProgress > 0) return '이어하기';
    return '시작하기';
  }

  GuestProgress copyWith({
    String? guestId,
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? streakCount,
    String? lastDailyDate,
    bool? todayDailyCompleted,
    bool? todayAllCorrect,
    int? dailyProgress,
    int? hearts,
    List<WorldNodeState>? world1Nodes,
  }) {
    return GuestProgress(
      schemaVersion: schemaVersion,
      guestId: guestId ?? this.guestId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      streakCount: streakCount ?? this.streakCount,
      lastDailyDate: lastDailyDate ?? this.lastDailyDate,
      todayDailyCompleted:
          todayDailyCompleted ?? this.todayDailyCompleted,
      todayAllCorrect: todayAllCorrect ?? this.todayAllCorrect,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      dailyTotal: dailyTotal,
      dailyPickCount: dailyPickCount,
      dailyBlankCount: dailyBlankCount,
      hearts: hearts ?? this.hearts,
      world1Nodes: world1Nodes ?? this.world1Nodes,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'guestId': guestId,
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'streakCount': streakCount,
        'lastDailyDate': lastDailyDate,
        'todayDailyCompleted': todayDailyCompleted,
        'todayAllCorrect': todayAllCorrect,
        'dailyProgress': dailyProgress,
        'dailyTotal': dailyTotal,
        'dailyPickCount': dailyPickCount,
        'dailyBlankCount': dailyBlankCount,
        'hearts': hearts,
        'world1Nodes': world1Nodes.map(_worldNodeToString).toList(),
      };

  factory GuestProgress.fromJson(Map<String, dynamic> json) {
    return GuestProgress(
      schemaVersion: json['schemaVersion'] as int? ?? 2,
      guestId: json['guestId'] as String? ?? '',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpToNextLevel: json['xpToNextLevel'] as int? ?? 100,
      streakCount: json['streakCount'] as int? ??
          (json['streak'] as int?) ??
          0,
      lastDailyDate: json['lastDailyDate'] as String?,
      todayDailyCompleted: json['todayDailyCompleted'] as bool? ?? false,
      todayAllCorrect: json['todayAllCorrect'] as bool? ?? false,
      dailyProgress: json['dailyProgress'] as int? ?? 0,
      dailyTotal: json['dailyTotal'] as int? ?? 5,
      dailyPickCount: json['dailyPickCount'] as int? ?? 3,
      dailyBlankCount: json['dailyBlankCount'] as int? ?? 2,
      hearts: json['hearts'] as int? ?? 5,
      world1Nodes: _parseWorldNodes(json['world1Nodes']),
    );
  }

  static List<WorldNodeState> _parseWorldNodes(dynamic raw) {
    if (raw is! List) {
      return const [
        WorldNodeState.cleared,
        WorldNodeState.cleared,
        WorldNodeState.current,
        WorldNodeState.locked,
        WorldNodeState.locked,
        WorldNodeState.locked,
        WorldNodeState.locked,
      ];
    }
    return raw.map((e) {
      switch (e) {
        case 'cleared':
          return WorldNodeState.cleared;
        case 'current':
          return WorldNodeState.current;
        default:
          return WorldNodeState.locked;
      }
    }).toList();
  }

  static String _worldNodeToString(WorldNodeState state) {
    return switch (state) {
      WorldNodeState.cleared => 'cleared',
      WorldNodeState.current => 'current',
      WorldNodeState.locked => 'locked',
    };
  }
}
