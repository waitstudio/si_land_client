import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 圆形 loading 指示器
///
/// 复用位置：订阅页加载、添加订阅弹框加载、启动恢复 splash。
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: AppColors.goldDark,
        strokeWidth: 3,
      ),
    );
  }
}
