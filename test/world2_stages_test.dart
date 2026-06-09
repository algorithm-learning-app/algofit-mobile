import 'package:algofit/data/stage_questions.dart';
import 'package:algofit/data/world2_stage_questions.dart';
import 'package:algofit/data/world2_stages.dart';
import 'package:algofit/models/guest_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World 2 has 15 stages with question mapping', () {
    expect(world2MapStages.length, world2TotalStages);
    expect(world2TotalStages, 15);
    for (final stage in world2MapStages) {
      expect(hasWorld2StageContent(stage.id), isTrue, reason: stage.id);
    }
    expect(world2StageQuestions.length, world2MapStages.length);
    for (final stage in world2MapStages) {
      expect(stageQuestionCount(stage.id), stageMiniSetSize, reason: stage.id);
    }
  });

  test('스테이지 order가 1..15로 연속이다', () {
    final orders = world2MapStages.map((s) => s.order).toList();
    expect(orders, List.generate(world2TotalStages, (i) => i + 1));
  });

  test('기본 노드 리스트 길이가 스테이지 수와 일치한다', () {
    expect(defaultWorld2NodesLocked.length, world2TotalStages);
    expect(defaultWorld2NodesUnlocked.length, world2TotalStages);
    expect(defaultWorld2NodesUnlocked.first, WorldNodeState.current);
  });
}
