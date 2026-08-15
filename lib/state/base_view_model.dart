import 'package:flutter/foundation.dart';

/// ViewModel 基类
///
/// 当前仅提供 [hasListeners] 守卫与通知包装。
/// 子类各自持有不可变 state（如 AuthState / SubscriptionState），
/// 通过 [emit] 触发 UI 重建。
///
/// 不在此处持有 loading/error，因为它们属于具体 state 的字段，
/// 与 immutable state 模式协调时通过 copyWith 维护更自然。
abstract class BaseViewModel extends ChangeNotifier {
  /// 安全发射：在异步操作完成后调用，避免 widget 已销毁时通知
  @protected
  void emit() {
    if (!hasListeners) return;
    notifyListeners();
  }
}
