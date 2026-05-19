import 'package:algofit/data/stage_questions.dart';
import 'package:algofit/data/world1_stage_questions.dart';
import 'package:algofit/data/world1_stages.dart';
import 'package:algofit/data/world2_stages.dart';
import 'package:algofit/models/daily_question.dart';
import 'package:algofit/services/daily_service.dart';
import 'package:algofit/services/stage_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetDailyPackCacheForTest);

  group('stage mini-set', () {
    test('every World 1 stage has exactly two questions', () {
      for (final stage in world1MapStages) {
        expect(
          stageQuestionCount(stage.id),
          stageMiniSetSize,
          reason: stage.id,
        );
      }
    });

    test('every World 2 stage has exactly two questions', () {
      for (final stage in world2MapStages) {
        expect(
          stageQuestionCount(stage.id),
          stageMiniSetSize,
          reason: stage.id,
        );
      }
    });

    test('two pointer intro avoids meta pick_tp_001', () {
      final set = world1StageQuestionSet('stage_w1_05')!;
      final ids = set.questions.map((q) => q.questionId).toList();
      expect(ids, isNot(contains('pick_tp_001')));
      expect(ids, contains('pick_stage_tp_001'));
    });

    test('binary search intro avoids meta pick_bs_001', () {
      final set = world1StageQuestionSet('stage_w1_13')!;
      final ids = set.questions.map((q) => q.questionId).toList();
      expect(ids, isNot(contains('pick_bs_001')));
      expect(ids, contains('pick_stage_bs_001'));
    });

    test('loadStageQuestion loads by index', () async {
      final q0 = await loadStageQuestion('stage_w1_05', questionIndex: 0);
      final q1 = await loadStageQuestion('stage_w1_05', questionIndex: 1);
      expect(q0?.id, 'pick_stage_tp_001');
      expect(q1?.id, 'pick_tp_002');
    });

    test(
      'stage-specific pick questions parse with application subtype',
      () async {
        final q = await getQuestionById('pick_stage_tp_001');
        expect(q, isA<PickQuestion>());
        expect((q as PickQuestion).pickSubtype, 'application');
      },
    );
  });
}
