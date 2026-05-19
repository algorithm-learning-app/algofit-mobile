class BadgeDefinition {
  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
  });

  final String id;
  final String title;
  final String description;
  final String emoji;
}

/// MVP badges (docs/04-gamification.md).
const kBadges = <BadgeDefinition>[
  BadgeDefinition(
    id: 'first_daily',
    title: '첫 챌린지',
    description: '일일 챌린지를 처음 완료했어요',
    emoji: '🌟',
  ),
  BadgeDefinition(
    id: 'streak_3',
    title: '3일 연속',
    description: '스트릭 3일 달성',
    emoji: '🔥',
  ),
  BadgeDefinition(
    id: 'streak_7',
    title: '7일 연속',
    description: '스트릭 7일 달성',
    emoji: '💫',
  ),
  BadgeDefinition(
    id: 'first_stage',
    title: '첫 스테이지',
    description: '월드 스테이지를 처음 클리어했어요',
    emoji: '🗺️',
  ),
  BadgeDefinition(
    id: 'world2_unlock',
    title: '월드 2 개방',
    description: '월드 2를 열었어요',
    emoji: '🔓',
  ),
  BadgeDefinition(
    id: 'world1_clear',
    title: '월드 1 정복',
    description: '월드 1 스테이지를 모두 클리어했어요',
    emoji: '🏆',
  ),
  BadgeDefinition(
    id: 'correct_10',
    title: '정답 10문항',
    description: '누적 10문항을 맞혔어요',
    emoji: '✅',
  ),
  BadgeDefinition(
    id: 'perfect_daily',
    title: '완벽한 하루',
    description: '일일 챌린지 5문항 전부 정답',
    emoji: '💯',
  ),
];

BadgeDefinition? badgeById(String id) {
  for (final b in kBadges) {
    if (b.id == id) return b;
  }
  return null;
}
