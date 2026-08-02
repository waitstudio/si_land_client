import 'package:flutter/material.dart';

/// 全局主题：白底金色配色
///
/// 集中管理颜色与组件样式，便于后续扩展深色主题或多品牌主题。
class AppColors {
  AppColors._();

  static const gold = Color(0xFFC9A86A);
  static const goldDark = Color(0xFF8C7547);
  static const ink = Color(0xFF1F1F1F);
  static const subInk = Color(0xFF9A9A9A);
  static const divider = Color(0xFFE8E8E8);
  static const fieldFill = Color(0xFFF7F7F7);
  static const disabled = Color(0xFFC0C0C0);
  static const disabledButton = Color(0xFFE0D4BD);
  static const error = Color(0xFFCB3B3B);
  static const footer = Color(0xFFB5B5B5);
}

/// 构建应用主题
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: subInk, fontSize: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: goldDark,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
