import '../models/world_stage.dart';

const world2Title = 'World 2';
const world2Subtitle = '스택 · BFS';
const world2TotalStages = 15;

const world2MapStages = <WorldStage>[
  WorldStage(id: 'stage_w2_01', order: 1, title: '스택이 뭐죠?', tags: ['stack']),
  WorldStage(id: 'stage_w2_02', order: 2, title: '괄호 검사', tags: ['stack']),
  WorldStage(id: 'stage_w2_03', order: 3, title: '스택 코드', tags: ['stack']),
  WorldStage(id: 'stage_w2_04', order: 4, title: 'BFS 입문', tags: ['bfs']),
  WorldStage(id: 'stage_w2_05', order: 5, title: '격자 최단거리', tags: ['bfs']),
  WorldStage(id: 'stage_w2_06', order: 6, title: '스택 연습', tags: ['stack']),
  WorldStage(id: 'stage_w2_07', order: 7, title: '괄호 심화', tags: ['stack']),
  WorldStage(id: 'stage_w2_08', order: 8, title: '큐와 BFS', tags: ['bfs']),
  WorldStage(id: 'stage_w2_09', order: 9, title: 'BFS 연습', tags: ['bfs']),
  WorldStage(id: 'stage_w2_10', order: 10, title: '최단 경로 마스터', tags: ['bfs']),
  WorldStage(id: 'stage_w2_11', order: 11, title: '스택 복습', tags: ['stack']),
  WorldStage(id: 'stage_w2_12', order: 12, title: '스택 심화', tags: ['stack']),
  WorldStage(id: 'stage_w2_13', order: 13, title: 'BFS 거리', tags: ['bfs']),
  WorldStage(id: 'stage_w2_14', order: 14, title: '위상 정렬', tags: ['bfs']),
  WorldStage(
    id: 'stage_w2_15',
    order: 15,
    title: '종합 도전',
    tags: ['stack', 'bfs'],
  ),
];
