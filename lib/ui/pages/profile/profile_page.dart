import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/formatters.dart';
import '../../../state/auth_view_model.dart';
import '../../components/streamer_avatar.dart';
import '../../components/toast.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';
import '../legal/privacy_policy.dart';
import '../legal/user_agreement.dart';

/// 我的页面（Tab 之一）
///
/// 展示当前登录用户信息，提供修改昵称、协议入口与退出登录。
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
              icon: Icons.edit_outlined,
              title: '修改昵称',
              onTap: () => _openEditNicknamePage(context, vm),
            ),
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

  void _openEditNicknamePage(BuildContext context, AuthViewModel vm) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditNicknameSheet(
        initialNickname: vm.state.currentUser?.nickname ?? '',
        onSubmit: (nickname) => vm.updateNickname(nickname),
      ),
    );
  }
}

/// 修改昵称底部弹层（微信风格）
///
/// - 从底部弹入并占满整个窗口，取消时向下滑出
/// - 顶部 AppBar：左"取消"、中间标题、右"完成"
/// - 中间输入框：预填当前昵称并自动全选
/// - 右下角字数统计 x/20
/// - 输入为空或与原值相同时"完成"禁用；失败在输入框下方红字提示
class _EditNicknameSheet extends StatefulWidget {
  const _EditNicknameSheet({
    required this.initialNickname,
    required this.onSubmit,
  });

  final String initialNickname;
  final Future<({bool success, String? message})> Function(String) onSubmit;

  @override
  State<_EditNicknameSheet> createState() => _EditNicknameSheetState();
}

class _EditNicknameSheetState extends State<_EditNicknameSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNickname);
    _focusNode = FocusNode();
    // 进入后自动全选，方便覆盖修改
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialNickname.length,
    );
    // 延迟请求焦点，等 sheet 滑入动画结束后再弹键盘，
    // 否则键盘上移会盖住 sheet 的滑入动画
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final trimmed = _controller.text.trim();
    return trimmed.isNotEmpty && trimmed != widget.initialNickname.trim();
  }

  Future<void> _submit() async {
    final res = await widget.onSubmit(_controller.text);
    if (!mounted) return;
    if (res.success) {
      showToast(context, '昵称已更新');
      Navigator.of(context).pop();
    } else {
      setState(() => _error = res.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final updating = context.watch<AuthViewModel>().state.updating;
    final count = _controller.text.runes.length;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: TextButton(
          onPressed: updating ? null : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.manualHint),
          child: const Text('取消'),
        ),
        title: const Text('修改昵称'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: (updating || !_canSubmit) ? null : _submit,
            style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
            child: updating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('完成'),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 20,
                enabled: !updating,
                decoration: InputDecoration(
                  hintText: '请输入昵称',
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.smR,
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) {
                  setState(() => _error = null);
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (_error != null)
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: AppTextScale.footer,
                          color: AppColors.error,
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  Text(
                    '$count/20',
                    style: const TextStyle(
                      fontSize: AppTextScale.footer,
                      color: AppColors.footer,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
