import 'package:algofit/models/daily_question.dart';
import 'package:algofit/services/daily_service.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    resetDailyPackCacheForTest();
    SharedPreferences.setMockInitialValues({});
  });

  test('checkPickAnswer는 correctChoiceId와 일치 여부를 반환한다', () {
    const q = PickQuestion(
      id: 'p1',
      stem: 'stem',
      explanation: 'e',
      feedbackCorrect: 'ok',
      feedbackWrong: 'no',
      choices: [
        DailyChoice(id: 'c1', label: 'a'),
        DailyChoice(id: 'c2', label: 'b'),
      ],
      correctChoiceId: 'c1',
    );
    expect(checkPickAnswer(q, 'c1'), isTrue);
    expect(checkPickAnswer(q, 'c2'), isFalse);
  });

  test('checkBlankAnswer는 모든 빈칸이 맞아야 true', () {
    const q = BlankQuestion(
      id: 'b1',
      stem: 'stem',
      explanation: 'e',
      feedbackCorrect: 'ok',
      feedbackWrong: 'no',
      codeTemplate: '{{b1}}',
      blanks: [
        BlankSlot(
          id: 'b1',
          correctAnswers: ['left < right'],
          choices: ['left < right', 'left > right'],
        ),
      ],
    );
    expect(
      checkBlankAnswer(q, {'b1': 'left < right'}),
      isTrue,
    );
    expect(
      checkBlankAnswer(q, {'b1': 'left > right'}),
      isFalse,
    );
  });

  test('recordDailyAnswer는 오답 시 하트를 1 감소시킨다', () async {
    final repo = await ProgressRepository.create();
    var session = repo.startDailySession();

    final result = repo.recordDailyAnswer(session, false);
    session = result.session;

    expect(session.hearts, 4);
    expect(session.xpEarned, dailyXpPerQuestion);
    expect(result.progress.xp, dailyXpPerQuestion);
  });

  test('completeDailyChallenge는 5/5 정답일 때만 streak 증가', () async {
    final repo = await ProgressRepository.create();

    var session = repo.startDailySession();
    for (var i = 0; i < dailyTotal; i++) {
      final recorded = repo.recordDailyAnswer(session, true);
      session = recorded.session;
      if (i < dailyTotal - 1) {
        session = repo.advanceAfterFeedback(session);
      }
    }

    final progress = repo.completeDailyChallenge(session);
    expect(progress.todayAllCorrect, isTrue);
    expect(progress.streakCount, 1);
    expect(progress.todayDailyCompleted, isTrue);
  });

  test('loadDailyPack은 JSON 에셋에서 5문항을 로드한다', () async {
    final pack = await loadDailyPack();
    expect(pack.id, 'daily_sample_001');
    expect(pack.questions.length, dailyTotal);
  });
}
