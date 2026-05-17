import 'package:flutter/material.dart';

import '../../../services/daily_service.dart';
import '../../../theme/app_colors.dart';

class DailyFeedbackView extends StatelessWidget {
  const DailyFeedbackView({
    super.key,
    required this.isCorrect,
    required this.message,
    required this.onContinue,
  });

  final bool isCorrect;
  final String message;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          isCorrect ? '✨' : '💔',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(height: 8),
        Text(
          isCorrect ? '정답!' : '오답',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isCorrect ? AppColors.primary : const Color(0xFFF87171),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          '+$dailyXpPerQuestion XP',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.xp,
          ),
        ),
        const Spacer(),
        FilledButton(
          onPressed: onContinue,
          child: const Text('다음'),
        ),
      ],
    );
  }
}
