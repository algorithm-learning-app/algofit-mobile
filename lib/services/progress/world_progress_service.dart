import '../../data/world_catalog.dart';
import '../../models/guest_progress.dart';
import '../../models/world_stage.dart' show advanceWorldNodesAfterClear;
import '../stage_service.dart';
import 'progress_math.dart';

class WorldProgressService {
  const WorldProgressService();

  GuestProgress completeStage({
    required GuestProgress progress,
    required int worldId,
    required int stageOrder,
    String? questionId,
  }) {
    final def = worldById(worldId);
    if (def == null) return progress;
    if (!progress.isWorldPlayable(worldId)) return progress;

    var nodes = List<WorldNodeState>.from(progress.nodesForWorld(worldId));
    while (nodes.length < def.mapStageCount) {
      nodes.add(WorldNodeState.locked);
    }

    final idx = stageOrder - 1;
    final alreadyCleared =
        idx >= 0 && idx < nodes.length && nodes[idx] == WorldNodeState.cleared;

    final updatedNodes = alreadyCleared
        ? nodes
        : advanceWorldNodesAfterClear(
            nodes: nodes,
            clearedStageOrder: stageOrder,
            mapStageCount: def.mapStageCount,
          );

    var next = alreadyCleared ? progress : addXp(progress, stageXpPerQuestion);
    next = next.withWorldNodes(worldId, updatedNodes);
    next = withQuestionCleared(next, questionId);

    if (worldId == 1) {
      final clearedCount =
          updatedNodes.where((n) => n == WorldNodeState.cleared).length;
      final unlockThreshold = worldById(2)?.unlockAfterWorld1Cleared;
      if (unlockThreshold != null &&
          clearedCount >= unlockThreshold &&
          !next.world2Unlocked) {
        next = next.copyWith(
          world2Unlocked: true,
          world2Nodes: defaultWorld2Nodes(unlocked: true),
        );
      }
    }

    return withBadges(progress, next);
  }
}
