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

  test('loadQuestionPools는 pick/blank JSON 풀을 로드한다', () async {
    final pools = await loadQuestionPools();
    expect(pools.picks.length, greaterThanOrEqualTo(14));
    expect(pools.blanks.length, greaterThanOrEqualTo(10));
    expect(pools.picks.every((q) => q.id.startsWith('pick_')), isTrue);
    expect(pools.blanks.every((q) => q.id.startsWith('blank_')), isTrue);
  });

  test('loadDailyPack은 3 pick + 2 blank로 5문항을 구성한다', () async {
    final pack = await loadDailyPack();
    expect(pack.questions.length, dailyTotal);
    expect(pack.title, '오늘의 챌린지');
    expect(pack.id, startsWith('daily_'));

    final pickCount =
        pack.questions.whereType<PickQuestion>().length;
    final blankCount =
        pack.questions.whereType<BlankQuestion>().length;
    expect(pickCount, dailyPickCount);
    expect(blankCount, dailyBlankCount);
  });

  test('composeDailyPack은 같은 서울 날짜에 동일한 문항 ID 순서', () async {
    final pools = await loadQuestionPools();
    const dateKey = '2026-05-18';

    final packA = composeDailyPack(pools, dateKey);
    final packB = composeDailyPack(pools, dateKey);

    expect(packA.id, 'daily_2026_05_18');
    expect(
      packA.questions.map((q) => q.id),
      packB.questions.map((q) => q.id),
    );
    expect(packA.questions.length, dailyTotal);
  });

  test('seoulDateKey는 UTC 기준 서울 달력일을 반환한다', () {
    final utc = DateTime.utc(2026, 5, 17, 20, 0);
    expect(seoulDateKey(utc), '2026-05-18');
  });
}
