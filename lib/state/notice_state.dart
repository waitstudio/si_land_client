import 'package:flutter/foundation.dart';

import '../domain/entities/notice.dart';

/// 消息页状态
@immutable
class NoticeState {
  const NoticeState({
    this.notices = const [],
    this.total = 0,
    this.unreadCount = 0,
    this.currentPage = 0,
    this.loading = false,
    this.refreshing = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.error,
  });

  /// 已加载的通知列表（按时间倒序，跨页累积）
  final List<LiveNotice> notices;

  /// 后端通知总数（用于判断是否还有更多）
  final int total;

  /// 未读消息数
  final int unreadCount;

  /// 当前已加载页码（0 表示尚未加载）
  final int currentPage;

  /// 首次加载中
  final bool loading;

  /// 下拉刷新中
  final bool refreshing;

  /// 上拉加载更多中
  final bool loadingMore;

  /// 是否还有更多数据
  final bool hasMore;

  final String? error;

  /// 是否处于空状态（已加载且无数据）
  bool get isEmpty => !loading && notices.isEmpty;

  NoticeState copyWith({
    List<LiveNotice>? notices,
    int? total,
    int? unreadCount,
    int? currentPage,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return NoticeState(
      notices: notices ?? this.notices,
      total: total ?? this.total,
      unreadCount: unreadCount ?? this.unreadCount,
      currentPage: currentPage ?? this.currentPage,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
