import 'package:algofit/data/stage_questions.dart';
import 'package:algofit/data/world2_stage_questions.dart';
import 'package:algofit/data/world2_stages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('World 2 has 10 MVP stages with question mapping', () {
    expect(world2MapStages.length, world2TotalStages);
    expect(world2TotalStages, 10);
    for (final stage in world2MapStages) {
      expect(hasWorld2StageContent(stage.id), isTrue, reason: stage.id);
    }
    expect(world2StageQuestions.length, world2MapStages.length);
    for (final stage in world2MapStages) {
      expect(stageQuestionCount(stage.id), stageMiniSetSize, reason: stage.id);
    }
  });
}
