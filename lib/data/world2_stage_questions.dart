import 'world1_stage_questions.dart';

const world2StageQuestions = <String, StageQuestionRef>{
  'stage_w2_01': StageQuestionRef(questionId: 'pick_stack_001', kind: 'pick'),
  'stage_w2_02': StageQuestionRef(questionId: 'blank_stack_001', kind: 'blank'),
  'stage_w2_03': StageQuestionRef(questionId: 'blank_stack_002', kind: 'blank'),
  'stage_w2_04': StageQuestionRef(questionId: 'pick_bfs_001', kind: 'pick'),
  'stage_w2_05': StageQuestionRef(questionId: 'blank_bfs_001', kind: 'blank'),
  'stage_w2_06': StageQuestionRef(questionId: 'pick_stack_002', kind: 'pick'),
  'stage_w2_07': StageQuestionRef(questionId: 'blank_stack_003', kind: 'blank'),
  'stage_w2_08': StageQuestionRef(questionId: 'pick_stack_003', kind: 'pick'),
  'stage_w2_09': StageQuestionRef(questionId: 'blank_bfs_002', kind: 'blank'),
  'stage_w2_10': StageQuestionRef(questionId: 'pick_bfs_002', kind: 'pick'),
};

bool hasWorld2StageContent(String stageId) =>
    world2StageQuestions.containsKey(stageId);

StageQuestionRef? world2StageQuestionRef(String stageId) =>
    world2StageQuestions[stageId];
