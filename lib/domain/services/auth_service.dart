import '../entities/auth.dart';
import '../entities/user.dart';

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

  /// 通过本地 token 恢复会话（/auth/me），成功返回当前用户
  Future<({bool success, User? user, String? message})> restoreSession();

  /// 修改昵称，成功返回更新后的用户
  Future<({bool success, User? user, String? message})> updateNickname(
      String nickname);

  /// 退出登录，清除本地 token
  Future<void> logout();
}
