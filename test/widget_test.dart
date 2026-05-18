import 'package:algofit/main.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(seedAlgofitTestPrefs);

  testWidgets('홈 화면 기본 요소 표시', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.binding.setSurfaceSize(const Size(480, 1200));
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 챌린지'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('뱃지'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('World 1'), 200);
    expect(find.text('World 1'), findsOneWidget);
    expect(find.text('전체 보기'), findsOneWidget);
  });
}
