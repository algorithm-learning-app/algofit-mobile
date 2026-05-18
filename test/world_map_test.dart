import 'package:algofit/data/world1_stages.dart';
import 'package:algofit/main.dart';
import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/models/world_stage.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(seedAlgofitTestPrefs);

  testWidgets('전체 보기에서 World 1 맵으로 이동', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('전체 보기'), 200);
    await tester.tap(find.text('전체 보기'));
    await tester.pumpAndSettle();

    expect(find.text('World 1'), findsWidgets);
    expect(find.text(world1Subtitle), findsOneWidget);
    expect(find.text('배열이 뭐죠?'), findsOneWidget);
  });

  testWidgets('학습 탭에서 World 맵으로 이동', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();

    expect(find.text('World 1'), findsWidgets);
    expect(find.text('맵 20개 스테이지 · 전체 20개'), findsOneWidget);
  });

  testWidgets('스테이지 1 탭 시 Pick 문항 화면', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.binding.setSurfaceSize(const Size(480, 1400));
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('배열이 뭐죠?'));
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await pumpUntilFound(tester, find.text('Pick'));

    expect(find.text('Pick'), findsOneWidget);
    expect(find.text('스테이지 준비 중'), findsNothing);
  });

  test('worldStageNodeState는 진행 노드 길이를 따른다', () {
    const nodes = [
      WorldNodeState.cleared,
      WorldNodeState.current,
      WorldNodeState.locked,
    ];
    expect(
      worldStageNodeState(stageOrder: 1, progressNodes: nodes),
      WorldNodeState.cleared,
    );
    expect(
      worldStageNodeState(stageOrder: 3, progressNodes: nodes),
      WorldNodeState.locked,
    );
    expect(
      worldStageNodeState(stageOrder: 4, progressNodes: nodes),
      WorldNodeState.locked,
    );
  });
}
