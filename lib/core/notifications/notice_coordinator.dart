import 'package:flutter/material.dart';

import '../../core/config.dart';
import '../../state/notice_view_model.dart';
import '../../state/unread_badge.dart';
import '../../ui/pages/messages/messages_page.dart';
import '../../ui/services/local_notifier.dart';
import '../../ui/services/notice_banner.dart';

/// 协调实时通知的副作用，避免 ViewModel 与根 Widget 混入导航和弹窗逻辑。
class NoticeCoordinator {
  final NoticeBannerController _banner = NoticeBannerController();
  final List<String> _shownIds = <String>[];

  void handleNotice(
    Map<String, dynamic> data, {
    required UnreadBadge badge,
    required NoticeViewModel noticeViewModel,
    required bool appResumed,
  }) {
    final id = data['id'] as String?;
    if (id == null || id.isEmpty || _shownIds.contains(id)) return;
    _shownIds.add(id);
    if (_shownIds.length > AppConstants.noticeDedupCacheSize) {
      _shownIds.removeRange(0, _shownIds.length - AppConstants.noticeDedupCacheSize);
    }

    badge.increment();
    if (noticeViewModel.state.currentPage == 0) {
      noticeViewModel.load();
    } else if (!noticeViewModel.state.refreshing) {
      noticeViewModel.refresh();
    }

    if (!appResumed) return;
    final overlay = LocalNotifier.instance.navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    _banner.show(
      overlay: overlay,
      nickname: data['streamer_nickname'] as String? ?? '',
      avatar: data['avatar'] as String? ?? '',
      body: data['body'] as String? ?? '',
      onTap: _goToMessages,
    );
  }

  void clear() {
    _shownIds.clear();
    _banner.dispose();
  }

  void _goToMessages() {
    final navigator = LocalNotifier.instance.navigatorKey.currentState;
    if (navigator == null) return;
    navigator.popUntil((route) => route.isFirst);
    navigator.push(MaterialPageRoute(builder: (_) => const MessagesPage()));
  }

  void dispose() => _banner.dispose();
}
