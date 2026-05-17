import 'guest_progress.dart';

class WorldStage {
  const WorldStage({
    required this.id,
    required this.order,
    required this.title,
    required this.tags,
  });

  final String id;
  final int order;
  final String title;
  final List<String> tags;
}

WorldNodeState worldStageNodeState({
  required int stageOrder,
  required List<WorldNodeState> progressNodes,
}) {
  final index = stageOrder - 1;
  if (index < progressNodes.length) {
    return progressNodes[index];
  }
  return WorldNodeState.locked;
}

/// 스테이지 클리어 후 맵 노드 갱신 (order는 1-based)
List<WorldNodeState> advanceWorld1NodesAfterClear({
  required List<WorldNodeState> nodes,
  required int clearedStageOrder,
  required int mapStageCount,
}) {
  final result = List<WorldNodeState>.from(nodes);
  while (result.length < mapStageCount) {
    result.add(WorldNodeState.locked);
  }

  final idx = clearedStageOrder - 1;
  if (idx < 0 || idx >= result.length) return result;

  result[idx] = WorldNodeState.cleared;
  final nextIdx = idx + 1;
  if (nextIdx < result.length && result[nextIdx] == WorldNodeState.locked) {
    result[nextIdx] = WorldNodeState.current;
  }
  return result;
}
