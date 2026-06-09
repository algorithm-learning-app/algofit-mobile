/// 실전 시나리오(`scenario_map`) 문항 모델.
/// 긴 도메인 지문을 읽고 알맞은 알고리즘 패턴을 고르는 매핑 훈련.
/// 콘텐츠: `assets/data/scenario.json` ([docs/12-real-world-scenarios.md]).
library;

class ScenarioPatternChoice {
  const ScenarioPatternChoice({
    required this.id,
    required this.label,
    required this.patternTag,
  });

  factory ScenarioPatternChoice.fromJson(Map<String, dynamic> json) {
    return ScenarioPatternChoice(
      id: json['id'] as String,
      label: json['label'] as String,
      patternTag: json['patternTag'] as String? ?? '',
    );
  }

  final String id;
  final String label;

  /// 이 선택지가 가리키는 패턴 태그(array, hash, bfs ...). 정답 판정엔 쓰지 않고
  /// 해설·통계용. 정답 여부는 [ScenarioQuestion.primaryPatternIds]로 판정한다.
  final String patternTag;
}

class ScenarioQuestion {
  const ScenarioQuestion({
    required this.id,
    required this.stem,
    required this.scenarioCategory,
    required this.difficulty,
    required this.patternChoices,
    required this.primaryPatternIds,
    required this.explanation,
    this.tags = const [],
    this.tone = 'neutral',
  });

  factory ScenarioQuestion.fromJson(Map<String, dynamic> json) {
    return ScenarioQuestion(
      id: json['id'] as String,
      stem: json['stem'] as String,
      scenarioCategory: json['scenarioCategory'] as String? ?? '',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      patternChoices: (json['patternChoices'] as List<dynamic>)
          .map((e) => ScenarioPatternChoice.fromJson(e as Map<String, dynamic>))
          .toList(),
      primaryPatternIds: (json['primaryPatternIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      explanation: json['explanation'] as String? ?? '',
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      tone: json['tone'] as String? ?? 'neutral',
    );
  }

  final String id;
  final String stem;
  final String scenarioCategory;
  final int difficulty;
  final List<ScenarioPatternChoice> patternChoices;

  /// 정답 선택지 id 목록(1개 이상). 고른 선택지가 이 안에 있으면 정답.
  final List<String> primaryPatternIds;
  final String explanation;
  final List<String> tags;
  final String tone;

  bool isCorrectChoice(String choiceId) =>
      primaryPatternIds.contains(choiceId);
}
