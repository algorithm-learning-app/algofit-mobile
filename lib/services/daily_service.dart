import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/code_language.dart';
import '../models/daily_question.dart';
import 'question_pool_cache.dart';

export 'question_pool_cache.dart' show QuestionPools;

const dailyTotal = 5;
const dailyPickCount = 3;
const dailyBlankCount = 2;
const dailyXpPerQuestion = 10;

const _idPattern = r'^(pick|blank|scenario)_[a-z0-9_]+$';

final _cache = QuestionPoolCache.instance;

class DailyComposeResult {
  const DailyComposeResult({
    required this.pack,
    this.usedLanguageFallback = false,
  });

  final DailyPack pack;
  final bool usedLanguageFallback;
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

Future<DailyPack> loadDailyPack({
  DateTime? referenceUtc,
  String? preferredLanguage,
}) async {
  final result = await loadDailyPackWithMeta(
    referenceUtc: referenceUtc,
    preferredLanguage: preferredLanguage,
  );
  return result.pack;
}

Future<DailyComposeResult> loadDailyPackWithMeta({
  DateTime? referenceUtc,
  String? preferredLanguage,
}) async {
  final lang = CodeLanguage.normalize(preferredLanguage);
  final dateKey = seoulDateKey(referenceUtc);
  if (_cache.dailyPack != null &&
      _cache.dailyPackDateKey == dateKey &&
      _cache.dailyPackLanguage == lang) {
    return DailyComposeResult(pack: _cache.dailyPack!);
  }
  final pools = await loadQuestionPools();
  final composed = composeDailyPack(pools, dateKey, preferredLanguage: lang);
  _cache.setDailyPack(pack: composed.pack, dateKey: dateKey, language: lang);
  return composed;
}

Future<DailyQuestion?> getDailyQuestion(
  int index, {
  String? preferredLanguage,
}) async {
  final pack = await loadDailyPack(preferredLanguage: preferredLanguage);
  if (index < 0 || index >= pack.questions.length) return null;
  return pack.questions[index];
}

Future<DailyQuestion?> getQuestionById(String questionId) async {
  final pools = await loadQuestionPools();
  for (final pick in pools.picks) {
    if (pick.id == questionId) {
      return withShuffledChoices(
        pick,
        Random(choiceShuffleSeed('review', questionId)),
      );
    }
  }
  for (final blank in pools.blanks) {
    if (blank.id == questionId) {
      return withShuffledChoices(
        blank,
        Random(choiceShuffleSeed('review', questionId)),
      );
    }
  }
  return null;
}

/// 날짜·문항별로 안정적인 선택지 순서 시드.
@visibleForTesting
int choiceShuffleSeed(String scope, String questionId) {
  return Object.hash(scope, questionId);
}

/// 선택지 순서만 섞고 정답 id/문자열은 유지한다.
@visibleForTesting
DailyQuestion withShuffledChoices(DailyQuestion question, Random rng) {
  if (question is PickQuestion) {
    return shufflePickChoices(question, rng);
  }
  if (question is BlankQuestion) {
    return shuffleBlankChoices(question, rng);
  }
  return question;
}

@visibleForTesting
PickQuestion shufflePickChoices(PickQuestion question, Random rng) {
  final choices = List<DailyChoice>.from(question.choices)..shuffle(rng);
  return PickQuestion(
    id: question.id,
    stem: question.stem,
    explanation: question.explanation,
    feedbackCorrect: question.feedbackCorrect,
    feedbackWrong: question.feedbackWrong,
    choices: choices,
    correctChoiceId: question.correctChoiceId,
    tags: question.tags,
    pickSubtype: question.pickSubtype,
  );
}

@visibleForTesting
BlankQuestion shuffleBlankChoices(BlankQuestion question, Random rng) {
  final blanks = question.blanks.map((slot) {
    final choices = List<String>.from(slot.choices)..shuffle(rng);
    return BlankSlot(
      id: slot.id,
      correctAnswers: slot.correctAnswers,
      choices: choices,
    );
  }).toList();
  return BlankQuestion(
    id: question.id,
    stem: question.stem,
    explanation: question.explanation,
    feedbackCorrect: question.feedbackCorrect,
    feedbackWrong: question.feedbackWrong,
    codeTemplate: question.codeTemplate,
    blanks: blanks,
    language: question.language,
    tags: question.tags,
  );
}

Future<QuestionPools> loadQuestionPools() async {
  if (_cache.pools != null) return _cache.pools!;
  final pickRaw = await rootBundle.loadString('assets/data/pick.json');
  final blankRaw = await rootBundle.loadString('assets/data/blank.json');
  final pools = _parsePools(
    jsonDecode(pickRaw) as Map<String, dynamic>,
    jsonDecode(blankRaw) as Map<String, dynamic>,
  );
  _cache.setPools(pools);
  return pools;
}

@visibleForTesting
List<BlankQuestion> filterBlanksByLanguage(
  List<BlankQuestion> blanks,
  String preferredLanguage,
) {
  final lang = CodeLanguage.normalize(preferredLanguage);
  return blanks.where((q) => q.language == lang).toList();
}

@visibleForTesting
DailyComposeResult composeDailyPack(
  QuestionPools pools,
  String dateKey, {
  String preferredLanguage = CodeLanguage.defaultId,
}) {
  final seed = seoulDateSeed(dateKey);
  final rng = Random(seed);
  final lang = CodeLanguage.normalize(preferredLanguage);

  final picks = _sampleFrom(pools.picks, dailyPickCount, rng);

  var blankPool = filterBlanksByLanguage(pools.blanks, lang);
  var usedFallback = false;
  if (blankPool.length < dailyBlankCount && lang != CodeLanguage.defaultId) {
    blankPool = filterBlanksByLanguage(pools.blanks, CodeLanguage.defaultId);
    usedFallback = true;
  }

  final blanks = _sampleFrom(blankPool, dailyBlankCount, rng);

  final questions = <DailyQuestion>[...picks, ...blanks]
      .map(
        (q) => withShuffledChoices(q, Random(choiceShuffleSeed(dateKey, q.id))),
      )
      .toList();
  final packId = 'daily_${dateKey.replaceAll('-', '_')}';

  return DailyComposeResult(
    pack: DailyPack(id: packId, title: '오늘의 챌린지', questions: questions),
    usedLanguageFallback: usedFallback,
  );
}

/// 스테이지 고정 blank가 선호 언어와 다를 때 같은 태그·난이도 풀에서 대체.
@visibleForTesting
BlankQuestion? findBlankSubstitute(
  BlankQuestion original,
  List<BlankQuestion> pool,
  String preferredLanguage,
) {
  final lang = CodeLanguage.normalize(preferredLanguage);
  if (original.language == lang) return original;

  final tag = original.tags.isNotEmpty ? original.tags.first : null;
  final candidates = pool.where((q) {
    if (q.id == original.id || q.language != lang) return false;
    if (tag == null) return true;
    return q.tags.contains(tag);
  }).toList();

  if (candidates.isEmpty) return null;
  return candidates.first;
}

Future<DailyQuestion?> resolveStageQuestion(
  String questionId, {
  String? preferredLanguage,
}) async {
  final pools = await loadQuestionPools();
  final lang = CodeLanguage.normalize(preferredLanguage);

  DailyQuestion? q;
  for (final pick in pools.picks) {
    if (pick.id == questionId) {
      q = pick;
      break;
    }
  }
  if (q == null) {
    for (final blank in pools.blanks) {
      if (blank.id == questionId) {
        q = blank;
        break;
      }
    }
  }
  if (q == null) return null;

  DailyQuestion resolved = q;
  if (q is BlankQuestion && q.language != lang) {
    final substitute = findBlankSubstitute(q, pools.blanks, lang);
    if (substitute != null) {
      resolved = substitute;
    } else if (lang != CodeLanguage.defaultId) {
      final py = findBlankSubstitute(q, pools.blanks, CodeLanguage.defaultId);
      if (py != null) resolved = py;
    }
  }

  return withShuffledChoices(
    resolved,
    Random(choiceShuffleSeed('stage', resolved.id)),
  );
}

List<T> _sampleFrom<T>(List<T> pool, int count, Random rng) {
  if (pool.isEmpty) return const [];
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
    final placeholders = RegExp(
      r'\{\{(\w+)\}\}',
    ).allMatches(question.codeTemplate).map((m) => m.group(1)!).toSet();
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

bool checkBlankAnswer(BlankQuestion question, Map<String, String> selections) {
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
  QuestionPoolCache.instance.resetAll();
}
