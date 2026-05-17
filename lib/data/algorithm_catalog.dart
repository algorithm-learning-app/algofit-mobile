/// Algorithm 모드 6종 (MVP Must)
class AlgorithmEntry {
  const AlgorithmEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.patternTag,
  });

  final String id;
  final String title;
  final String subtitle;
  final String icon;
  final String patternTag;
}

const algorithmCatalog = <AlgorithmEntry>[
  AlgorithmEntry(
    id: 'array',
    title: '배열',
    subtitle: '순회·인덱스',
    icon: '📊',
    patternTag: 'array',
  ),
  AlgorithmEntry(
    id: 'two_pointer',
    title: '투 포인터',
    subtitle: '정렬·양끝·윈도우',
    icon: '↔️',
    patternTag: 'two_pointer',
  ),
  AlgorithmEntry(
    id: 'hash',
    title: '해시',
    subtitle: '빈도·complement',
    icon: '🗂️',
    patternTag: 'hash',
  ),
  AlgorithmEntry(
    id: 'binary_search',
    title: '이분 탐색',
    subtitle: '정렬·경계',
    icon: '🔍',
    patternTag: 'binary_search',
  ),
  AlgorithmEntry(
    id: 'stack',
    title: '스택',
    subtitle: 'LIFO·괄호',
    icon: '📚',
    patternTag: 'stack',
  ),
  AlgorithmEntry(
    id: 'bfs',
    title: 'BFS',
    subtitle: '격자·최단거리',
    icon: '🌊',
    patternTag: 'bfs',
  ),
];

AlgorithmEntry? algorithmById(String id) {
  for (final entry in algorithmCatalog) {
    if (entry.id == id) return entry;
  }
  return null;
}
