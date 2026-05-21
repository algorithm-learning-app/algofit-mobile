import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/badges.dart';
import '../../models/guest_progress.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/code_language_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _languagePromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowLanguagePrompt(),
    );
  }

  Future<void> _maybeShowLanguagePrompt() async {
    if (_languagePromptShown || !mounted) return;
    if (!widget.repo.progress.needsCodeLanguagePrompt) return;
    _languagePromptShown = true;
    await showCodeLanguageBottomSheet(
      context,
      initialId: widget.repo.effectiveCodeLanguage,
      onConfirm: widget.repo.setPreferredCodeLanguage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repo,
      builder: (context, _) {
        final progress = widget.repo.progress;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    _HomeHeader(progress: progress),
                    const SizedBox(height: 16),
                    _DailyCard(repo: widget.repo, progress: progress),
                    const SizedBox(height: 16),
                    _BadgesSection(progress: progress),
                    const SizedBox(height: 16),
                    const _PcBonusCard(),
                    const SizedBox(height: 16),
                    _WorldPreview(nodes: progress.world1Nodes),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AlgofitBottomNavBar(),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.progress});

  final GuestProgress progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: '스트릭 ${progress.streakCount}일',
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.streak.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 4),
                Text(
                  '${progress.streakCount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.streak,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lv.${progress.level}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.xp,
                    ),
                  ),
                  Text(
                    '${progress.xp} / ${progress.xpToNextLevel} XP',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Semantics(
                label: '경험치',
                value: '${progress.xp} / ${progress.xpToNextLevel}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.xpPercent,
                    minHeight: 8,
                    backgroundColor: AppColors.muted.withValues(alpha: 0.25),
                    color: AppColors.xp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.repo, required this.progress});

  final ProgressRepository repo;
  final GuestProgress progress;

  void _onDailyTap(BuildContext context) {
    if (progress.todayDailyCompleted) {
      context.push('/daily/complete');
      return;
    }
    if (repo.dailySession == null && progress.dailyProgress == 0) {
      repo.startDailySession();
    }
    final step = repo.dailyResumeStep();
    context.push('/daily/$step');
  }

  @override
  Widget build(BuildContext context) {
    final completedToday = progress.todayDailyCompleted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 챌린지',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pick ${progress.dailyPickCount} · Blank ${progress.dailyBlankCount}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/mascot/algofit-mascot-neutral.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(progress.dailyTotal, (index) {
                final done = index < progress.dailyProgress;
                final current = index == progress.dailyProgress;
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < progress.dailyTotal - 1 ? 8 : 0,
                  ),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || current
                          ? AppColors.primary
                          : AppColors.muted.withValues(alpha: 0.35),
                      boxShadow: current
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 0,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.dailyProgress}/${progress.dailyTotal}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              '5문제 완료 시 스트릭 +1 (만점이면 보너스)',
              style: TextStyle(fontSize: 13, color: AppColors.streak),
            ),
            if (completedToday) ...[
              const SizedBox(height: 8),
              const Text(
                '오늘 챌린지를 완료했어요. 내일 다시 도전해 보세요!',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _onDailyTap(context),
              child: Text(progress.dailyCtaLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgesSection extends StatelessWidget {
  const _BadgesSection({required this.progress});

  final GuestProgress progress;

  @override
  Widget build(BuildContext context) {
    final unlocked = progress.unlockedBadgeIds.toSet();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '뱃지',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              '${unlocked.length} / ${kBadges.length} 획득',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final badge in kBadges)
                  Semantics(
                    label: unlocked.contains(badge.id)
                        ? '${badge.title} 획득'
                        : '${badge.title} 미획득',
                    child: Tooltip(
                      message: badge.description,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: unlocked.contains(badge.id)
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.muted.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: unlocked.contains(badge.id)
                                ? AppColors.primary.withValues(alpha: 0.4)
                                : AppColors.muted.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          unlocked.contains(badge.id) ? badge.emoji : '○',
                          style: TextStyle(
                            fontSize: unlocked.contains(badge.id) ? 22 : 16,
                            color: unlocked.contains(badge.id)
                                ? null
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PcBonusCard extends StatelessWidget {
  const _PcBonusCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pcAccent.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.pcAccent.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.pcAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                '보너스',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PC에서 추가 XP',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '스트릭 조건과 무관 · 선택 참여',
                    style: TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.pcAccent,
            ),
          ],
        ),
      ),
    );
  }
}

class _WorldPreview extends StatelessWidget {
  const _WorldPreview({required this.nodes});

  final List<WorldNodeState> nodes;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/world/1'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'World 1',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/world/1'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '전체 보기',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 24,
                    right: 24,
                    child: Container(
                      height: 2,
                      color: AppColors.muted.withValues(alpha: 0.3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var i = 0; i < nodes.length && i < 5; i++)
                        _WorldNode(index: i + 1, state: nodes[i]),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorldNode extends StatelessWidget {
  const _WorldNode({required this.index, required this.state});

  final int index;
  final WorldNodeState state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      WorldNodeState.locked => '스테이지 $index 잠금',
      WorldNodeState.cleared => '스테이지 $index 완료',
      WorldNodeState.current => '스테이지 $index 진행 중',
    };

    Color bg;
    Color border;
    Color text;
    double opacity = 1;

    switch (state) {
      case WorldNodeState.cleared:
        bg = AppColors.primary.withValues(alpha: 0.2);
        border = AppColors.primary;
        text = AppColors.primary;
      case WorldNodeState.current:
        bg = AppColors.primary;
        border = AppColors.primary;
        text = AppColors.onPrimary;
      case WorldNodeState.locked:
        bg = AppColors.bg;
        border = AppColors.muted.withValues(alpha: 0.4);
        text = AppColors.muted;
        opacity = 0.6;
    }

    return Semantics(
      label: label,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: border, width: 2),
            boxShadow: state == WorldNodeState.current
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ),
      ),
    );
  }
}
