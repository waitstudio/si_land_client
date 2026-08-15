import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_text_scale.dart';
import '../../legal/privacy_policy.dart';
import '../../legal/user_agreement.dart';

/// 用户协议勾选区
///
/// 点击《用户协议》《隐私政策》跳转对应详情页，点击其余文本切换勾选状态。
class Agreement extends StatefulWidget {
  const Agreement({
    super.key,
    required this.agreed,
    required this.onToggle,
  });

  final bool agreed;
  final VoidCallback onToggle;

  @override
  State<Agreement> createState() => _AgreementState();
}

class _AgreementState extends State<Agreement> {
  late final TapGestureRecognizer _toggleRecognizer;
  late final TapGestureRecognizer _agreementRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _toggleRecognizer = TapGestureRecognizer()..onTap = widget.onToggle;
    _agreementRecognizer = TapGestureRecognizer()
      ..onTap = _openUserAgreement;
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = _openPrivacyPolicy;
  }

  @override
  void didUpdateWidget(covariant Agreement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onToggle != widget.onToggle) {
      _toggleRecognizer.onTap = widget.onToggle;
    }
  }

  @override
  void dispose() {
    _toggleRecognizer.dispose();
    _agreementRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openUserAgreement() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserAgreementPage()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const linkStyle = TextStyle(color: AppColors.goldDark);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: widget.agreed,
            onChanged: (_) => widget.onToggle(),
            shape: const CircleBorder(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                    fontSize: AppTextScale.footer, color: AppColors.subInk),
                children: [
                  TextSpan(
                    text: '我已阅读并同意 ',
                    recognizer: _toggleRecognizer,
                  ),
                  TextSpan(
                    text: '《用户协议》',
                    style: linkStyle,
                    recognizer: _agreementRecognizer,
                  ),
                  TextSpan(text: ' 与 ', recognizer: _toggleRecognizer),
                  TextSpan(
                    text: '《隐私政策》',
                    style: linkStyle,
                    recognizer: _privacyRecognizer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
