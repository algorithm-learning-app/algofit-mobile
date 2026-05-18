import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'blank_code_parser.dart';

/// Blank 문항 코드 영역 — `{{b1}}` 플레이스홀더를 칩으로 강조 표시합니다.
class BlankCodeView extends StatelessWidget {
  const BlankCodeView({
    super.key,
    required this.codeTemplate,
    this.selections = const {},
    this.showHint = true,
    this.maxHeight = 200,
  });

  final String codeTemplate;
  final Map<String, String> selections;
  final bool showHint;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    final segments = parseBlankCodeTemplate(codeTemplate);
    final blankIds = segments
        .whereType<BlankCodePlaceholderSegment>()
        .map((s) => s.blankId)
        .toList();

    const codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.5,
      color: Colors.white,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHint && blankIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _hintText(blankIds),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.muted.withValues(alpha: 0.95),
                height: 1.35,
              ),
            ),
          ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText.rich(
                TextSpan(
                  style: codeStyle,
                  children: _buildSpans(segments, selections),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _hintText(List<String> blankIds) {
    if (blankIds.length == 1) {
      return '빈칸 ${blankIds.first}를 아래에서 고르세요';
    }
    return '빈칸 ${blankIds.join(' · ')}를 아래에서 고르세요';
  }

  List<InlineSpan> _buildSpans(
    List<BlankCodeSegment> segments,
    Map<String, String> selections,
  ) {
    return [
      for (final segment in segments)
        if (segment is BlankCodeTextSegment)
          TextSpan(text: segment.text)
        else if (segment is BlankCodePlaceholderSegment)
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            style: const TextStyle(height: 1.5),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
              child: _BlankChip(
                blankId: segment.blankId,
                selectedValue: selections[segment.blankId],
              ),
            ),
          ),
    ];
  }
}

class _BlankChip extends StatelessWidget {
  const _BlankChip({
    required this.blankId,
    this.selectedValue,
  });

  final String blankId;
  final String? selectedValue;

  @override
  Widget build(BuildContext context) {
    final filled = selectedValue != null && selectedValue!.isNotEmpty;
    final accent = filled ? AppColors.xp : AppColors.primary;
    final label = filled ? selectedValue! : blankId;
    final prefix = filled ? '' : '「 ';
    final suffix = filled ? '' : ' 」';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: filled ? 8 : 6,
        vertical: filled ? 3 : 2,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accent.withValues(alpha: filled ? 0.85 : 0.55),
          width: filled ? 1.5 : 1,
        ),
      ),
      child: Text(
        '$prefix$label$suffix',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: filled ? 12 : 11,
          fontWeight: FontWeight.w700,
          color: accent,
          height: 1.2,
        ),
      ),
    );
  }
}
