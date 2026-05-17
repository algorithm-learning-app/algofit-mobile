import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/daily_question.dart';

const dailyTotal = 5;
const dailyPickCount = 3;
const dailyBlankCount = 2;
const dailyXpPerQuestion = 10;

const _idPattern = r'^(pick|blank|scenario)_[a-z0-9_]+$';

DailyPack? _cachedPack;
String? _cachedPackDateKey;
QuestionPools? _cachedPools;

class QuestionPools {
  const QuestionPools({required this.picks, required this.blanks});

  final List<PickQuestion> picks;
  final List<BlankQuestion> blanks;
}

/// Asia/Seoul 기준 오늘 날짜 키 (`yyyy-MM-dd`).
@visibleForTesting
String seoulDateKey([DateTime? referenceUtc]) {
  final utc = (referenceUtc ?? DateTime.now()).toUtc();
  final seoul = utc.add(const Duration(hours: 9));
  final y = seoul.year;
  final m = seoul.month.toString().padLeft(2, '0');
  final d = seoul.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

@visibleForTesting
int seoulDateSeed(String dateKey) {
  final parts = dateKey.split('-');
  return int.parse(parts[0]) * 10000 +
      int.parse(parts[1]) * 100 +
      int.parse(parts[2]);
}

Future<DailyPack> loadDailyPack({DateTime? referenceUtc}) async {
  final dateKey = seoulDateKey(referenceUtc);
  if (_cachedPack != null && _cachedPackDateKey == dateKey) {
    return _cachedPack!;
  }
  final pools = await loadQuestionPools();
  _cachedPack = composeDailyPack(pools, dateKey);
  _cachedPackDateKey = dateKey;
  return _cachedPack!;
}

Future<DailyQuestion?> getDailyQuestion(int index) async {
  final pack = await loadDailyPack();
  if (index < 0 || index >= pack.questions.length) return null;
  return pack.questions[index];
}

Future<DailyQuestion?> getQuestionById(String questionId) async {
  final pools = await loadQuestionPools();
  for (final pick in pools.picks) {
    if (pick.id == questionId) return pick;
  }
  for (final blank in pools.blanks) {
    if (blank.id == questionId) return blank;
  }
  return null;
}

Future<QuestionPools> loadQuestionPools() async {
  if (_cachedPools != null) return _cachedPools!;
  final pickRaw = await rootBundle.loadString('assets/data/pick.json');
  final blankRaw = await rootBundle.loadString('assets/data/blank.json');
  _cachedPools = _parsePools(
    jsonDecode(pickRaw) as Map<String, dynamic>,
    jsonDecode(blankRaw) as Map<String, dynamic>,
  );
  return _cachedPools!;
}

@visibleForTesting
DailyPack composeDailyPack(QuestionPools pools, String dateKey) {
  final seed = seoulDateSeed(dateKey);
  final rng = Random(seed);

  final picks = _sampleFrom(pools.picks, dailyPickCount, rng);
  final blanks = _sampleFrom(pools.blanks, dailyBlankCount, rng);

  final questions = <DailyQuestion>[...picks, ...blanks];
  final packId = 'daily_${dateKey.replaceAll('-', '_')}';

  return DailyPack(
    id: packId,
    title: '오늘의 챌린지',
    questions: questions,
  );
}

List<T> _sampleFrom<T>(List<T> pool, int count, Random rng) {
  if (pool.length <= count) return List<T>.from(pool);
  final indices = List<int>.generate(pool.length, (i) => i)..shuffle(rng);
  return indices.take(count).map((i) => pool[i]).toList();
}

QuestionPools _parsePools(
  Map<String, dynamic> pickBundle,
  Map<String, dynamic> blankBundle,
) {
  final picks = <PickQuestion>[];
  for (final raw in pickBundle['questions'] as List<dynamic>) {
    final q = _tryParsePick(raw as Map<String, dynamic>);
    if (q != null) picks.add(q);
  }

  final blanks = <BlankQuestion>[];
  for (final raw in blankBundle['questions'] as List<dynamic>) {
    final q = _tryParseBlank(raw as Map<String, dynamic>);
    if (q != null) blanks.add(q);
  }

  return QuestionPools(picks: picks, blanks: blanks);
}

PickQuestion? _tryParsePick(Map<String, dynamic> json) {
  final id = json['id'] as String?;
  if (!_isValidId(id)) {
    _logSkip(id, 'invalid id');
    return null;
  }
  if (json['type'] != 'pick') {
    _logSkip(id, 'type is not pick');
    return null;
  }
  try {
    final question = PickQuestion.fromJson(json);
    final choiceIds = question.choices.map((c) => c.id).toSet();
    if (!choiceIds.contains(question.correctChoiceId)) {
      _logSkip(id, 'correctChoiceId not in choices');
      return null;
    }
    if (question.choices.length < 3 || question.choices.length > 4) {
      _logSkip(id, 'choices count must be 3–4');
      return null;
    }
    return question;
  } catch (e, st) {
    _logSkip(id, 'parse error: $e', st);
    return null;
  }
}

BlankQuestion? _tryParseBlank(Map<String, dynamic> json) {
  final id = json['id'] as String?;
  if (!_isValidId(id)) {
    _logSkip(id, 'invalid id');
    return null;
  }
  if (json['type'] != 'blank') {
    _logSkip(id, 'type is not blank');
    return null;
  }
  try {
    final question = BlankQuestion.fromJson(json);
    final placeholders = RegExp(r'\{\{(\w+)\}\}')
        .allMatches(question.codeTemplate)
        .map((m) => m.group(1)!)
        .toSet();
    final blankIds = question.blanks.map((b) => b.id).toSet();
    if (!placeholders.containsAll(blankIds) ||
        !blankIds.containsAll(placeholders)) {
      _logSkip(id, 'codeTemplate placeholders mismatch blanks');
      return null;
    }
    for (final slot in question.blanks) {
      for (final answer in slot.correctAnswers) {
        if (!slot.choices.contains(answer)) {
          _logSkip(id, 'blank ${slot.id} choices missing correctAnswers');
          return null;
        }
      }
    }
    return question;
  } catch (e, st) {
    _logSkip(id, 'parse error: $e', st);
    return null;
  }
}

bool _isValidId(String? id) {
  if (id == null || id.isEmpty) return false;
  return RegExp(_idPattern).hasMatch(id);
}

void _logSkip(String? id, String reason, [StackTrace? st]) {
  developer.log(
    'Skipping question ${id ?? "?"}: $reason',
    name: 'DailyService',
    stackTrace: st,
  );
}

bool checkPickAnswer(PickQuestion question, String choiceId) {
  return choiceId == question.correctChoiceId;
}

bool checkBlankAnswer(
  BlankQuestion question,
  Map<String, String> selections,
) {
  return question.blanks.every((slot) {
    final picked = selections[slot.id];
    if (picked == null) return false;
    return slot.correctAnswers.contains(picked);
  });
}

String renderCodeWithSelections(
  String template,
  Map<String, String> selections,
) {
  return template.replaceAllMapped(RegExp(r'\{\{(\w+)\}\}'), (match) {
    final id = match.group(1)!;
    return selections[id] ?? '{{$id}}';
  });
}

/// 테스트에서 캐시 초기화용
void resetDailyPackCacheForTest() {
  _cachedPack = null;
  _cachedPackDateKey = null;
  _cachedPools = null;
}
