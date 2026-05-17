/// World 1 스테이지 → 문항 ID (docs/07-curriculum-world-1.md MVP)
class StageQuestionRef {
  const StageQuestionRef({
    required this.questionId,
    required this.kind,
  });

  final String questionId;
  final String kind;
}

const world1StageQuestions = <String, StageQuestionRef>{
  'stage_w1_01': StageQuestionRef(
    questionId: 'pick_arr_002',
    kind: 'pick',
  ),
  'stage_w1_02': StageQuestionRef(
    questionId: 'blank_arr_001',
    kind: 'blank',
  ),
  'stage_w1_03': StageQuestionRef(
    questionId: 'pick_arr_003',
    kind: 'pick',
  ),
};

bool hasWorld1StageContent(String stageId) =>
    world1StageQuestions.containsKey(stageId);

StageQuestionRef? world1StageQuestionRef(String stageId) =>
    world1StageQuestions[stageId];
