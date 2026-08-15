import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/config.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';

/// 手机号输入框
///
/// 通过 [controller] 与外部状态同步，[onChanged] 触发上层刷新。
/// 不直接持有业务逻辑。
class PhoneField extends StatelessWidget {
  const PhoneField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: AppConstants.phoneMaxLength,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: '请输入手机号',
        counterText: '',
        prefixIcon: Padding(
          padding: EdgeInsets.only(
              left: AppSpacing.md - 2, right: AppSpacing.sm),
          child: Center(
            widthFactor: 1,
            child: Text(
              '+86',
              style: TextStyle(
                color: Colors.black54,
                fontSize: AppTextScale.bodyLg,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}
