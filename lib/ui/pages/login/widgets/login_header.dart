import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';

/// 登录页标题区
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 64),
        Text(
          '进入硅基星球',
          style: TextStyle(
            fontSize: AppTextScale.display + 2,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: AppSpacing.sm),
        Text(
          '使用手机号验证码即可继续',
          style: TextStyle(
              fontSize: AppTextScale.body, color: AppColors.subInk),
        ),
        SizedBox(height: AppSpacing.xxxl + AppSpacing.xs),
      ],
    );
  }
}
