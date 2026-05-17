import '../models/world_stage.dart';

const world1Title = 'World 1';
const world1Subtitle = '배열 · 투 포인터 · 해시 · 이분 탐색';
const world1TotalStages = 20;

/// MVP 맵에 표시할 스테이지 (커리큘럼 1-1 ~ 1-7 요약)
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
];
