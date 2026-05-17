import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/data/world1_stages.dart';
import 'package:algofit/models/world_stage.dart';
import 'package:algofit/services/daily_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('advanceWorldNodesAfterClear', () {
    test('clears current stage and unlocks next', () {
      const nodes = [
        WorldNodeState.cleared,
        WorldNodeState.cleared,
        WorldNodeState.current,
        WorldNodeState.locked,
      ];
      final next = advanceWorldNodesAfterClear(
        nodes: nodes,
        clearedStageOrder: 3,
        mapStageCount: world1MapStages.length,
      );
      expect(next[2], WorldNodeState.cleared);
      expect(next[3], WorldNodeState.current);
    });
  });

  group('getQuestionById', () {
    setUp(() {
      resetDailyPackCacheForTest();
    });

    test('loads mapped stage pick question', () async {
      final q = await getQuestionById('pick_arr_002');
      expect(q, isNotNull);
      expect(q!.id, 'pick_arr_002');
    });

    test('loads mapped stage blank question', () async {
      final q = await getQuestionById('blank_arr_001');
      expect(q, isNotNull);
      expect(q!.id, 'blank_arr_001');
    });
  });
}
