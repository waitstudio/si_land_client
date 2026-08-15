import '../../core/result.dart';
import '../entities/auth.dart';
import '../entities/user.dart';

/// 认证仓库抽象
///
/// data 层提供实现（如 [RestAuthRepository]）；
/// 测试时可注入 mock 实现，业务层与 UI 层不依赖具体实现。
abstract class AuthRepository {
  /// 发送验证码
  Future<Result<int>> sendSmsCode(String phone);

  /// 验证码登录
  Future<Result<LoginResult>> login({required String phone, required String code});

  /// 获取当前登录用户信息（/auth/me）
  Future<Result<User>> fetchMe();

  /// 修改当前登录用户昵称（/auth/nickname）
  Future<Result<User>> updateNickname(String nickname);

  /// 清除本地 token（退出登录）
  Future<void> clearToken();
}
