import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_scale.dart';

/// 开播状态标签
///
/// 复用位置：订阅卡片（compact=false）、热门列表项（compact=true）。
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, required this.live, this.compact = false});

  final bool live;

  /// compact=true 用于列表项行内紧凑展示（更小内边距）
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = live ? AppColors.live : AppColors.footer;
    final text = live ? '直播中' : '未开播';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.xs - 1 : AppSpacing.xs + 1,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.xsR,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTextScale.caption,
          color: Colors.white,
        ),
      ),
    );
  }
}
