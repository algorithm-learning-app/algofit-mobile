import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 문제 지문용 경량 마크다운: `**굵게**`, `` `코드` `` 만 지원.
class StemText extends StatelessWidget {
  const StemText({super.key, required this.text, this.style, this.textAlign});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final base = style ?? DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(style: base, children: _parseSpans(text, base)),
      textAlign: textAlign,
    );
  }

  static List<InlineSpan> _parseSpans(String input, TextStyle base) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*|`([^`]+)`');
    var start = 0;
    for (final match in pattern.allMatches(input)) {
      if (match.start > start) {
        spans.add(TextSpan(text: input.substring(start, match.start)));
      }
      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: base.copyWith(fontWeight: FontWeight.w800),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: base.copyWith(
              fontFamily: 'monospace',
              fontSize: (base.fontSize ?? 14) - 1,
              color: AppColors.primary.withValues(alpha: 0.95),
            ),
          ),
        );
      }
      start = match.end;
    }
    if (start < input.length) {
      spans.add(TextSpan(text: input.substring(start)));
    }
    if (spans.isEmpty) {
      spans.add(TextSpan(text: input));
    }
    return spans;
  }
}
