import 'dart:convert';

import 'package:algofit/services/daily_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 언어 선택 바텀시트가 테스트를 가리지 않도록 기본 진행 상태를 시드한다.
void seedAlgofitTestPrefs({int? world1CurrentStage}) {
  resetDailyPackCacheForTest();
  const guestId = 'test-guest';
  final progress = <String, dynamic>{
    'schemaVersion': 5,
    'preferredCodeLanguage': 'python',
    'guestId': guestId,
  };
  if (world1CurrentStage != null) {
    progress['world1Nodes'] = List.generate(20, (i) {
      final order = i + 1;
      if (order < world1CurrentStage) return 'cleared';
      if (order == world1CurrentStage) return 'current';
      return 'locked';
    });
  }
  SharedPreferences.setMockInitialValues({
    'algofit:guestId': guestId,
    'algofit:guestProgress': jsonEncode(progress),
  });
}

Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxTicks = 40,
  Duration step = const Duration(milliseconds: 100),
}) async {
  for (var i = 0; i < maxTicks; i++) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) return;
  }
}
