import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 主播 / 用户头像
///
/// - 有 avatar URL → 加载网络图片，加载失败回退首字母
/// - 无 avatar URL → 金色圆 + 昵称首字母（兜底 "?"）
///
/// 复用位置：订阅卡片、热门列表项、我的页。
class StreamerAvatar extends StatelessWidget {
  const StreamerAvatar({
    super.key,
    required this.avatar,
    required this.nickname,
    this.radius = 28,
  });

  final String avatar;
  final String nickname;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatar.isNotEmpty;
    final letter = (nickname.isNotEmpty ? nickname.characters.first : '?')
        .toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.goldDark,
      backgroundImage: hasAvatar ? NetworkImage(avatar) : null,
      child: hasAvatar
          ? null
          : Text(
              letter,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * _letterScale,
              ),
            ),
    );
  }
}

/// 首字母字号按头像半径缩放，让大小头像视觉比例一致
const double _letterScale = 0.72;
