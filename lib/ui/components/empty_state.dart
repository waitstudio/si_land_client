import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_scale.dart';

/// 空态占位
///
/// 复用位置：订阅列表空、发现页占位、消息页占位。
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.lightGold),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppTextScale.body,
              color: AppColors.subInk,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: AppTextScale.footer,
                color: AppColors.footer,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
