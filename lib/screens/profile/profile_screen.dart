import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/badges.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/code_language_picker.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.repo});

  final ProgressRepository repo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final progress = repo.progress;
        final unlocked = progress.unlockedBadgeIds.toSet();
        final continueUrl = repo.createPcContinueUrl();

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
                  children: [
                    Text(
                      '내 정보',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 16),
                    _StatRow(
                      label: '게스트 ID',
                      value: progress.guestId,
                      monospace: true,
                      onCopy: () => _copy(context, progress.guestId, '게스트 ID'),
                    ),
                    const SizedBox(height: 12),
                    _StatRow(label: '스트릭', value: '${progress.streakCount}일'),
                    const SizedBox(height: 12),
                    _StatRow(
                      label: '레벨 · XP',
                      value:
                          'Lv.${progress.level} · ${progress.xp} / ${progress.xpToNextLevel} XP',
                    ),
                    const SizedBox(height: 12),
                    _StatRow(label: '하트', value: '${progress.hearts} / 5'),
                    const SizedBox(height: 20),
                    Text(
                      '코드 언어',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '빈칸 채우기 문제의 코드 예시 언어입니다.',
                      style: TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 12),
                    CodeLanguagePicker(
                      selectedId: repo.effectiveCodeLanguage,
                      onChanged: (id) => repo.setPreferredCodeLanguage(id),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '뱃지 ${unlocked.length} / ${kBadges.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final badge in kBadges)
                          Tooltip(
                            message: badge.description,
                            child: Container(
                              width: 48,
                              height: 48,
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
                                  fontSize: unlocked.contains(badge.id)
                                      ? 22
                                      : 16,
                                  color: unlocked.contains(badge.id)
                                      ? null
                                      : AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'PC에서 이어하기',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '아래 링크를 PC 브라우저에 붙여 넣으면 Daily·보너스를 이어할 수 있어요.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SelectableText(
                              continueUrl,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: AppColors.pcAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: () =>
                                  _copy(context, continueUrl, 'PC 이어하기 링크'),
                              icon: const Icon(Icons.link_rounded, size: 18),
                              label: const Text('링크 복사'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const AlgofitBottomNavBar(currentIndex: 4),
        );
      },
    );
  }

  static Future<void> _copy(
    BuildContext context,
    String text,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label 복사됨')));
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.monospace = false,
    this.onCopy,
  });

  final String label;
  final String value;
  final bool monospace;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontFamily: monospace ? 'monospace' : null,
            ),
          ),
        ),
        if (onCopy != null)
          IconButton(
            onPressed: onCopy,
            icon: const Icon(Icons.copy_rounded, size: 20),
            color: AppColors.primary,
            tooltip: '복사',
          ),
      ],
    );
  }
}
