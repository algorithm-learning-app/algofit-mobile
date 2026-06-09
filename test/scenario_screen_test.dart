import 'package:algofit/main.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(seedAlgofitTestPrefs);

  testWidgets('홈 실전 시나리오 카드 → 세션 진입 → 답안 제출 → 피드백', (
    WidgetTester tester,
  ) async {
    final repo = await ProgressRepository.create();
    await tester.binding.setSurfaceSize(const Size(480, 1600));
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    // 홈에서 실전 시나리오 카드로 진입
    await tester.scrollUntilVisible(find.text('실전 시나리오'), 200);
    await tester.tap(find.text('실전 시나리오'));
    await tester.pumpAndSettle();

    // 시나리오 세션 로드(비동기) 대기
    await pumpUntilFound(tester, find.text('어떤 패턴으로 풀까요?'));
    expect(find.text('어떤 패턴으로 풀까요?'), findsOneWidget);

    // 제출 전: 확인 버튼 비활성
    final submit = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '확인'),
    );
    expect(submit.onPressed, isNull);

    // 첫 선택지 탭 → 확인 활성 → 제출
    await tester.tap(find.byKey(const ValueKey('scenario-choice-0')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '확인'));
    await tester.pumpAndSettle();

    // 피드백 화면: 다음/결과 보기 버튼 노출 + 정답/오답 표시
    final hasContinue =
        find.widgetWithText(FilledButton, '다음').evaluate().isNotEmpty ||
        find.widgetWithText(FilledButton, '결과 보기').evaluate().isNotEmpty;
    expect(hasContinue, isTrue);
    final hasVerdict =
        find.text('정답!').evaluate().isNotEmpty ||
        find.text('아쉬워요').evaluate().isNotEmpty;
    expect(hasVerdict, isTrue);
  });
}
