import 'package:flutter/material.dart';

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
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F1F1F),
          ),
        ),
        SizedBox(height: 8),
        Text(
          '使用手机号验证码即可继续',
          style: TextStyle(fontSize: 14, color: Color(0xFF9A9A9A)),
        ),
        SizedBox(height: 32),
      ],
    );
  }
}
