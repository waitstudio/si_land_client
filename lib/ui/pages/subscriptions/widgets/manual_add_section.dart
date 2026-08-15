import 'package:flutter/material.dart';

import '../../../../core/utils/douyin_id_validator.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_scale.dart';

/// 手动输入抖音号订阅区块
///
/// 兜底入口：用户在热门列表没找到喜欢的主播时使用。
/// 校验逻辑与后端 validate_douyin_id 对齐，详见 [DouyinIdValidator]。
class ManualAddSection extends StatefulWidget {
  const ManualAddSection({
    super.key,
    required this.onSubscribe,
    required this.subscribing,
  });

  final Future<void> Function(String douyinId) onSubscribe;

  /// 订阅进行中：禁用按钮，避免重复提交
  final bool subscribing;

  @override
  State<ManualAddSection> createState() => _ManualAddSectionState();
}

class _ManualAddSectionState extends State<ManualAddSection> {
  final _ctrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id = _ctrl.text.trim();
    final err = DouyinIdValidator.validate(id);
    if (err != null || id.isEmpty) {
      setState(() => _error = err ?? '请输入抖音号');
      return;
    }
    setState(() => _error = null);
    await widget.onSubscribe(id);
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _ctrl.text.trim().isNotEmpty && _error == null && !widget.subscribing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '没找到喜欢的主播？',
            style: TextStyle(
              fontSize: AppTextScale.hint,
              fontWeight: FontWeight.w600,
              color: AppColors.manualHint,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  autofocus: false,
                  textInputAction: TextInputAction.done,
                  onChanged: (v) =>
                      setState(() => _error = DouyinIdValidator.validate(v)),
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '输入抖音号',
                    hintStyle: const TextStyle(
                      fontSize: AppTextScale.body,
                      color: AppColors.footer,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.md),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdR,
                      borderSide: const BorderSide(color: AppColors.lightGold),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdR,
                      borderSide: const BorderSide(color: AppColors.lightGold),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.mdR,
                      borderSide: const BorderSide(
                          color: AppColors.goldDark, width: 1.5),
                    ),
                    errorText: _error,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              FilledButton(
                onPressed: canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.sheetDisabledButton,
                  minimumSize: const Size(72, 44),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.mdR),
                ),
                child: const Text('订阅'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
