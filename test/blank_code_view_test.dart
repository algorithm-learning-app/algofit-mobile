import 'package:algofit/widgets/blank_code_parser.dart';
import 'package:algofit/widgets/blank_code_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBlankCodeTemplate', () {
    test('finds b1 and b2 placeholders in order', () {
      const template =
          'while {{b1}}:\n        s = nums[left] + nums[right]\n        elif s < target:\n            {{b2}}';
      final ids = blankIdsFromTemplate(template);
      expect(ids, ['b1', 'b2']);
    });

    test('returns text-only segment when no placeholders', () {
      final segments = parseBlankCodeTemplate('return total');
      expect(segments.length, 1);
      expect(segments.first, isA<BlankCodeTextSegment>());
      expect((segments.first as BlankCodeTextSegment).text, 'return total');
    });

    test('splits leading text, placeholder, trailing text', () {
      final segments = parseBlankCodeTemplate('for x in {{b1}}:\n    pass');
      expect(segments.length, 3);
      expect((segments[0] as BlankCodeTextSegment).text, 'for x in ');
      expect((segments[1] as BlankCodePlaceholderSegment).blankId, 'b1');
      expect((segments[2] as BlankCodeTextSegment).text, ':\n    pass');
    });
  });

  group('BlankCodeView', () {
    testWidgets('renders blank chips for each placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlankCodeView(codeTemplate: 'if {{b1}}:\n    {{b2}}'),
          ),
        ),
      );

      expect(find.textContaining('「'), findsNWidgets(2));
      expect(find.textContaining('b1'), findsWidgets);
      expect(find.textContaining('b2'), findsWidgets);
      expect(find.text('빈칸 b1 · b2를 아래에서 고르세요'), findsOneWidget);
    });

    testWidgets('shows selected value in chip when filled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlankCodeView(
              codeTemplate: 'for x in {{b1}}:',
              selections: {'b1': 'nums'},
            ),
          ),
        ),
      );

      expect(find.text('nums'), findsOneWidget);
      expect(find.textContaining('「'), findsNothing);
    });
  });
}
