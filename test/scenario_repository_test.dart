import 'package:algofit/services/progress_repository.dart';
import 'package:algofit/services/scenario_service.dart' show scenarioXpPerQuestion;
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressRepository.recordScenarioAnswer', () {
    test('정답 시 XP만 지급하고 전역 cleared/wrong은 건드리지 않는다', () async {
      seedAlgofitTestPrefs();
      final repo = await ProgressRepository.create();
      final before = repo.progress;

      final after = repo.recordScenarioAnswer(isCorrect: true);

      expect(after.xp, before.xp + scenarioXpPerQuestion);
      expect(after.clearedQuestionIds, before.clearedQuestionIds);
      expect(after.wrongQuestionIds, before.wrongQuestionIds);
    });

    test('오답 시 XP 변화 없고 wrong 풀에 시나리오 id가 유입되지 않는다', () async {
      seedAlgofitTestPrefs();
      final repo = await ProgressRepository.create();
      final before = repo.progress;

      final after = repo.recordScenarioAnswer(isCorrect: false);

      expect(after.xp, before.xp);
      expect(after.wrongQuestionIds, isEmpty);
      expect(after.clearedQuestionIds, before.clearedQuestionIds);
    });
  });
}
