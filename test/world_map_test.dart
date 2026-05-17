import 'package:algofit/data/world1_stages.dart';
import 'package:algofit/main.dart';
import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/models/world_stage.dart';
import 'package:algofit/router/app_router.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:algofit/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('전체 보기에서 World 1 맵으로 이동', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

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
    await tester.pumpWidget(AlgofitApp(repo: repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('학습'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('배열이 뭐죠?'));
    await tester.pumpAndSettle();

    expect(find.text('Pick'), findsOneWidget);
    expect(find.text('스테이지 준비 중'), findsNothing);
  });

  testWidgets('스테이지 2는 1 클리어 후 Blank', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    repo.completeWorldStage(
      worldId: 1,
      stageOrder: 1,
      questionId: 'pick_arr_001',
    );
    final router = createAppRouter(repo);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark(),
      ),
    );
    router.go('/world/1/stage/stage_w1_02');
    await tester.pumpAndSettle();

    expect(find.text('Blank'), findsOneWidget);
    expect(find.text('스테이지 준비 중'), findsNothing);
  });

  testWidgets('스테이지 5는 Pick 문항 화면', (WidgetTester tester) async {
    final repo = await ProgressRepository.create();
    for (var order = 1; order < 5; order++) {
      repo.completeWorldStage(worldId: 1, stageOrder: order);
    }
    final router = createAppRouter(repo);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.dark(),
      ),
    );
    router.go('/world/1/stage/stage_w1_05');
    await tester.pumpAndSettle();

    expect(find.text('스테이지 준비 중'), findsNothing);
    expect(find.text('Pick'), findsOneWidget);
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
