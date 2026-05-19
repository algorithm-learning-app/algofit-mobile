import '../models/guest_progress.dart';
import '../models/world_stage.dart';
import 'world1_stages.dart';
import 'world2_stages.dart';

/// World 2 해금: World 1 스테이지 클리어 개수
const world2UnlockClearedCount = 7;

class WorldDefinition {
  const WorldDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.totalStages,
    required this.stages,
    required this.defaultNodesLocked,
    required this.defaultNodesUnlocked,
    this.unlockAfterWorld1Cleared,
  });

  final int id;
  final String title;
  final String subtitle;
  final int totalStages;
  final List<WorldStage> stages;
  final List<WorldNodeState> defaultNodesLocked;
  final List<WorldNodeState> defaultNodesUnlocked;

  /// `null`이면 항상 해금. 값이 있으면 World 1 클리어 수로 World 2 해금.
  final int? unlockAfterWorld1Cleared;

  int get mapStageCount => stages.length;

  List<WorldNodeState> defaultNodes({required bool unlocked}) =>
      unlocked ? defaultNodesUnlocked : defaultNodesLocked;
}

const _worldCatalog = <int, WorldDefinition>{
  1: WorldDefinition(
    id: 1,
    title: world1Title,
    subtitle: world1Subtitle,
    totalStages: world1TotalStages,
    stages: world1MapStages,
    defaultNodesLocked: defaultWorld1Nodes,
    defaultNodesUnlocked: defaultWorld1Nodes,
  ),
  2: WorldDefinition(
    id: 2,
    title: world2Title,
    subtitle: world2Subtitle,
    totalStages: world2TotalStages,
    stages: world2MapStages,
    defaultNodesLocked: defaultWorld2NodesLocked,
    defaultNodesUnlocked: defaultWorld2NodesUnlocked,
    unlockAfterWorld1Cleared: world2UnlockClearedCount,
  ),
};

Iterable<int> get supportedWorldIds => _worldCatalog.keys;

WorldDefinition? worldById(int worldId) => _worldCatalog[worldId];

bool isWorldSupported(int worldId) => _worldCatalog.containsKey(worldId);

extension GuestProgressWorldAccess on GuestProgress {
  List<WorldNodeState> nodesForWorld(int worldId) {
    return switch (worldId) {
      1 => world1Nodes,
      2 => world2Nodes,
      _ => const [],
    };
  }

  bool isWorldPlayable(int worldId) {
    final def = worldById(worldId);
    if (def == null) return false;
    if (def.unlockAfterWorld1Cleared == null) return true;
    return world2Unlocked;
  }

  GuestProgress withWorldNodes(int worldId, List<WorldNodeState> nodes) {
    return switch (worldId) {
      1 => copyWith(world1Nodes: nodes),
      2 => copyWith(world2Nodes: nodes),
      _ => this,
    };
  }
}
