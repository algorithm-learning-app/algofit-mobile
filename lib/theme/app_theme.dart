import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// 제목용 디스플레이 폰트 패밀리. 임의의 헤딩 [TextStyle]에 직접 적용할 때 사용.
  static const displayFontFamily = 'DoHyeon';

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      surface: AppColors.surface,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      onSurface: Colors.white,
      outline: AppColors.muted,
    );

    // 본문·UI는 Pretendard, 큰 제목(display/headline/title)은 Do Hyeon.
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamily: 'Pretendard',
      scaffoldBackgroundColor: AppColors.bg,
    );

    return base.copyWith(
      textTheme: _withDisplayHeadings(base.textTheme),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  /// display/headline/title 계열에만 디스플레이 폰트를 입힌다(본문은 Pretendard 유지).
  static TextTheme _withDisplayHeadings(TextTheme base) {
    TextStyle? d(TextStyle? s) => s?.copyWith(fontFamily: displayFontFamily);
    return base.copyWith(
      displayLarge: d(base.displayLarge),
      displayMedium: d(base.displayMedium),
      displaySmall: d(base.displaySmall),
      headlineLarge: d(base.headlineLarge),
      headlineMedium: d(base.headlineMedium),
      headlineSmall: d(base.headlineSmall),
      titleLarge: d(base.titleLarge),
    );
  }
}
