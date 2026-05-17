import '../models/daily_question.dart';
import 'daily_service.dart';

Future<List<DailyQuestion>> questionsForPattern(String patternTag) async {
  final pools = await loadQuestionPools();
  final result = <DailyQuestion>[
    ...pools.picks.where((q) => q.tags.contains(patternTag)),
    ...pools.blanks.where((q) => q.tags.contains(patternTag)),
  ];
  result.sort((a, b) => a.id.compareTo(b.id));
  return result;
}

int clearedCountForPattern({
  required String patternTag,
  required List<String> clearedQuestionIds,
  required List<DailyQuestion> pool,
}) {
  if (pool.isEmpty) return 0;
  final cleared = clearedQuestionIds.toSet();
  return pool.where((q) => cleared.contains(q.id)).length;
}

double progressPercentForPattern({
  required String patternTag,
  required List<String> clearedQuestionIds,
  required List<DailyQuestion> pool,
}) {
  if (pool.isEmpty) return 0;
  final cleared = clearedCountForPattern(
    patternTag: patternTag,
    clearedQuestionIds: clearedQuestionIds,
    pool: pool,
  );
  return (cleared / pool.length).clamp(0.0, 1.0);
}
