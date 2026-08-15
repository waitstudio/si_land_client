import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../components/streamer_avatar.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_scale.dart';

/// WS 实时开播通知弹窗（顶部滑入卡片）
///
/// 展示：头像 + 主播昵称 + 通知文案，点击跳转消息页，
/// [AppConstants.noticeBannerDismissSeconds] 秒后自动滑出。
/// 防重复弹窗由 [NoticeBannerController] 互斥保证（同时最多一条，
/// 新通知到达时替换旧弹窗），id 级去重由调用方（WsGate）负责。
class NoticeBanner extends StatefulWidget {
  const NoticeBanner({
    super.key,
    required this.nickname,
    required this.avatar,
    required this.body,
    required this.onTap,
  });

  final String nickname;
  final String avatar;
  final String body;
  final VoidCallback onTap;

  @override
  State<NoticeBanner> createState() => _NoticeBannerState();
}

class _NoticeBannerState extends State<NoticeBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.bannerAnimDurationMs),
    );
    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          bottom: false,
          child: SlideTransition(
            position: _offset,
            child: GestureDetector(
              onTap: widget.onTap,
              child: Container(
                margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.lgR,
                  border: Border.all(color: AppColors.lightGold, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.bannerShadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    StreamerAvatar(
                      avatar: widget.avatar,
                      nickname: widget.nickname,
                      radius: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.ink,
                              fontSize: AppTextScale.body,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.legalBody,
                              fontSize: AppTextScale.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.chevron_right,
                        color: AppColors.chevron, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 通知弹窗控制器：互斥展示 + 自动移除
///
/// 同一时刻最多一条弹窗（防重复弹窗堆叠），
/// 新通知到达时旧弹窗立即被替换。
class NoticeBannerController {
  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  /// 当前是否正在展示
  bool get isShowing => _currentEntry != null;

  /// 在指定 overlay 上展示一条通知弹窗，超时自动移除
  void show({
    required OverlayState overlay,
    required String nickname,
    required String avatar,
    required String body,
    required VoidCallback onTap,
  }) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => NoticeBanner(
        nickname: nickname,
        avatar: avatar,
        body: body,
        onTap: () {
          _dismiss();
          onTap();
        },
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(
      const Duration(seconds: AppConstants.noticeBannerDismissSeconds),
      _dismiss,
    );
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }

  void dispose() {
    _dismiss();
  }
}
