import 'dart:async';

import '../core/config.dart';
import '../domain/services/auth_service.dart';
import 'auth_state.dart';
import 'base_view_model.dart';

/// 认证 ViewModel
///
/// 持有 [AuthState]，通过 [AuthService] 编排业务，UI 通过 Provider 订阅。
/// UI 不直接接触 service / repository，只调用本类的方法。
class AuthViewModel extends BaseViewModel {
  AuthViewModel(this._service);

  final AuthService _service;
  Timer? _timer;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  void _set(AuthState newState) {
    _state = newState;
    emit();
  }

  void updatePhone(String v) =>
      _set(_state.copyWith(phone: v, clearError: true));

  void updateCode(String v) =>
      _set(_state.copyWith(code: v, clearError: true));

  void toggleAgreement({bool? value}) =>
      _set(_state.copyWith(agreed: value ?? !_state.agreed));

  /// 启动时尝试恢复登录会话
  ///
  /// 调用 /auth/me：
  /// - 成功（token 有效）→ 设置 currentUser，UI 跳转 MainShell
  /// - 失败（无 token / token 过期 / 网络错误）→ 显示登录页
  Future<void> restoreSession() async {
    _set(_state.copyWith(restoring: true, clearError: true));
    final res = await _service.restoreSession();
    if (res.success && res.user != null) {
      _set(_state.copyWith(
        restoring: false,
        restored: true,
        currentUser: res.user,
        clearError: true,
      ));
    } else {
      _set(_state.copyWith(
        restoring: false,
        restored: true,
        clearCurrentUser: true,
      ));
    }
  }

  /// 发送验证码
  Future<void> sendCode() async {
    if (!_state.canSendCode) return;

    _set(_state.copyWith(sending: true, clearError: true));
    final res = await _service.sendCode(_state.phone);

    if (res.success) {
      _startCountdown();
      _set(_state.copyWith(
        sending: false,
        error: '验证码已发送，有效期 ${res.expireIn} 秒',
      ));
    } else {
      _set(_state.copyWith(sending: false, error: res.message));
    }
  }

  /// 登录
  Future<void> login() async {
    if (!_state.canLogin) return;

    _set(_state.copyWith(loading: true, clearError: true));
    final res = await _service.login(
      phone: _state.phone,
      code: _state.code,
    );

    if (res.success && res.result != null) {
      _set(_state.copyWith(
        loading: false,
        loggedInUser: res.result!.user,
        currentUser: res.result!.user,
        error: null,
      ));
    } else {
      _set(_state.copyWith(loading: false, error: res.message));
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _set(_state.copyWith(countdown: AppConstants.resendCooldown));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!hasListeners) {
        t.cancel();
        return;
      }
      final next = _state.countdown - 1;
      if (next <= 0) {
        t.cancel();
        _set(_state.copyWith(countdown: 0));
      } else {
        _set(_state.copyWith(countdown: next));
      }
    });
  }

  /// 消费错误信息（UI 展示后清除）
  void clearError() => _set(_state.copyWith(clearError: true));

  /// 消费登录成功用户（UI 展示后清除，避免重复提示）
  void clearLoggedInUser() => _set(_state.copyWith(clearUser: true));

  /// 退出登录，清除本地 token 与当前用户
  Future<void> logout() async {
    await _service.logout();
    _set(_state.copyWith(
      clearUser: true,
      clearCurrentUser: true,
      clearError: true,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
