import 'package:flutter/material.dart';

import '../models/guest_progress.dart';
import '../theme/app_colors.dart';

class WorldMapNode extends StatelessWidget {
  const WorldMapNode({
    super.key,
    required this.order,
    required this.title,
    required this.state,
    required this.onTap,
  });

  final int order;
  final String title;
  final WorldNodeState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) {
      WorldNodeState.locked => '스테이지 $order 잠금',
      WorldNodeState.cleared => '스테이지 $order 완료',
      WorldNodeState.current => '스테이지 $order 진행 중',
    };

    final colors = _colorsFor(state);
    final enabled = state != WorldNodeState.locked;

    return Semantics(
      label: label,
      button: enabled,
      child: Opacity(
        opacity: state == WorldNodeState.locked ? 0.55 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.background,
                    border: Border.all(color: colors.border, width: 2.5),
                    boxShadow: state == WorldNodeState.current
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  alignment: Alignment.center,
                  child: state == WorldNodeState.cleared
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 26,
                        )
                      : Text(
                          '$order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: colors.text,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 96,
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: state == WorldNodeState.locked
                          ? AppColors.muted
                          : Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _NodeColors _colorsFor(WorldNodeState state) {
    return switch (state) {
      WorldNodeState.cleared => _NodeColors(
          background: AppColors.primary.withValues(alpha: 0.2),
          border: AppColors.primary,
          text: AppColors.primary,
        ),
      WorldNodeState.current => const _NodeColors(
          background: AppColors.primary,
          border: AppColors.primary,
          text: AppColors.onPrimary,
        ),
      WorldNodeState.locked => _NodeColors(
          background: AppColors.bg,
          border: AppColors.muted.withValues(alpha: 0.4),
          text: AppColors.muted,
        ),
    };
  }
}

class _NodeColors {
  const _NodeColors({
    required this.background,
    required this.border,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color text;
}
