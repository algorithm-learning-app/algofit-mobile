import '../data/stage_questions.dart';
import '../models/daily_question.dart';
import 'daily_service.dart';

const stageXpPerQuestion = 10;

Future<DailyQuestion?> loadStageQuestion(String stageId) async {
  final ref = stageQuestionRef(stageId);
  if (ref == null) return null;
  return getQuestionById(ref.questionId);
}
