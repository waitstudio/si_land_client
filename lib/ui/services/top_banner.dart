import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_scale.dart';

/// 应用内顶部 banner
///
/// 由 [TopBannerController] 注入到 Navigator overlay，从顶部滑入，
/// [AppConstants.bannerDismissSeconds] 秒后自动移除。点击可立即关闭。
class TopBanner extends StatefulWidget {
  const TopBanner({
    super.key,
    required this.message,
    required this.onTap,
  });

  final String message;
  final VoidCallback onTap;

  @override
  State<TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<TopBanner>
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.live,
                  borderRadius: AppRadius.mdR,
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.bannerShadow,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.live_tv, color: Colors.white, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTextScale.hint,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.close, color: Colors.white70, size: 16),
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

/// Banner 控制器：管理 OverlayEntry 的插入与自动移除
class TopBannerController {
  OverlayEntry? _currentEntry;
  Timer? _dismissTimer;

  /// 当前是否正在显示（用于测试与外部判断）
  bool get isShowing => _currentEntry != null;

  /// 在指定 overlay 上展示一条 banner，超时自动移除
  void show(OverlayState overlay, String message) {
    _dismissTimer?.cancel();
    _currentEntry?.remove();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => TopBanner(
        message: message,
        onTap: _dismiss,
      ),
    );
    _currentEntry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(
      const Duration(seconds: AppConstants.bannerDismissSeconds),
      _dismiss,
    );
  }

  void _dismiss() {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }

  void dispose() {
    _dismissTimer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
