import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/world1_stages.dart';
import '../../models/world_stage.dart';
import '../../theme/app_colors.dart';

class StagePlaceholderScreen extends StatelessWidget {
  const StagePlaceholderScreen({
    super.key,
    required this.worldId,
    required this.stageId,
  });

  final int worldId;
  final String stageId;

  WorldStage? get _stage {
    for (final stage in world1MapStages) {
      if (stage.id == stageId) return stage;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stage = _stage;
    final title = stage?.title ?? '스테이지';
    final order = stage?.order;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(order != null ? '1-$order' : title),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🎯', style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '스테이지 준비 중',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'World $worldId · Pick 1 문항 플레이스홀더',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  if (stage != null && stage.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final tag in stage.tags)
                          Chip(
                            label: Text(tag),
                            visualDensity: VisualDensity.compact,
                            backgroundColor:
                                AppColors.surface.withValues(alpha: 0.8),
                            side: BorderSide(
                              color: AppColors.muted.withValues(alpha: 0.35),
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.pop(),
                    child: const Text('맵으로 돌아가기'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
