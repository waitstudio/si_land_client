import 'package:flutter/material.dart';

/// 颜色 token：全量设计系统颜色，禁止在 widget 中内联 Color(0xFF...)
class AppColors {
  AppColors._();

  // === 主色 ===
  static const gold = Color(0xFFC9A86A);
  static const goldDark = Color(0xFF8C7547);

  // === 文字 ===
  static const ink = Color(0xFF1F1F1F);
  static const subInk = Color(0xFF9A9A9A);
  static const footer = Color(0xFFB5B5B5);
  static const manualHint = Color(0xFF6B6B6B);
  static const legalBody = Color(0xFF5A5A5A);

  // === 背景 / 分割线 ===
  static const divider = Color(0xFFE8E8E8);
  static const profileDivider = Color(0xFFEFEFEF);
  static const sheetDivider = Color(0xFFEFE8DC);
  static const fieldFill = Color(0xFFF7F7F7);

  // === 禁用 ===
  static const disabled = Color(0xFFC0C0C0);
  static const disabledButton = Color(0xFFE0D4BD);
  static const sheetDisabledButton = Color(0xFFE4DCC9);
  static const subscribedButton = Color(0xFFF0EDE5);

  // === 强调 / 状态 ===
  static const live = Color(0xFFE53935);
  static const error = Color(0xFFCB3B3B);
  static const bannerShadow = Color(0x33000000);

  // === 装饰 ===
  static const lightGold = Color(0xFFD6CBB3);
  static const chevron = Color(0xFFC8C8C8);
}
