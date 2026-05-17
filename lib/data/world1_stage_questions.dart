/// World 1 스테이지 → 문항 ID (docs/07-curriculum-world-1.md)
class StageQuestionRef {
  const StageQuestionRef({
    required this.questionId,
    required this.kind,
  });

  final String questionId;
  final String kind;
}

const world1StageQuestions = <String, StageQuestionRef>{
  'stage_w1_01': StageQuestionRef(questionId: 'pick_arr_001', kind: 'pick'),
  'stage_w1_02': StageQuestionRef(questionId: 'blank_arr_001', kind: 'blank'),
  'stage_w1_03': StageQuestionRef(questionId: 'pick_arr_003', kind: 'pick'),
  'stage_w1_04': StageQuestionRef(questionId: 'pick_arr_004', kind: 'pick'),
  'stage_w1_05': StageQuestionRef(questionId: 'pick_tp_001', kind: 'pick'),
  'stage_w1_06': StageQuestionRef(questionId: 'blank_tp_001', kind: 'blank'),
  'stage_w1_07': StageQuestionRef(questionId: 'pick_tp_003', kind: 'pick'),
  'stage_w1_08': StageQuestionRef(questionId: 'pick_tp_002', kind: 'pick'),
  'stage_w1_09': StageQuestionRef(questionId: 'pick_hash_001', kind: 'pick'),
  'stage_w1_10': StageQuestionRef(questionId: 'blank_hash_001', kind: 'blank'),
  'stage_w1_11': StageQuestionRef(questionId: 'pick_hash_003', kind: 'pick'),
  'stage_w1_12': StageQuestionRef(questionId: 'blank_hash_002', kind: 'blank'),
  'stage_w1_13': StageQuestionRef(questionId: 'pick_bs_001', kind: 'pick'),
  'stage_w1_14': StageQuestionRef(questionId: 'blank_bs_001', kind: 'blank'),
  'stage_w1_15': StageQuestionRef(questionId: 'pick_bs_002', kind: 'pick'),
  'stage_w1_16': StageQuestionRef(questionId: 'pick_arr_002', kind: 'pick'),
  'stage_w1_17': StageQuestionRef(questionId: 'pick_hash_002', kind: 'pick'),
  'stage_w1_18': StageQuestionRef(questionId: 'pick_arr_004', kind: 'pick'),
  'stage_w1_19': StageQuestionRef(questionId: 'pick_tp_002', kind: 'pick'),
  'stage_w1_20': StageQuestionRef(questionId: 'blank_bs_002', kind: 'blank'),
};

bool hasWorld1StageContent(String stageId) =>
    world1StageQuestions.containsKey(stageId);

StageQuestionRef? world1StageQuestionRef(String stageId) =>
    world1StageQuestions[stageId];
