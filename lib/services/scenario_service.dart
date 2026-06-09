import 'dart:convert';
import 'dart:math' show Random;

import 'package:flutter/services.dart' show rootBundle;

import '../models/scenario_question.dart';

/// 실전 시나리오 1문항 정답 시 XP. Daily(10)보다 지문이 길고 난도가 있어 약간 높게.
const scenarioXpPerQuestion = 15;

/// 한 세션 문항 수(스펙: 3~5문항). 풀이 길이가 길어 5로 둔다.
const scenarioSessionSize = 5;

const _scenarioAssetPath = 'assets/data/scenario.json';

/// `assets/data/scenario.json` 번들 전체를 파싱한다.
List<ScenarioQuestion> parseScenarios(String jsonStr) {
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  return (data['questions'] as List<dynamic>)
      .map((e) => ScenarioQuestion.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// 번들에서 시나리오 전체를 로드한다.
Future<List<ScenarioQuestion>> loadScenarios() async {
  final raw = await rootBundle.loadString(_scenarioAssetPath);
  return parseScenarios(raw);
}

/// [all]에서 [count]개를 골라 한 세션을 만든다.
/// [count]가 0 이하면 빈 세션을, 풀 크기를 넘으면 풀 크기로 클램프한다.
/// [seed]가 주어지면 셔플이 결정적이라 테스트에서 재현 가능하다.
List<ScenarioQuestion> buildScenarioSession(
  List<ScenarioQuestion> all, {
  int count = scenarioSessionSize,
  int? seed,
}) {
  if (count <= 0) return <ScenarioQuestion>[];
  final pool = List<ScenarioQuestion>.from(all);
  pool.shuffle(seed == null ? null : Random(seed));
  return pool.take(count.clamp(0, pool.length)).toList();
}
