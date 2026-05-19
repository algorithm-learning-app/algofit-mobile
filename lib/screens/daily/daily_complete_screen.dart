import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/daily_service.dart';
import '../../services/progress_repository.dart';
import '../../theme/app_colors.dart';

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
                  Text(
                    allCorrect ? '🔥' : '🌙',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 56),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    allCorrect ? '오늘 챌린지 클리어!' : '챌린지 완료',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    allCorrect
                        ? '$dailyTotal문제 전부 정답! 스트릭이 1일 늘었어요.'
                        : '오늘 스트릭은 내일 다시 도전해 보세요. 5문제 전부 정답이면 스트릭이 올라가요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.muted,
                      height: 1.45,
                    ),
                  ),
                  if (allCorrect) ...[
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
                  ],
                  const SizedBox(height: 16),
                  Text(
                    '이번 세션 +$xpEarned XP',
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
