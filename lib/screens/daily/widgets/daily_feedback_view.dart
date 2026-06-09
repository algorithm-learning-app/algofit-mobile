import 'package:flutter/material.dart';

import '../../../services/daily_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/mascot.dart';
import '../../../widgets/stem_text.dart';

class DailyFeedbackView extends StatelessWidget {
  const DailyFeedbackView({
    super.key,
    required this.isCorrect,
    required this.message,
    required this.onContinue,
    this.explanation,
  });

  final bool isCorrect;
  final String message;
  final VoidCallback onContinue;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Mascot(
            isCorrect ? MascotMood.happy : MascotMood.sad,
            size: 104,
            animate: true,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isCorrect ? '정답!' : '오답',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppTheme.displayFontFamily,
            fontSize: 24,
            color: isCorrect ? AppColors.primary : const Color(0xFFF87171),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, height: 1.45),
        ),
        if (explanation != null && explanation!.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          StemText(
            text: explanation!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
        ],
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
        FilledButton(onPressed: onContinue, child: const Text('다음')),
      ],
    );
  }
}
