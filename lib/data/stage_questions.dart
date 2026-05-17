import 'world1_stage_questions.dart';
import 'world2_stage_questions.dart';

export 'world1_stage_questions.dart' show StageQuestionRef;

bool hasStageContent(String stageId) =>
    hasWorld1StageContent(stageId) || hasWorld2StageContent(stageId);

StageQuestionRef? stageQuestionRef(String stageId) =>
    world1StageQuestionRef(stageId) ?? world2StageQuestionRef(stageId);
