import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 验证码输入框
///
/// 通过 [controller] 与外部状态同步，[onChanged] 触发上层刷新。
/// 右侧 [suffix] 通常放发送验证码按钮。
class CodeField extends StatelessWidget {
  const CodeField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.suffix,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '请输入验证码',
        counterText: '',
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: suffix,
        ),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
