import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_text_scale.dart';

export 'app_colors.dart';
export 'app_radius.dart';
export 'app_spacing.dart';
export 'app_text_scale.dart';

/// 构建应用主题：白底金色配色
ThemeData buildAppTheme() {
  const gold = AppColors.gold;
  const goldDark = AppColors.goldDark;
  const ink = AppColors.ink;
  const subInk = AppColors.subInk;
  const divider = AppColors.divider;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: gold,
      brightness: Brightness.light,
      primary: gold,
      onPrimary: Colors.white,
      secondary: goldDark,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: ink,
      error: AppColors.error,
    ).copyWith(primary: gold, secondary: goldDark),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: ink),
      bodyMedium: TextStyle(color: ink),
      bodySmall: TextStyle(color: subInk),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      hintStyle: const TextStyle(
        color: subInk,
        fontSize: AppTextScale.bodyLg,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.lgR,
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgR,
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.lgR,
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.disabledButton,
        disabledForegroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgR),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: AppTextScale.title,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: goldDark,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        textStyle: const TextStyle(
          fontSize: AppTextScale.body,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
