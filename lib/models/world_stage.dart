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
