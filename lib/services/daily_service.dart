import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/daily_question.dart';

const dailyTotal = 5;
const dailyXpPerQuestion = 10;

DailyPack? _cachedPack;

Future<DailyPack> loadDailyPack() async {
  if (_cachedPack != null) return _cachedPack!;
  final raw = await rootBundle.loadString('assets/data/daily_sample.json');
  _cachedPack = DailyPack.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  return _cachedPack!;
}

Future<DailyQuestion?> getDailyQuestion(int index) async {
  final pack = await loadDailyPack();
  if (index < 0 || index >= pack.questions.length) return null;
  return pack.questions[index];
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
}
