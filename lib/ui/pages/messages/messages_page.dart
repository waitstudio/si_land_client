import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../state/notice_state.dart';
import '../../../state/notice_view_model.dart';
import '../../../domain/entities/notice.dart';
import '../../components/empty_state.dart';
import '../../components/loading_indicator.dart';
import '../../components/streamer_avatar.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_scale.dart';

/// 消息页（Tab 之一）
///
/// 展示开播通知列表：
/// - 顶部未读总数 + 一键全部已读
/// - 下拉刷新 / 上拉分页
/// - 点击条目标记已读（红点消失）
/// - 左滑展开"删除"按钮，点击删除该通知
/// - 左侧展示主播头像（未读时头像右上角带红点徽标）
/// - 无消息时展示空状态
class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 首次进入拉取第 1 页
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NoticeViewModel>().load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<NoticeViewModel>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoticeViewModel>();
    final s = vm.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('消息'),
        actions: [
          if (s.unreadCount > 0)
            TextButton(
              onPressed: vm.markAllRead,
              child: const Text(
                '全部已读',
                style: TextStyle(
                  fontSize: AppTextScale.body,
                  color: AppColors.goldDark,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.goldDark,
          onRefresh: vm.refresh,
          child: _buildBody(vm, s),
        ),
      ),
    );
  }

  Widget _buildBody(NoticeViewModel vm, NoticeState s) {
    if (s.loading) {
      return const Center(child: LoadingIndicator());
    }
    if (s.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          EmptyState(
            icon: Icons.notifications_none,
            title: '暂无消息',
            subtitle: '主播开播后会在这里通知你',
          ),
        ],
      );
    }

    // 列表项总数 = 通知数 + 顶部未读横幅(1) + 底部加载更多(1)
    final extraCount = 1 + 1;
    return ListView.builder(
      controller: _scrollController,
      itemCount: s.notices.length + extraCount,
      itemBuilder: (context, i) {
        if (i == 0) {
          return _UnreadBanner(count: s.unreadCount);
        }
        if (i == s.notices.length + 1) {
          return _LoadMoreFooter(
            loading: s.loadingMore,
            hasMore: s.hasMore,
          );
        }
        final notice = s.notices[i - 1];
        return Slidable(
          key: ValueKey(notice.id),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            extentRatio: 0.25,
            children: [
              CustomSlidableAction(
                onPressed: (_) => vm.delete(notice.id),
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
                  color: AppColors.error,
                  alignment: Alignment.center,
                  child: const Text(
                    '删除',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: AppTextScale.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          child: _NoticeTile(
            notice: notice,
            onTap: () => vm.markRead(notice.id),
          ),
        );
      },
    );
  }
}

/// 顶部未读条数横幅
class _UnreadBanner extends StatelessWidget {
  const _UnreadBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pageHorizontal,
        vertical: AppSpacing.sm,
      ),
      color: const Color(0xFFFFF8EE),
      child: Row(
        children: [
          const Icon(
            Icons.mark_chat_unread,
            size: 14,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$count 条未读消息',
            style: const TextStyle(
              fontSize: AppTextScale.footer,
              color: AppColors.goldDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// 单条通知条目
///
/// 时间为相对时间（刚刚/N分钟前），通过定时器周期刷新保持实时。
class _NoticeTile extends StatefulWidget {
  const _NoticeTile({
    required this.notice,
    required this.onTap,
  });

  final LiveNotice notice;
  final VoidCallback onTap;

  @override
  State<_NoticeTile> createState() => _NoticeTileState();
}

class _NoticeTileState extends State<_NoticeTile> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 30s 一刷：覆盖"刚刚→N分钟前"及更粗粒度的变化
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notice = widget.notice;
    final unread = !notice.read;
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageHorizontal,
          vertical: AppSpacing.lg,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧主播头像（未读时右上角带红点徽标）
            _AvatarWithBadge(
              avatar: notice.avatar,
              nickname: notice.streamerNickname,
              unread: unread,
            ),
            const SizedBox(width: AppSpacing.md),
            // 中间内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.streamerNickname.isEmpty
                        ? notice.title
                        : notice.streamerNickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTextScale.title,
                      fontWeight:
                          unread ? FontWeight.w700 : FontWeight.w500,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    notice.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTextScale.body,
                      color: unread ? AppColors.ink : AppColors.manualHint,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formatTime(notice.createdAt),
                    style: const TextStyle(
                      fontSize: AppTextScale.footer,
                      color: AppColors.footer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 带未读红点徽标的头像
///
/// 头像右上角叠加红点，用于一眼区分未读消息，避免占用独立列宽。
class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({
    required this.avatar,
    required this.nickname,
    required this.unread,
  });

  final String avatar;
  final String nickname;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    const radius = 20.0;
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          StreamerAvatar(
            avatar: avatar,
            nickname: nickname,
            radius: radius,
          ),
          if (unread)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.live,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 底部加载更多指示器
class _LoadMoreFooter extends StatelessWidget {
  const _LoadMoreFooter({required this.loading, required this.hasMore});

  final bool loading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (!loading && !hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            '没有更多了',
            style: TextStyle(
              fontSize: AppTextScale.footer,
              color: AppColors.footer,
            ),
          ),
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(child: LoadingIndicator(size: 24)),
    );
  }
}

/// 相对时间格式化（秒级时间戳）
String _formatTime(int ts) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final diff = now - ts;
  if (diff < 60) return '刚刚';
  if (diff < 3600) return '${diff ~/ 60}分钟前';
  if (diff < 86400) return '${diff ~/ 3600}小时前';
  if (diff < 604800) return '${diff ~/ 86400}天前';
  final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
}
