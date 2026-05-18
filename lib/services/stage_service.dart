import '../data/stage_questions.dart';
import '../models/daily_question.dart';
import 'daily_service.dart';

const stageXpPerQuestion = 10;

Future<DailyQuestion?> loadStageQuestion(
  String stageId, {
  String? preferredLanguage,
}) async {
  final ref = stageQuestionRef(stageId);
  if (ref == null) return null;
  if (ref.kind == 'blank') {
    return resolveStageQuestion(
      ref.questionId,
      preferredLanguage: preferredLanguage,
    );
  }
  return getQuestionById(ref.questionId);
}
