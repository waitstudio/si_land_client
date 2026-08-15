import '../core/config.dart';
import '../domain/services/notice_service.dart';
import 'base_view_model.dart';
import 'notice_state.dart';
import 'unread_badge.dart';

/// 消息 ViewModel
///
/// 持有 [NoticeState]，通过 [NoticeService] 编排业务：
/// - 首次加载 / 下拉刷新重置为第 1 页
/// - 上拉加载更多追加下一页
/// - 标记已读 / 全部已读 / 删除均为本地乐观更新，避免重新拉取
/// - 所有未读数变化通过 [UnreadBadge] 同步到全局红点
class NoticeViewModel extends BaseViewModel {
  NoticeViewModel(this._service, [this._badge]);

  final NoticeService _service;
  final UnreadBadge? _badge;

  NoticeState _state = const NoticeState();
  NoticeState get state => _state;

  void _set(NoticeState newState) {
    _state = newState;
    // 未读数变化统一同步全局红点（WS / 消息页操作收敛到同一数据源）
    _badge?.setCount(newState.unreadCount);
    emit();
  }

  /// 首次加载或重置加载（page=1）
  Future<void> load() async {
    _set(_state.copyWith(loading: true, clearError: true));
    final res = await _service.list(page: 1, pageSize: AppConstants.noticePageSize);
    if (res.success && res.page != null) {
      final page = res.page!;
      _set(_state.copyWith(
        notices: page.items,
        total: page.total,
        unreadCount: page.unreadCount,
        currentPage: 1,
        loading: false,
        hasMore: page.items.length < page.total,
      ));
    } else {
      _set(_state.copyWith(loading: false, error: res.message));
    }
  }

  /// 下拉刷新（重新拉第 1 页，保留未读数）
  Future<void> refresh() async {
    _set(_state.copyWith(refreshing: true, clearError: true));
    final res = await _service.list(page: 1, pageSize: AppConstants.noticePageSize);
    if (res.success && res.page != null) {
      final page = res.page!;
      _set(_state.copyWith(
        notices: page.items,
        total: page.total,
        unreadCount: page.unreadCount,
        currentPage: 1,
        refreshing: false,
        hasMore: page.items.length < page.total,
      ));
    } else {
      _set(_state.copyWith(refreshing: false, error: res.message));
    }
  }

  /// 上拉加载更多
  Future<void> loadMore() async {
    if (_state.loadingMore || !_state.hasMore || _state.refreshing) return;
    _set(_state.copyWith(loadingMore: true, clearError: true));
    final next = _state.currentPage + 1;
    final res = await _service.list(page: next, pageSize: AppConstants.noticePageSize);
    if (res.success && res.page != null) {
      final page = res.page!;
      // 去重：避免边界条目重复
      final existing = _state.notices.map((n) => n.id).toSet();
      final merged = [..._state.notices, ...page.items.where((n) => !existing.contains(n.id))];
      _set(_state.copyWith(
        notices: merged,
        total: page.total,
        unreadCount: page.unreadCount,
        currentPage: next,
        loadingMore: false,
        hasMore: merged.length < page.total,
      ));
    } else {
      _set(_state.copyWith(loadingMore: false, error: res.message));
    }
  }

  /// 标记单条已读（本地乐观更新：红点立即消失）
  Future<void> markRead(String noticeId) async {
    // 本地先把该条置为已读，未读数 -1（若原本未读）
    final idx = _state.notices.indexWhere((n) => n.id == noticeId);
    if (idx < 0) return;
    final target = _state.notices[idx];
    if (target.read) return; // 已读则不重复
    final next = [..._state.notices];
    next[idx] = target.copyWith(read: true);
    _set(_state.copyWith(
      notices: next,
      unreadCount: _state.unreadCount > 0 ? _state.unreadCount - 1 : 0,
    ));

    final res = await _service.markRead(noticeId);
    if (!res.success) {
      // 后端失败回滚
      final rolled = [..._state.notices];
      final i = rolled.indexWhere((n) => n.id == noticeId);
      if (i >= 0) rolled[i] = rolled[i].copyWith(read: false);
      _set(_state.copyWith(
        notices: rolled,
        unreadCount: _state.unreadCount + 1,
        error: res.message,
      ));
    }
  }

  /// 一键全部已读
  Future<void> markAllRead() async {
    if (_state.unreadCount == 0) return;
    final prev = _state;
    _set(_state.copyWith(
      notices: _state.notices.map((n) => n.copyWith(read: true)).toList(),
      unreadCount: 0,
    ));
    final res = await _service.markAllRead();
    if (!res.success) {
      _set(prev.copyWith(error: res.message));
    }
  }

  /// 删除单条通知
  Future<void> delete(String noticeId) async {
    final prev = _state;
    final target = _state.notices.where((n) => n.id == noticeId).firstOrNull;
    final next = _state.notices.where((n) => n.id != noticeId).toList();
    _set(_state.copyWith(
      notices: next,
      total: _state.total > 0 ? _state.total - 1 : 0,
      unreadCount:
          (target != null && !target.read && _state.unreadCount > 0)
              ? _state.unreadCount - 1
              : _state.unreadCount,
    ));
    final res = await _service.delete(noticeId);
    if (!res.success) {
      _set(prev.copyWith(error: res.message));
    }
  }

  void clearError() => _set(_state.copyWith(clearError: true));
}
