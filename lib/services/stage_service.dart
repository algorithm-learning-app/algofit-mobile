import '../data/stage_questions.dart';
import '../models/daily_question.dart';
import 'daily_service.dart';

const stageXpPerQuestion = 10;

Future<DailyQuestion?> loadStageQuestion(
  String stageId, {
  required int questionIndex,
  String? preferredLanguage,
}) async {
  final set = stageQuestionSet(stageId);
  if (set == null ||
      questionIndex < 0 ||
      questionIndex >= set.questions.length) {
    return null;
  }
  final ref = set.questions[questionIndex];
  if (ref.isBlank) {
    return resolveStageQuestion(
      ref.questionId,
      preferredLanguage: preferredLanguage,
    );
  }
  return getQuestionById(ref.questionId);
}
