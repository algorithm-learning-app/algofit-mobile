import 'package:flutter/material.dart';

import '../models/code_language.dart';
import '../theme/app_colors.dart';

typedef CodeLanguageChanged = void Function(String languageId);

class CodeLanguagePicker extends StatelessWidget {
  const CodeLanguagePicker({
    super.key,
    required this.selectedId,
    required this.onChanged,
    this.compact = false,
  });

  final String selectedId;
  final CodeLanguageChanged onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = CodeLanguage.normalize(selectedId);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final lang in CodeLanguage.supported)
          FilterChip(
            label: Text(
              lang.label,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: normalized == lang.id
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
            selected: normalized == lang.id,
            showCheckmark: false,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            side: BorderSide(
              color: normalized == lang.id
                  ? AppColors.primary.withValues(alpha: 0.6)
                  : AppColors.muted.withValues(alpha: 0.3),
            ),
            onSelected: (_) => onChanged(lang.id),
          ),
      ],
    );
  }
}

Future<void> showCodeLanguageBottomSheet(
  BuildContext context, {
  required String initialId,
  required CodeLanguageChanged onConfirm,
}) {
  var selected = CodeLanguage.normalize(initialId);
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          8,
          20,
          20 + MediaQuery.paddingOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '코드 언어 선택',
              style: Theme.of(
                ctx,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              '빈칸 채우기 문제의 코드 예시 언어를 골라 주세요. 언제든 프로필에서 바꿀 수 있어요.',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setModalState) {
                return CodeLanguagePicker(
                  selectedId: selected,
                  onChanged: (id) => setModalState(() => selected = id),
                );
              },
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                onConfirm(selected);
                Navigator.of(ctx).pop();
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      );
    },
  );
}
