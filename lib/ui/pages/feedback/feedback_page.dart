import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/result.dart';
import '../../../domain/repositories/feedback_repository.dart';
import '../../components/toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';

/// 问题反馈页面
///
/// - 多行输入框收集 BUG / 功能建议，最多 500 字（右下角字数统计）
/// - 输入为空时"提交"禁用；提交中显示 loading 并防重复点击
/// - 提交成功弹窗提示，点击"好的"自动返回上一页；失败 toast 提示
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  late final TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      !_submitting && _controller.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);

    final repo = context.read<FeedbackRepository>();
    final result = await repo.submit(_controller.text.trim());
    if (!mounted) return;

    setState(() => _submitting = false);

    switch (result) {
      case Success():
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('提交成功'),
            content: const Text('感谢你的反馈，我们会尽快跟进处理'),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                ),
                child: const Text('好的'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pop();
      case Failure(:final error):
        showToast(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = _controller.text.runes.length;
    return Scaffold(
      appBar: AppBar(title: const Text('问题反馈')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_submitting,
                  maxLines: null,
                  expands: true,
                  maxLength: AppConstants.feedbackMaxLength,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: '请描述功能建议、遇到的问题，可说明使用场景与期望效果',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.fieldFill,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.smR,
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  const Spacer(),
                  Text(
                    '$count/${AppConstants.feedbackMaxLength}',
                    style: const TextStyle(
                      fontSize: AppTextScale.footer,
                      color: AppColors.footer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _canSubmit ? _submit : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  disabledBackgroundColor: AppColors.fieldFill,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('提交'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
