import '../../core/result.dart';
import '../../core/utils/phone_validator.dart';
import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/services/auth_service.dart';

/// 认证领域服务默认实现
///
/// 编排：参数校验 → 调用仓库 → 结果转换。
/// 不依赖具体仓库实现，便于替换 / 测试。
class AuthServiceImpl implements AuthService {
  AuthServiceImpl(this._repo);

  final AuthRepository _repo;

  @override
  Future<({bool success, int? expireIn, String? message})> sendCode(
      String phone) async {
    if (!isValidPhone(phone)) {
      return (success: false, expireIn: null, message: '请输入正确的手机号');
    }
    final result = await _repo.sendSmsCode(phone);
    return switch (result) {
      Success<int>(:final data) => (
          success: true,
          expireIn: data,
          message: null,
        ),
      Failure<int>(:final error) => (
          success: false,
          expireIn: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, LoginResult? result, String? message})> login({
    required String phone,
    required String code,
  }) async {
    if (!isValidPhone(phone)) {
      return (success: false, result: null, message: '请输入正确的手机号');
    }
    if (code.length < 4) {
      return (success: false, result: null, message: '请输入验证码');
    }
    final result = await _repo.login(phone: phone, code: code);
    return switch (result) {
      Success<LoginResult>(:final data) => (
          success: true,
          result: data,
          message: null,
        ),
      Failure<LoginResult>(:final error) => (
          success: false,
          result: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, User? user, String? message})> restoreSession() async {
    final result = await _repo.fetchMe();
    return switch (result) {
      Success<User>(:final data) => (
          success: true,
          user: data,
          message: null,
        ),
      Failure<User>(:final error) => (
          success: false,
          user: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<void> logout() async {
    await _repo.clearToken();
  }
}
