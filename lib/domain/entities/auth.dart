import 'user.dart';

/// 登录结果领域实体
class AuthToken {
  final String token;
  final String tokenType;
  final int expiresAt;

  const AuthToken({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
  });
}

/// 登录结果：token + 用户
class LoginResult {
  final AuthToken token;
  final User user;

  const LoginResult({required this.token, required this.user});
}
