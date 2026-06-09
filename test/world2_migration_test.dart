import 'dart:convert';

import 'package:algofit/data/world2_stages.dart';
import 'package:algofit/models/guest_progress.dart';
import 'package:algofit/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// World 2를 10→15 스테이지로 확장했을 때, 기존에 10노드로 저장된 게스트 진행이
/// 로드 시 15노드로 안전하게 마이그레이션되는지 검증한다.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void seedWorld2Nodes(List<String> nodes) {
    SharedPreferences.setMockInitialValues({
      'algofit:guestId': 'test-guest',
      'algofit:guestProgress': jsonEncode({
        'schemaVersion': 5,
        'guestId': 'test-guest',
        'preferredCodeLanguage': 'python',
        'world2Unlocked': true,
        'world2Nodes': nodes,
      }),
    });
  }

  test('10노드 저장본이 15노드로 패딩된다(빈 칸은 locked)', () async {
    seedWorld2Nodes(List.filled(10, 'locked'));
    final repo = await ProgressRepository.create();
    expect(repo.progress.world2Nodes.length, world2TotalStages);
    expect(
      repo.progress.world2Nodes.sublist(10).every(
        (n) => n == WorldNodeState.locked,
      ),
      isTrue,
    );
  });

  test('10노드 전부 cleared면 11번째가 current로 열린다', () async {
    seedWorld2Nodes(List.filled(10, 'cleared'));
    final repo = await ProgressRepository.create();
    final nodes = repo.progress.world2Nodes;
    expect(nodes.length, world2TotalStages);
    expect(nodes.take(10).every((n) => n == WorldNodeState.cleared), isTrue);
    expect(nodes[10], WorldNodeState.current);
  });

  test('target 초과 저장본은 target으로 트림된다', () async {
    seedWorld2Nodes(List.filled(18, 'locked'));
    final repo = await ProgressRepository.create();
    expect(repo.progress.world2Nodes.length, world2TotalStages);
  });

  test('부분 진행 저장본은 패딩만 되고 새 칸은 locked로 유지된다', () async {
    seedWorld2Nodes([...List.filled(9, 'cleared'), 'current']);
    final repo = await ProgressRepository.create();
    final nodes = repo.progress.world2Nodes;
    expect(nodes.length, world2TotalStages);
    expect(nodes[9], WorldNodeState.current);
    expect(
      nodes.sublist(10).every((n) => n == WorldNodeState.locked),
      isTrue,
    );
  });
}
