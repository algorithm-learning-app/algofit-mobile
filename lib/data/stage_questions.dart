import 'world1_stage_questions.dart';
import 'world2_stage_questions.dart';

export 'world1_stage_questions.dart'
    show StageQuestionRef, StageQuestionSet, stageMiniSetSize;

bool hasStageContent(String stageId) =>
    hasWorld1StageContent(stageId) || hasWorld2StageContent(stageId);

StageQuestionSet? stageQuestionSet(String stageId) =>
    world1StageQuestionSet(stageId) ?? world2StageQuestionSet(stageId);

int stageQuestionCount(String stageId) =>
    stageQuestionSet(stageId)?.questions.length ?? 0;
