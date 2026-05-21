import 'package:flutter/material.dart';

import '../models/daily_question.dart';
import '../theme/app_colors.dart';

typedef BlankChoiceTap = void Function(String blankId, String choice);

/// Blank 문항 — 빈칸 ID별로 선택지를 묶어 표시합니다.
class BlankChoicesSection extends StatelessWidget {
  const BlankChoicesSection({
    super.key,
    required this.blanks,
    required this.selections,
    required this.onSelect,
    required this.choiceBuilder,
  });

  final List<BlankSlot> blanks;
  final Map<String, String> selections;
  final BlankChoiceTap onSelect;
  final Widget Function({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  })
  choiceBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < blanks.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _BlankSlotHeader(blankId: blanks[i].id),
          const SizedBox(height: 8),
          for (final choice in blanks[i].choices)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: choiceBuilder(
                label: choice,
                selected: selections[blanks[i].id] == choice,
                onTap: () => onSelect(blanks[i].id, choice),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _BlankSlotHeader extends StatelessWidget {
  const _BlankSlotHeader({required this.blankId});

  final String blankId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
          child: Text(
            blankId,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '빈칸 선택',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}
