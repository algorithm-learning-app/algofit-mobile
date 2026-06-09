import 'package:algofit/services/scenario_service.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

const _sampleJson = '''
{
  "schemaVersion": 1,
  "type": "scenario_map",
  "questions": [
    {
      "id": "scenario_x_001",
      "type": "scenario_map",
      "stem": "상황 지문 **강조**.",
      "scenarioCategory": "aggregation",
      "tags": ["array"],
      "difficulty": 1,
      "tone": "playful",
      "patternChoices": [
        {"id": "p1", "label": "배열 순회 카운트", "patternTag": "array"},
        {"id": "p2", "label": "이분 탐색", "patternTag": "binary_search"}
      ],
      "primaryPatternIds": ["p1"],
      "explanation": "단일 패스 카운트."
    },
    {
      "id": "scenario_x_002",
      "type": "scenario_map",
      "stem": "두 번째.",
      "scenarioCategory": "navigation",
      "tags": ["bfs"],
      "difficulty": 2,
      "tone": "neutral",
      "patternChoices": [
        {"id": "p1", "label": "BFS", "patternTag": "bfs"},
        {"id": "p2", "label": "스택", "patternTag": "stack"}
      ],
      "primaryPatternIds": ["p1"],
      "explanation": "최소 홉 = BFS."
    }
  ]
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseScenarios', () {
    test('필드를 파싱한다', () {
      final qs = parseScenarios(_sampleJson);
      expect(qs.length, 2);
      final q = qs.first;
      expect(q.id, 'scenario_x_001');
      expect(q.scenarioCategory, 'aggregation');
      expect(q.difficulty, 1);
      expect(q.patternChoices.length, 2);
      expect(q.patternChoices.first.patternTag, 'array');
      expect(q.primaryPatternIds, ['p1']);
    });

    test('isCorrectChoice는 primaryPatternIds로 판정한다', () {
      final q = parseScenarios(_sampleJson).first;
      expect(q.isCorrectChoice('p1'), isTrue);
      expect(q.isCorrectChoice('p2'), isFalse);
    });
  });

  group('buildScenarioSession', () {
    final all = parseScenarios(_sampleJson);

    test('count를 풀 크기로 클램프한다', () {
      final session = buildScenarioSession(all, count: 10);
      expect(session.length, all.length);
    });

    test('요청한 개수만큼 고른다', () {
      final session = buildScenarioSession(all, count: 1);
      expect(session.length, 1);
    });

    test('같은 seed면 결정적이다', () {
      final a = buildScenarioSession(all, seed: 42).map((q) => q.id).toList();
      final b = buildScenarioSession(all, seed: 42).map((q) => q.id).toList();
      expect(a, b);
    });

    test('세션 문항은 모두 원본에서 온 고유 문항이다', () {
      final session = buildScenarioSession(all, count: 2, seed: 7);
      final ids = session.map((q) => q.id).toSet();
      expect(ids.length, session.length); // 중복 없음
      for (final q in session) {
        expect(all.map((e) => e.id), contains(q.id));
      }
    });
  });

  group('번들 콘텐츠 무결성', () {
    test('assets/data/scenario.json이 로드되고 정답이 선택지 안에 있다', () async {
      final raw = await rootBundle.loadString('assets/data/scenario.json');
      final qs = parseScenarios(raw);
      expect(qs.length, greaterThanOrEqualTo(10));
      for (final q in qs) {
        expect(q.primaryPatternIds, isNotEmpty, reason: '${q.id} 정답 없음');
        final choiceIds = q.patternChoices.map((c) => c.id).toSet();
        for (final pid in q.primaryPatternIds) {
          expect(
            choiceIds,
            contains(pid),
            reason: '${q.id} 정답 $pid 가 선택지에 없음',
          );
        }
        expect(q.patternChoices.length, greaterThanOrEqualTo(2));
        expect(q.explanation.trim(), isNotEmpty, reason: '${q.id} 해설 없음');

        // 정답 선택지의 patternTag는 오답 선택지와 겹치지 않아야 정답을
        // patternTag로 구분할 수 있다.
        final primaryTags = q.patternChoices
            .where((c) => q.primaryPatternIds.contains(c.id))
            .map((c) => c.patternTag)
            .where((t) => t.isNotEmpty)
            .toSet();
        for (final c in q.patternChoices) {
          if (q.primaryPatternIds.contains(c.id)) continue;
          if (c.patternTag.isEmpty) continue;
          expect(
            primaryTags,
            isNot(contains(c.patternTag)),
            reason: '${q.id} 오답 ${c.id}의 patternTag(${c.patternTag})가 정답과 겹침',
          );
        }
      }
    });
  });
}
