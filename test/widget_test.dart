import 'package:algofit/main.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('홈 화면 기본 요소 표시', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    expect(find.text('오늘의 챌린지'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('World 1'), findsOneWidget);
  });
}
