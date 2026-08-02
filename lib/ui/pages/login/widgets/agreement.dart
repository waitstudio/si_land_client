import 'package:flutter/material.dart';

/// 用户协议勾选区
class Agreement extends StatelessWidget {
  const Agreement({
    super.key,
    required this.agreed,
    required this.onToggle,
  });

  final bool agreed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: agreed,
            onChanged: (_) => onToggle(),
            shape: const CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: GestureDetector(
            onTap: onToggle,
            child: const Padding(
              padding: EdgeInsets.only(top: 3),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
                  children: [
                    TextSpan(text: '我已阅读并同意 '),
                    TextSpan(
                      text: '《用户协议》',
                      style: TextStyle(color: Color(0xFF8C7547)),
                    ),
                    TextSpan(text: ' 与 '),
                    TextSpan(
                      text: '《隐私政策》',
                      style: TextStyle(color: Color(0xFF8C7547)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
