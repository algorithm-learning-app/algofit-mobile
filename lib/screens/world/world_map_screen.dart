import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/world1_stages.dart';
import '../../data/world2_stages.dart';
import '../../models/guest_progress.dart';
import '../../models/world_stage.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/world_map_node.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({
    super.key,
    required this.repo,
    this.worldId = 1,
  });

  final ProgressRepository repo;
  final int worldId;

  @override
  Widget build(BuildContext context) {
    if (worldId != 1 && worldId != 2) {
      return _UnsupportedWorld(worldId: worldId);
    }

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final progress = repo.progress;
        final isWorld2 = worldId == 2;
        if (isWorld2 && !progress.world2Unlocked) {
          return _WorldLocked(repo: repo);
        }

        final stages = isWorld2 ? world2MapStages : world1MapStages;
        final nodes = isWorld2 ? progress.world2Nodes : progress.world1Nodes;
        final title = isWorld2 ? world2Title : world1Title;
        final subtitle = isWorld2 ? world2Subtitle : world1Subtitle;
        final total = isWorld2 ? world2TotalStages : world1TotalStages;
        final clearedCount =
            nodes.where((n) => n == WorldNodeState.cleared).length;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: _WorldMapHeader(
                          worldId: worldId,
                          title: title,
                          subtitle: subtitle,
                          clearedCount: clearedCount,
                          totalStages: total,
                          mapStageCount: stages.length,
                          world2Unlocked: progress.world2Unlocked,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stage = stages[index];
                            final state = worldStageNodeState(
                              stageOrder: stage.order,
                              progressNodes: nodes,
                            );
                            final alignRight = index.isOdd;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < stages.length - 1 ? 8 : 0,
                              ),
                              child: _MapRow(
                                alignRight: alignRight,
                                showConnector: index > 0,
                                child: WorldMapNode(
                                  order: stage.order,
                                  title: stage.title,
                                  state: state,
                                  onTap: () => context.push(
                                    '/world/$worldId/stage/${stage.id}',
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: stages.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AlgofitBottomNavBar(currentIndex: 1),
        );
      },
    );
  }
}

class _WorldMapHeader extends StatelessWidget {
  const _WorldMapHeader({
    required this.worldId,
    required this.title,
    required this.subtitle,
    required this.clearedCount,
    required this.totalStages,
    required this.mapStageCount,
    required this.world2Unlocked,
  });

  final int worldId;
  final String title;
  final String subtitle;
  final int clearedCount;
  final int totalStages;
  final int mapStageCount;
  final bool world2Unlocked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.canPop()
                  ? context.pop()
                  : context.go('/home'),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.muted,
              tooltip: '뒤로',
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$clearedCount / $totalStages',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _WorldChip(
              label: 'World 1',
              selected: worldId == 1,
              onTap: () => context.go('/world/1'),
            ),
            const SizedBox(width: 8),
            _WorldChip(
              label: 'World 2',
              selected: worldId == 2,
              locked: !world2Unlocked,
              onTap: world2Unlocked
                  ? () => context.go('/world/2')
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Text(
          '맵 $mapStageCount개 스테이지 · 전체 $totalStages개',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.muted.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _WorldChip extends StatelessWidget {
  const _WorldChip({
    required this.label,
    required this.selected,
    this.locked = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(locked ? '$label 🔒' : label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
    );
  }
}

class _MapRow extends StatelessWidget {
  const _MapRow({
    required this.alignRight,
    required this.showConnector,
    required this.child,
  });

  final bool alignRight;
  final bool showConnector;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (showConnector)
          Positioned(
            top: 0,
            bottom: 0,
            left: alignRight ? 72 : null,
            right: alignRight ? null : 72,
            child: Container(
              width: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.muted.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.45),
                    AppColors.muted.withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),
        Align(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(
              left: alignRight ? 48 : 8,
              right: alignRight ? 8 : 48,
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _WorldLocked extends StatelessWidget {
  const _WorldLocked({required this.repo});

  final ProgressRepository repo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('World 2')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'World 1을 $world2UnlockClearedCount스테이지 이상 클리어하면 열려요',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/world/1'),
                child: const Text('World 1으로'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AlgofitBottomNavBar(currentIndex: 1),
    );
  }
}

class _UnsupportedWorld extends StatelessWidget {
  const _UnsupportedWorld({required this.worldId});

  final int worldId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('World $worldId')),
      body: Center(
        child: Text(
          'World $worldId은(는) 준비 중이에요.',
          style: const TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}
