import '../models/world_stage.dart';

const world1Title = 'World 1';
const world1Subtitle = '배열 · 투 포인터 · 해시 · 이분 탐색';
const world1TotalStages = 20;

/// World 1 맵 스테이지 (커리큘럼 1-1 ~ 1-20)
const world1MapStages = <WorldStage>[
  WorldStage(
    id: 'stage_w1_01',
    order: 1,
    title: '배열이 뭐죠?',
    tags: ['array'],
  ),
  WorldStage(
    id: 'stage_w1_02',
    order: 2,
    title: '합구하기 입문',
    tags: ['array'],
  ),
  WorldStage(
    id: 'stage_w1_03',
    order: 3,
    title: '최댓값 찾기',
    tags: ['array'],
  ),
  WorldStage(
    id: 'stage_w1_04',
    order: 4,
    title: '두 수의 합',
    tags: ['array'],
  ),
  WorldStage(
    id: 'stage_w1_05',
    order: 5,
    title: '투 포인터 입문',
    tags: ['two_pointer'],
  ),
  WorldStage(
    id: 'stage_w1_06',
    order: 6,
    title: '투 포인터 코드',
    tags: ['two_pointer'],
  ),
  WorldStage(
    id: 'stage_w1_07',
    order: 7,
    title: '부분 배열 합',
    tags: ['two_pointer'],
  ),
  WorldStage(
    id: 'stage_w1_08',
    order: 8,
    title: '투 포인터 복습',
    tags: ['two_pointer'],
  ),
  WorldStage(
    id: 'stage_w1_09',
    order: 9,
    title: '해시가 필요해요',
    tags: ['hash'],
  ),
  WorldStage(
    id: 'stage_w1_10',
    order: 10,
    title: '두 수의 합 (해시)',
    tags: ['hash'],
  ),
  WorldStage(
    id: 'stage_w1_11',
    order: 11,
    title: '빈도 세기',
    tags: ['hash'],
  ),
  WorldStage(
    id: 'stage_w1_12',
    order: 12,
    title: '해시 복습',
    tags: ['hash'],
  ),
  WorldStage(
    id: 'stage_w1_13',
    order: 13,
    title: '이분 탐색이란',
    tags: ['binary_search'],
  ),
  WorldStage(
    id: 'stage_w1_14',
    order: 14,
    title: '이분 탐색 코드',
    tags: ['binary_search'],
  ),
  WorldStage(
    id: 'stage_w1_15',
    order: 15,
    title: 'lower bound 맛보기',
    tags: ['binary_search'],
  ),
  WorldStage(
    id: 'stage_w1_16',
    order: 16,
    title: '배열 + 이분 조합',
    tags: ['binary_search', 'array'],
  ),
  WorldStage(
    id: 'stage_w1_17',
    order: 17,
    title: 'World 1 중간 보스',
    tags: ['array', 'two_pointer', 'hash'],
  ),
  WorldStage(
    id: 'stage_w1_18',
    order: 18,
    title: '약한 패턴 보충',
    tags: ['hash'],
  ),
  WorldStage(
    id: 'stage_w1_19',
    order: 19,
    title: '속도 훈련',
    tags: ['two_pointer'],
  ),
  WorldStage(
    id: 'stage_w1_20',
    order: 20,
    title: 'World 1 클리어',
    tags: ['array', 'binary_search'],
  ),
];
