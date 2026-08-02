import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/config.dart';
import '../domain/entities/user.dart';
import '../domain/services/auth_service.dart';

/// 认证页面状态
@immutable
class AuthState {
  const AuthState({
    this.phone = '',
    this.code = '',
    this.agreed = false,
    this.sending = false,
    this.loading = false,
    this.countdown = 0,
    this.error,
    this.loggedInUser,
  });

  final String phone;
  final String code;
  final bool agreed;

  /// 发送验证码中
  final bool sending;

  /// 登录中
  final bool loading;

  /// 倒计时剩余秒数
  final int countdown;

  /// 最近一次错误信息（null 表示无）
  final String? error;

  /// 登录成功的用户（非 null 表示已登录）
  final User? loggedInUser;

  /// 派生：手机号是否合法
  bool get isPhoneValid => RegExp(r'^1[3-9]\d{9}$').hasMatch(phone);

  /// 派生：验证码是否合法
  bool get isCodeValid => code.length >= 4;

  /// 派生：是否可登录
  bool get canLogin =>
      isPhoneValid && isCodeValid && agreed && !loading;

  /// 派生：是否可发送验证码
  bool get canSendCode => !sending && countdown == 0 && isPhoneValid;

  AuthState copyWith({
    String? phone,
    String? code,
    bool? agreed,
    bool? sending,
    bool? loading,
    int? countdown,
    String? error,
    User? loggedInUser,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      code: code ?? this.code,
      agreed: agreed ?? this.agreed,
      sending: sending ?? this.sending,
      loading: loading ?? this.loading,
      countdown: countdown ?? this.countdown,
      error: clearError ? null : (error ?? this.error),
      loggedInUser: clearUser ? null : (loggedInUser ?? this.loggedInUser),
    );
  }
}

/// 认证 ViewModel
///
/// 持有 [AuthState]，通过 [AuthService] 编排业务，UI 通过 Provider 订阅。
/// UI 不直接接触 service / repository，只调用本类的方法。
class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._service);

  final AuthService _service;
  Timer? _timer;

  AuthState _state = const AuthState();
  AuthState get state => _state;

  void _emit(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  void updatePhone(String v) =>
      _emit(_state.copyWith(phone: v, clearError: true));

  void updateCode(String v) =>
      _emit(_state.copyWith(code: v, clearError: true));

  void toggleAgreement({bool? value}) =>
      _emit(_state.copyWith(agreed: value ?? !_state.agreed));

  /// 发送验证码
  Future<void> sendCode() async {
    if (!_state.canSendCode) return;

    _emit(_state.copyWith(sending: true, clearError: true));
    final res = await _service.sendCode(_state.phone);
    if (!hasListeners) return;

    if (res.success) {
      _startCountdown();
      _emit(_state.copyWith(
        sending: false,
        error: '验证码已发送，有效期 ${res.expireIn} 秒',
      ));
    } else {
      _emit(_state.copyWith(sending: false, error: res.message));
    }
  }

  /// 登录
  Future<void> login() async {
    if (!_state.canLogin) return;

    _emit(_state.copyWith(loading: true, clearError: true));
    final res = await _service.login(
      phone: _state.phone,
      code: _state.code,
    );
    if (!hasListeners) return;

    if (res.success && res.result != null) {
      _emit(_state.copyWith(
        loading: false,
        loggedInUser: res.result!.user,
        error: null,
      ));
    } else {
      _emit(_state.copyWith(loading: false, error: res.message));
    }
  }

  void _startCountdown() {
    _timer?.cancel();
    _emit(_state.copyWith(countdown: ApiConfig.resendCooldown));
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!hasListeners) {
        t.cancel();
        return;
      }
      final next = _state.countdown - 1;
      if (next <= 0) {
        t.cancel();
        _emit(_state.copyWith(countdown: 0));
      } else {
        _emit(_state.copyWith(countdown: next));
      }
    });
  }

  /// 消费错误信息（UI 展示后清除）
  void clearError() => _emit(_state.copyWith(clearError: true));

  /// 消费登录成功用户（UI 展示后清除，避免重复提示）
  void clearLoggedInUser() => _emit(_state.copyWith(clearUser: true));

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
