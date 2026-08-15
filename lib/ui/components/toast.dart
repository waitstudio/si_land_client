import 'package:flutter/material.dart';

import '../../core/config.dart';

/// 显示一条轻提示
///
/// 复用位置：登录页 / 订阅页 / 添加订阅弹框。
/// 默认时长走 [AppConstants.toastDurationSeconds]，与全局保持一致。
void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: AppConstants.toastDurationSeconds),
    ),
  );
}
