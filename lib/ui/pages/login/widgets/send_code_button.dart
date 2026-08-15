import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_scale.dart';

/// 发送验证码按钮（带倒计时与状态切换）
///
/// 纯展示组件，所有状态由外部传入。
class SendCodeButton extends StatelessWidget {
  const SendCodeButton({
    super.key,
    required this.countdown,
    required this.sending,
    required this.canSend,
    required this.onPressed,
  });

  final int countdown;
  final bool sending;
  final bool canSend;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool counting = countdown > 0;
    final bool disabled = sending || counting || !canSend;
    final String text = counting
        ? '${countdown}s 后重新获取'
        : (sending ? '发送中...' : '获取验证码');

    return TextButton(
      onPressed: disabled ? null : onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: AppTextScale.body,
          fontWeight: FontWeight.w500,
          color: disabled ? AppColors.disabled : AppColors.goldDark,
        ),
      ),
    );
  }
}
