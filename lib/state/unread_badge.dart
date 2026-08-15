import 'package:flutter/foundation.dart';

/// 全局未读数状态（消息 Tab 红点唯一数据源）
///
/// 更新来源（最终一致，以服务端权威值校准）：
/// - WS `notice` 消息：本地 +1（乐观增量）
/// - WS `unread` 消息 / 冷启动 unread-count 接口：服务端权威值覆盖
/// - 消息页标记已读 / 全部已读 / 删除：本地减量
///
/// 计数容错：所有更新统一 clamp 到非负整数，避免漂移为负。
class UnreadBadge extends ChangeNotifier {
  int _count = 0;
  int get count => _count;

  /// 是否有未读（红点可见性判断）
  bool get hasUnread => _count > 0;

  /// 红点文案：超过 99 显示 99+
  String get badgeLabel => _count > 99 ? '99+' : '$_count';

  /// 以服务端权威值覆盖（WS unread 消息 / unread-count 接口）
  void setCount(int value) {
    final next = value.clamp(0, 1 << 30);
    if (next == _count) return;
    _count = next;
    notifyListeners();
  }

  /// 本地乐观 +1（WS 收到新通知）
  void increment() => setCount(_count + 1);

  /// 本地乐观减量（标记已读/删除成功后），减到 0 为止
  void decrement() {
    if (_count <= 0) return;
    setCount(_count - 1);
  }

  /// 清零（全部已读 / 登出）
  void clear() => setCount(0);
}
