import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/badges.dart';
import '../../services/notification_service.dart';
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
                      '알림',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ReminderCard(repo: repo),
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

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({required this.repo});

  final ProgressRepository repo;

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _onToggle(BuildContext context, bool enabled) async {
    final notifications = NotificationService.instance;
    if (enabled) {
      final granted = await notifications.requestPermission();
      if (!granted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 권한이 필요해요')),
        );
        return;
      }
      final progress = repo.progress;
      await repo.setDailyReminder(
        enabled: true,
        hour: progress.reminderHour,
        minute: progress.reminderMinute,
      );
      await notifications.scheduleDailyReminder(
        hour: progress.reminderHour,
        minute: progress.reminderMinute,
      );
    } else {
      await repo.setDailyReminder(enabled: false);
      await notifications.cancelDailyReminder();
    }
  }

  Future<void> _onChangeTime(BuildContext context) async {
    final progress = repo.progress;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: progress.reminderHour,
        minute: progress.reminderMinute,
      ),
    );
    if (picked == null) return;
    await repo.setDailyReminder(
      enabled: true,
      hour: picked.hour,
      minute: picked.minute,
    );
    await NotificationService.instance.scheduleDailyReminder(
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = repo.progress;
    final enabled = progress.dailyReminderEnabled;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: const Text(
                '매일 학습 리마인드',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                '매일 정해진 시간에 챌린지 알림을 받아요.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              value: enabled,
              onChanged: (value) => _onToggle(context, value),
            ),
            if (enabled)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  '알림 시간',
                  style: TextStyle(fontSize: 14, color: AppColors.muted),
                ),
                trailing: Text(
                  _formatTime(progress.reminderHour, progress.reminderMinute),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                onTap: () => _onChangeTime(context),
              ),
            if (enabled)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '기기 절전 상태에 따라 알림이 정시보다 다소 늦을 수 있어요.',
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
          ],
        ),
      ),
    );
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
