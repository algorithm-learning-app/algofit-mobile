import 'world1_stage_questions.dart';

/// World 2 스테이지 문항 — World 1과 동일하게 [stageMiniSetSize]문항 미니 세트.
/// 입문 스테이지에는 `pickSubtype: meta`(알고리즘 이름만 고르기) 풀을 쓰지 않는다.
const world2StageQuestions = <String, StageQuestionSet>{
  'stage_w2_01': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stage_stack_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_stack_005', kind: 'pick'),
  ]),
  'stage_w2_02': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_stack_001', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_stack_006', kind: 'pick'),
  ]),
  'stage_w2_03': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_stack_002', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_stack_003', kind: 'pick'),
  ]),
  'stage_w2_04': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stage_bfs_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bfs_003', kind: 'pick'),
  ]),
  'stage_w2_05': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_bfs_001', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_bfs_004', kind: 'pick'),
  ]),
  'stage_w2_06': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stack_007', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_stack_008', kind: 'pick'),
  ]),
  'stage_w2_07': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_stack_003', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_stack_009', kind: 'pick'),
  ]),
  'stage_w2_08': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bfs_005', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_bfs_002', kind: 'blank'),
  ]),
  'stage_w2_09': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bfs_006', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bfs_007', kind: 'pick'),
  ]),
  'stage_w2_10': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bfs_008', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_bfs_003', kind: 'blank'),
  ]),
  'stage_w2_11': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stack_001', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_stack_005', kind: 'blank'),
  ]),
  'stage_w2_12': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stack_002', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_stack_004', kind: 'blank'),
  ]),
  'stage_w2_13': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bfs_001', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_bfs_004', kind: 'blank'),
  ]),
  'stage_w2_14': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bfs_009', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_bfs_005', kind: 'blank'),
  ]),
  'stage_w2_15': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stack_004', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bfs_002', kind: 'pick'),
  ]),
};

bool hasWorld2StageContent(String stageId) =>
    world2StageQuestions.containsKey(stageId);

StageQuestionSet? world2StageQuestionSet(String stageId) =>
    world2StageQuestions[stageId];
