/// World 1 스테이지 → 문항 미니 세트 ([stageMiniSetSize]문항)
///
/// ## 페다고지 규칙
/// - **입문 스테이지**(제목·태그에 패턴 X): 문항은 패턴 X를 **적용**해야 한다.
///   (빈칸 코드, 상황 인지 pick — 선택지는 전술·구현이지 알고리즘 이름만 나열하지 않는다.)
/// - **메타 pick**("어떤 알고리즘?"): 전용 「패턴 고르기」 스테이지·Daily만.
///   `pickSubtype: meta` 풀(예: pick_tp_001, pick_bs_001)은 입문 스테이지에 넣지 않는다.
/// - 스테이지 클리어: 세트 문항 **전부** 정답(오답 시 하트 차감 후 같은 문항 재시도).
///
/// docs/07-curriculum-world-1.md
class StageQuestionRef {
  const StageQuestionRef({
    required this.questionId,
    required this.kind,
  });

  final String questionId;
  final String kind;
}

/// 스테이지 1회 플레이당 문항 수.
const stageMiniSetSize = 2;

class StageQuestionSet {
  const StageQuestionSet(this.questions);

  final List<StageQuestionRef> questions;
}

const world1StageQuestions = <String, StageQuestionSet>{
  'stage_w1_01': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_arr_007', kind: 'pick'),
  ]),
  'stage_w1_02': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_005', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_arr_001', kind: 'blank'),
  ]),
  'stage_w1_03': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_arr_004', kind: 'pick'),
  ]),
  'stage_w1_04': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_004', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_arr_002', kind: 'pick'),
  ]),
  'stage_w1_05': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stage_tp_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_tp_002', kind: 'pick'),
  ]),
  'stage_w1_06': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_tp_001', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_tp_003', kind: 'pick'),
  ]),
  'stage_w1_07': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_tp_003', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_tp_007', kind: 'pick'),
  ]),
  'stage_w1_08': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_tp_002', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_str_001', kind: 'pick'),
  ]),
  'stage_w1_09': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_hash_004', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_hash_006', kind: 'pick'),
  ]),
  'stage_w1_10': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_hash_001', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_hash_002', kind: 'pick'),
  ]),
  'stage_w1_11': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_hash_003', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_hash_005', kind: 'pick'),
  ]),
  'stage_w1_12': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_hash_002', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_hash_007', kind: 'pick'),
  ]),
  'stage_w1_13': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_stage_bs_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bs_006', kind: 'pick'),
  ]),
  'stage_w1_14': StageQuestionSet([
    StageQuestionRef(questionId: 'blank_bs_001', kind: 'blank'),
    StageQuestionRef(questionId: 'pick_bs_007', kind: 'pick'),
  ]),
  'stage_w1_15': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_bs_005', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bs_004', kind: 'pick'),
  ]),
  'stage_w1_16': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_008', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_bs_002', kind: 'pick'),
  ]),
  'stage_w1_17': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_tp_004', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_hash_005', kind: 'pick'),
  ]),
  'stage_w1_18': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_mix_001', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_arr_006', kind: 'pick'),
  ]),
  'stage_w1_19': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_tp_006', kind: 'pick'),
    StageQuestionRef(questionId: 'pick_tp_007', kind: 'pick'),
  ]),
  'stage_w1_20': StageQuestionSet([
    StageQuestionRef(questionId: 'pick_arr_009', kind: 'pick'),
    StageQuestionRef(questionId: 'blank_bs_002', kind: 'blank'),
  ]),
};

bool hasWorld1StageContent(String stageId) =>
    world1StageQuestions.containsKey(stageId);

StageQuestionSet? world1StageQuestionSet(String stageId) =>
    world1StageQuestions[stageId];
