import '../../domain/entities/auth.dart';

/// 认证领域服务抽象
///
/// 封装登录编排逻辑（校验、调用仓库、结果转换）。
/// UI / ViewModel 通过此抽象调用，便于替换实现或测试。
abstract class AuthService {
  /// 发送验证码，成功返回有效期（秒）
  Future<({bool success, int? expireIn, String? message})> sendCode(String phone);

  /// 验证码登录
  Future<({bool success, LoginResult? result, String? message})> login({
    required String phone,
    required String code,
  });
}
