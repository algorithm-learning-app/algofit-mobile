import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/world1_stages.dart';
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
    if (worldId != 1) {
      return _UnsupportedWorld(worldId: worldId);
    }

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final nodes = repo.progress.world1Nodes;
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
                          clearedCount: nodes
                              .where((n) => n == WorldNodeState.cleared)
                              .length,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 96),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final stage = world1MapStages[index];
                            final state = worldStageNodeState(
                              stageOrder: stage.order,
                              progressNodes: nodes,
                            );
                            final alignRight = index.isOdd;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index < world1MapStages.length - 1
                                    ? 8
                                    : 0,
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
                          childCount: world1MapStages.length,
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
  const _WorldMapHeader({required this.clearedCount});

  final int clearedCount;

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
                '$clearedCount / $world1TotalStages',
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
        Text(
          world1Title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        const Text(
          world1Subtitle,
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 12),
        Text(
          '맵에는 ${world1MapStages.length}개 스테이지 · 전체 $world1TotalStages개',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.muted.withValues(alpha: 0.85),
          ),
        ),
      ],
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
