import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../state/auth_view_model.dart';
import '../../components/streamer_avatar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';
import '../legal/privacy_policy.dart';
import '../legal/user_agreement.dart';

/// 我的页面（Tab 之一）
///
/// 展示当前登录用户信息，提供协议入口与退出登录。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewModel>().state.currentUser;
    final vm = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.xxxl),
            Center(
              child: StreamerAvatar(
                avatar: user?.avatar ?? '',
                nickname: user?.nickname ?? '?',
                radius: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                user?.nickname ?? '未登录',
                style: const TextStyle(
                  fontSize: AppTextScale.headlineLg,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                user != null ? Formatters.maskPhone(user.phone) : '',
                style: const TextStyle(
                    fontSize: AppTextScale.hint, color: AppColors.subInk),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const _Divider(),
            _MenuItem(
              icon: Icons.description_outlined,
              title: '用户协议',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UserAgreementPage()),
              ),
            ),
            _MenuItem(
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
            ),
            const _Divider(),
            _MenuItem(
              icon: Icons.logout,
              title: '退出登录',
              color: AppColors.live,
              onTap: () => _confirmLogout(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthViewModel vm) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              vm.logout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.live,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.ink,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(fontSize: AppTextScale.bodyLg, color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.chevron, size: 22),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Divider(height: 1, color: AppColors.profileDivider),
    );
  }
}
