import 'package:flutter/material.dart';

/// 登录按钮（含 loading 状态）
class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    required this.canLogin,
    required this.loading,
    required this.onPressed,
  });

  final bool canLogin;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (canLogin && !loading) ? onPressed : null,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Text('进入矽澜'),
    );
  }
}
