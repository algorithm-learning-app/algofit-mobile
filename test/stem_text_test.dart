import 'package:algofit/widgets/stem_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('StemText는 **굵게**와 `코드`를 파싱한다', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StemText(text: '**굵게**와 `code`')),
      ),
    );

    expect(find.textContaining('굵게'), findsOneWidget);
    expect(find.textContaining('code'), findsOneWidget);
    expect(find.textContaining('**'), findsNothing);
  });
}
