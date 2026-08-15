import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../state/auth_view_model.dart';
import '../../components/toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';
import 'widgets/agreement.dart';
import 'widgets/code_field.dart';
import 'widgets/login_button.dart';
import 'widgets/login_header.dart';
import 'widgets/phone_field.dart';
import 'widgets/send_code_button.dart';

/// 手机号 + 验证码登录页
///
/// 仅负责 UI 组装与事件转发，业务逻辑由 [AuthViewModel] 处理。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final state = vm.state;

    // 控制器与状态同步：ViewModel 是 source of truth
    if (_phoneCtrl.text != state.phone) _phoneCtrl.text = state.phone;
    if (_codeCtrl.text != state.code) _codeCtrl.text = state.code;

    // 错误 / 成功提示监听
    _listenState(context, vm);

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const LoginHeader(),
                        PhoneField(
                          controller: _phoneCtrl,
                          onChanged: vm.updatePhone,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CodeField(
                          controller: _codeCtrl,
                          onChanged: vm.updateCode,
                          suffix: SendCodeButton(
                            countdown: state.countdown,
                            sending: state.sending,
                            canSend: state.isPhoneValid,
                            onPressed: vm.sendCode,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
                        LoginButton(
                          canLogin: state.canLogin,
                          loading: state.loading,
                          onPressed: vm.login,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Agreement(
                          agreed: state.agreed,
                          onToggle: () => vm.toggleAgreement(),
                        ),
                        const Spacer(),
                        const _Footer(),
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _listenState(BuildContext context, AuthViewModel vm) {
    // 用 didChangeDependencies 周期 + 微任务延迟监听，避免在 build 中触发对话框重建
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final s = vm.state;
      if (s.error != null) {
        showToast(context, s.error!);
        vm.clearError();
        return;
      }
      if (s.loggedInUser != null) {
        showToast(context, '登录成功，欢迎${s.loggedInUser!.nickname}');
        vm.clearLoggedInUser();
        // 跳转由 _SplashGate 监听 currentUser 变化自动完成
      }
    });
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '登录即代表你愿意接受我们的服务条款',
        style: TextStyle(
            fontSize: AppTextScale.footer, color: AppColors.footer),
      ),
    );
  }
}
