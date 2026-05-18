import 'dart:math';

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

  test('shufflePickChoices는 correctChoiceId를 유지하고 순서만 바꾼다', () {
    const q = PickQuestion(
      id: 'p1',
      stem: 'stem',
      explanation: 'e',
      feedbackCorrect: 'ok',
      feedbackWrong: 'no',
      choices: [
        DailyChoice(id: 'c1', label: 'correct'),
        DailyChoice(id: 'c2', label: 'wrong-a'),
        DailyChoice(id: 'c3', label: 'wrong-b'),
        DailyChoice(id: 'c4', label: 'wrong-c'),
      ],
      correctChoiceId: 'c1',
    );
    final shuffled = shufflePickChoices(q, Random(42));
    expect(shuffled.correctChoiceId, 'c1');
    expect(shuffled.choices.map((c) => c.id).toSet(), {'c1', 'c2', 'c3', 'c4'});
    expect(checkPickAnswer(shuffled, 'c1'), isTrue);
    expect(checkPickAnswer(shuffled, 'c2'), isFalse);
    final correctIndex =
        shuffled.choices.indexWhere((c) => c.id == shuffled.correctChoiceId);
    expect(correctIndex, isNot(0));
  });

  test('composeDailyPack은 셔플 후에도 choice id로 채점한다', () async {
    final pools = await loadQuestionPools();
    const dateKey = '2026-05-19';
    final pack = composeDailyPack(pools, dateKey).pack;

    for (final q in pack.questions) {
      if (q is! PickQuestion) continue;
      final correct = q.choices.firstWhere((c) => c.id == q.correctChoiceId);
      expect(checkPickAnswer(q, correct.id), isTrue);
      final wrong = q.choices.firstWhere((c) => c.id != q.correctChoiceId);
      expect(checkPickAnswer(q, wrong.id), isFalse);
    }
  });

  test('composeDailyPack은 일부 pick에서 정답이 1번이 아닐 수 있다', () async {
    final pools = await loadQuestionPools();
    final pack = composeDailyPack(pools, '2026-05-19').pack;
    final pickCorrectIndices = pack.questions.whereType<PickQuestion>().map((q) {
      return q.choices.indexWhere((c) => c.id == q.correctChoiceId);
    });
    expect(pickCorrectIndices.any((i) => i != 0), isTrue);
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

  test('recordQuestionOutcome은 deductHeartOnWrong일 때만 하트를 깎는다', () async {
    final repo = await ProgressRepository.create();
    expect(repo.progress.hearts, 5);

    repo.recordQuestionOutcome(
      questionId: 'pick_test',
      isCorrect: false,
      deductHeartOnWrong: true,
    );
    expect(repo.progress.hearts, 4);

    repo.recordQuestionOutcome(
      questionId: 'pick_test2',
      isCorrect: false,
      deductHeartOnWrong: false,
    );
    expect(repo.progress.hearts, 4);
  });

  test('recordDailyAnswer는 Daily에서 하트를 소모하지 않는다', () async {
    final repo = await ProgressRepository.create();
    var session = repo.startDailySession();

    final result = repo.recordDailyAnswer(session, false);
    session = result.session;

    expect(session.hearts, 5);
    expect(result.progress.hearts, 5);
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
    expect(pools.picks.length, greaterThanOrEqualTo(80));
    expect(pools.blanks.length, greaterThanOrEqualTo(50));
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

    final packA = composeDailyPack(pools, dateKey).pack;
    final packB = composeDailyPack(pools, dateKey).pack;

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

  test('filterBlanksByLanguage는 선호 언어만 남긴다', () async {
    final pools = await loadQuestionPools();
    final javaOnly = filterBlanksByLanguage(pools.blanks, 'java');
    expect(javaOnly, isNotEmpty);
    expect(javaOnly.every((q) => q.language == 'java'), isTrue);
  });

  test('composeDailyPack은 java 풀 부족 시 python fallback', () async {
    final pools = await loadQuestionPools();
    const dateKey = '2026-05-20';
    final result = composeDailyPack(
      pools,
      dateKey,
      preferredLanguage: 'kotlin',
    );
    expect(result.usedLanguageFallback, isTrue);
    expect(
      result.pack.questions.whereType<BlankQuestion>().every(
            (q) => q.language == 'python',
          ),
      isTrue,
    );
  });
}
