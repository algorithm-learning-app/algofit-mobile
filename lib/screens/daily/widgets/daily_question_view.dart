import 'package:flutter/material.dart';

import '../../../models/daily_question.dart';
import '../../../services/daily_service.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/blank_choices_section.dart';
import '../../../widgets/blank_code_view.dart';

class DailyQuestionView extends StatefulWidget {
  const DailyQuestionView({
    super.key,
    required this.question,
    required this.onSubmit,
  });

  final DailyQuestion question;
  final void Function(bool isCorrect) onSubmit;

  @override
  State<DailyQuestionView> createState() => _DailyQuestionViewState();
}

class _DailyQuestionViewState extends State<DailyQuestionView> {
  String? _pickChoice;
  final Map<String, String> _blankSelections = {};

  bool get _canSubmit {
    final q = widget.question;
    if (q is PickQuestion) return _pickChoice != null;
    if (q is BlankQuestion) {
      return q.blanks.every((b) => _blankSelections.containsKey(b.id));
    }
    return false;
  }

  void _handleSubmit() {
    final q = widget.question;
    if (!_canSubmit) return;
    if (q is PickQuestion) {
      widget.onSubmit(checkPickAnswer(q, _pickChoice!));
    } else if (q is BlankQuestion) {
      widget.onSubmit(checkBlankAnswer(q, _blankSelections));
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final isPick = q is PickQuestion;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            isPick ? 'Pick' : 'Blank',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          q.stem,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        if (q is PickQuestion) ..._buildPickChoices(q),
        if (q is BlankQuestion) ..._buildBlank(q),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _canSubmit ? _handleSubmit : null,
          child: const Text('확인'),
        ),
      ],
    );
  }

  List<Widget> _buildPickChoices(PickQuestion q) {
    return [
      for (final choice in q.choices)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _ChoiceButton(
            label: choice.label,
            selected: _pickChoice == choice.id,
            onTap: () => setState(() => _pickChoice = choice.id),
          ),
        ),
    ];
  }

  List<Widget> _buildBlank(BlankQuestion q) {
    return [
      BlankCodeView(
        codeTemplate: q.codeTemplate,
        selections: _blankSelections,
      ),
      const SizedBox(height: 12),
      BlankChoicesSection(
        blanks: q.blanks,
        selections: _blankSelections,
        onSelect: (blankId, choice) =>
            setState(() => _blankSelections[blankId] = choice),
        choiceBuilder: ({
          required label,
          required selected,
          required onTap,
        }) =>
            _ChoiceButton(
          label: label,
          selected: selected,
          onTap: onTap,
        ),
      ),
    ];
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.2)
          : AppColors.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.muted.withValues(alpha: 0.35),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.primary : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
