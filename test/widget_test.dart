import 'package:flutter_test/flutter_test.dart';

import 'package:algofit/main.dart';

void main() {
  testWidgets('홈 화면 기본 요소 표시', (WidgetTester tester) async {
    await tester.pumpWidget(const AlgofitApp());
    await tester.pumpAndSettle();

    expect(find.text('오늘의 챌린지'), findsOneWidget);
    expect(find.text('이어하기'), findsOneWidget);
    expect(find.text('World 1'), findsOneWidget);
  });
}
