import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/daily_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';
import '../../widgets/mascot.dart';

class DailyCompleteScreen extends StatelessWidget {
  const DailyCompleteScreen({
    super.key,
    required this.repo,
    this.allCorrect = false,
    this.xpEarned = 0,
  });

  final ProgressRepository repo;
  final bool allCorrect;
  final int xpEarned;

  @override
  Widget build(BuildContext context) {
    final streak = repo.progress.streakCount;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: Mascot(MascotMood.happy, size: 132, animate: true),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    allCorrect ? '완벽한 하루!' : '오늘도 완료!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    allCorrect
                        ? '$dailyTotal문제 전부 정답! 스트릭 +1, 보너스 +$dailyPerfectBonusXp XP.'
                        : '스트릭이 1일 늘었어요. 꾸준함이 진짜 실력이에요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 6),
                      Text(
                        '$streak일 연속',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.streak,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '이번 세션 +$xpEarned XP${allCorrect ? ' (보너스 포함)' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('홈으로'),
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
