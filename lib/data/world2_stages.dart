import '../models/world_stage.dart';

const world2Title = 'World 2';
const world2Subtitle = '스택 · BFS';
const world2TotalStages = 5;

const world2MapStages = <WorldStage>[
  WorldStage(
    id: 'stage_w2_01',
    order: 1,
    title: '스택이 뭐죠?',
    tags: ['stack'],
  ),
  WorldStage(
    id: 'stage_w2_02',
    order: 2,
    title: '괄호 검사',
    tags: ['stack'],
  ),
  WorldStage(
    id: 'stage_w2_03',
    order: 3,
    title: '스택 코드',
    tags: ['stack'],
  ),
  WorldStage(
    id: 'stage_w2_04',
    order: 4,
    title: 'BFS 입문',
    tags: ['bfs'],
  ),
  WorldStage(
    id: 'stage_w2_05',
    order: 5,
    title: '격자 최단거리',
    tags: ['bfs'],
  ),
];
