import 'package:flutter/foundation.dart';

import '../core/utils/phone_validator.dart';
import '../domain/entities/user.dart';

/// 认证页面状态
@immutable
class AuthState {
  const AuthState({
    this.phone = '',
    this.code = '',
    this.agreed = false,
    this.sending = false,
    this.loading = false,
    this.updating = false,
    this.countdown = 0,
    this.error,
    this.loggedInUser,
    this.currentUser,
    this.restoring = false,
    this.restored = false,
  });

  final String phone;
  final String code;
  final bool agreed;

  /// 发送验证码中
  final bool sending;

  /// 登录中
  final bool loading;

  /// 修改昵称中
  final bool updating;

  /// 倒计时剩余秒数
  final int countdown;

  /// 最近一次错误信息（null 表示无）
  final String? error;

  /// 登录成功的用户（一次性信号，UI 消费后清除）
  final User? loggedInUser;

  /// 当前登录用户（持久，登录后保留，供"我的"页等读取）
  final User? currentUser;

  /// 启动时恢复会话中
  final bool restoring;

  /// 启动恢复完成（无论成功失败），用于 UI 决定首屏路由
  final bool restored;

  /// 派生：手机号是否合法
  bool get isPhoneValid => isValidPhone(phone);

  /// 派生：验证码是否合法
  bool get isCodeValid => code.length >= 4;

  /// 派生：是否可登录
  bool get canLogin => isPhoneValid && isCodeValid && agreed && !loading;

  /// 派生：是否可发送验证码
  bool get canSendCode => !sending && countdown == 0 && isPhoneValid;

  AuthState copyWith({
    String? phone,
    String? code,
    bool? agreed,
    bool? sending,
    bool? loading,
    bool? updating,
    int? countdown,
    String? error,
    User? loggedInUser,
    User? currentUser,
    bool? restoring,
    bool? restored,
    bool clearError = false,
    bool clearUser = false,
    bool clearCurrentUser = false,
  }) {
    return AuthState(
      phone: phone ?? this.phone,
      code: code ?? this.code,
      agreed: agreed ?? this.agreed,
      sending: sending ?? this.sending,
      loading: loading ?? this.loading,
      updating: updating ?? this.updating,
      countdown: countdown ?? this.countdown,
      error: clearError ? null : (error ?? this.error),
      loggedInUser: clearUser ? null : (loggedInUser ?? this.loggedInUser),
      currentUser: clearCurrentUser
          ? null
          : (currentUser ?? this.currentUser),
      restoring: restoring ?? this.restoring,
      restored: restored ?? this.restored,
    );
  }
}
