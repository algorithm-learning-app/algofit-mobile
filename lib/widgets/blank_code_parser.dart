/// `codeTemplate` 내 `{{b1}}` 형태 플레이스홀더를 코드 조각과 빈칸 ID로 분리합니다.
final blankPlaceholderPattern = RegExp(r'\{\{(\w+)\}\}');

sealed class BlankCodeSegment {
  const BlankCodeSegment();
}

final class BlankCodeTextSegment extends BlankCodeSegment {
  const BlankCodeTextSegment(this.text);

  final String text;
}

final class BlankCodePlaceholderSegment extends BlankCodeSegment {
  const BlankCodePlaceholderSegment(this.blankId);

  final String blankId;
}

/// [template]을 순서대로 [BlankCodeTextSegment] / [BlankCodePlaceholderSegment] 목록으로 파싱합니다.
List<BlankCodeSegment> parseBlankCodeTemplate(String template) {
  final segments = <BlankCodeSegment>[];
  var cursor = 0;

  for (final match in blankPlaceholderPattern.allMatches(template)) {
    if (match.start > cursor) {
      segments.add(BlankCodeTextSegment(template.substring(cursor, match.start)));
    }
    segments.add(BlankCodePlaceholderSegment(match.group(1)!));
    cursor = match.end;
  }

  if (cursor < template.length) {
    segments.add(BlankCodeTextSegment(template.substring(cursor)));
  }

  return segments;
}

/// 파싱된 세그먼트에서 빈칸 ID만 순서대로 추출합니다.
List<String> blankIdsFromTemplate(String template) {
  return parseBlankCodeTemplate(template)
      .whereType<BlankCodePlaceholderSegment>()
      .map((s) => s.blankId)
      .toList();
}
