enum WorldNodeState { locked, current, cleared }

const defaultWorld1Nodes = <WorldNodeState>[
  WorldNodeState.current,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
];

const defaultWorld2NodesLocked = <WorldNodeState>[
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
];

const defaultWorld2NodesUnlocked = <WorldNodeState>[
  WorldNodeState.current,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
  WorldNodeState.locked,
];

List<WorldNodeState> defaultWorld2Nodes({bool unlocked = false}) =>
    unlocked ? defaultWorld2NodesUnlocked : defaultWorld2NodesLocked;

class GuestProgress {
  GuestProgress({
    this.schemaVersion = 4,
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
    List<WorldNodeState>? world1Nodes,
    List<WorldNodeState>? world2Nodes,
    this.world2Unlocked = false,
    this.clearedQuestionIds = const [],
    this.wrongQuestionIds = const [],
    this.unlockedBadgeIds = const [],
  })  : world1Nodes = world1Nodes ?? defaultWorld1Nodes,
        world2Nodes = world2Nodes ?? defaultWorld2NodesLocked;

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
  final List<WorldNodeState> world2Nodes;
  final bool world2Unlocked;
  final List<String> clearedQuestionIds;
  final List<String> wrongQuestionIds;
  final List<String> unlockedBadgeIds;

  double get xpPercent =>
      xpToNextLevel > 0 ? (xp / xpToNextLevel).clamp(0.0, 1.0) : 0.0;

  int get world1ClearedCount =>
      world1Nodes.where((n) => n == WorldNodeState.cleared).length;

  bool get isWorld1Complete => world1ClearedCount >= 20;

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
    List<WorldNodeState>? world2Nodes,
    bool? world2Unlocked,
    List<String>? clearedQuestionIds,
    List<String>? wrongQuestionIds,
    List<String>? unlockedBadgeIds,
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
      world2Nodes: world2Nodes ?? this.world2Nodes,
      world2Unlocked: world2Unlocked ?? this.world2Unlocked,
      clearedQuestionIds: clearedQuestionIds ?? this.clearedQuestionIds,
      wrongQuestionIds: wrongQuestionIds ?? this.wrongQuestionIds,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
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
        'world2Nodes': world2Nodes.map(_worldNodeToString).toList(),
        'world2Unlocked': world2Unlocked,
        'clearedQuestionIds': clearedQuestionIds,
        'wrongQuestionIds': wrongQuestionIds,
        'unlockedBadgeIds': unlockedBadgeIds,
      };

  factory GuestProgress.fromJson(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int? ?? 2;
    final schema = version < 4 ? 4 : version;
    final world1 = _parseWorldNodes(
      json['world1Nodes'],
      fallback: defaultWorld1Nodes,
    );
    final w2Unlocked = json['world2Unlocked'] as bool? ??
        (version >= 3 && world1.where((n) => n == WorldNodeState.cleared).length >= 7);
    return GuestProgress(
      schemaVersion: schema,
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
      world1Nodes: world1,
      world2Nodes: _parseWorldNodes(
        json['world2Nodes'],
        fallback: defaultWorld2Nodes(unlocked: w2Unlocked),
      ),
      world2Unlocked: w2Unlocked,
      clearedQuestionIds: _parseStringList(json['clearedQuestionIds']),
      wrongQuestionIds: _parseStringList(json['wrongQuestionIds']),
      unlockedBadgeIds: _parseStringList(json['unlockedBadgeIds']),
    );
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList();
  }

  static List<WorldNodeState> _parseWorldNodes(
    dynamic raw, {
    required List<WorldNodeState> fallback,
  }) {
    if (raw is! List) return fallback;
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
