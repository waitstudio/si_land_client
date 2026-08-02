import '../../core/result.dart';
import '../entities/auth.dart';

/// 认证仓库抽象
///
/// data 层提供实现（如 [RestAuthRepository]）；
/// 测试时可注入 mock 实现，业务层与 UI 层不依赖具体实现。
abstract class AuthRepository {
  /// 发送验证码
  Future<Result<int>> sendSmsCode(String phone);

  /// 验证码登录
  Future<Result<LoginResult>> login({required String phone, required String code});
}
