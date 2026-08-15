import '../../core/auth/auth_storage.dart';
import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/http/api_client.dart';
import '../../core/result.dart';
import '../../domain/entities/auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/api_response.dart';
import '../models/sms.dart';
import '../models/user.dart';

/// 基于 HTTP 的认证仓库实现
///
/// 通过 [ApiClient] 调用后端，把响应 DTO 映射为领域实体。
/// 登录成功后通过 [AuthStorage] 持久化 token，下次启动可通过 [fetchMe] 恢复会话。
class RestAuthRepository implements AuthRepository {
  RestAuthRepository({
    required ApiClient client,
    required AuthStorage authStorage,
  })  : _client = client,
        _authStorage = authStorage;

  final ApiClient _client;
  final AuthStorage _authStorage;

  @override
  Future<Result<int>> sendSmsCode(String phone) async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.sendSmsPath, body: {
        'phone': phone,
      }, auth: false);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => SendSmsDto.fromJson(raw as Map<String, dynamic>),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!.expireIn;
    });
  }

  @override
  Future<Result<LoginResult>> login({
    required String phone,
    required String code,
  }) async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.loginPath, body: {
        'phone': phone,
        'code': code,
      }, auth: false);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => LoginResultDto.fromJson(raw as Map<String, dynamic>),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      final dto = apiRes.data!;
      // 持久化 token，供后续请求与免登录使用
      await _authStorage.save(dto.token, dto.expiresAt);
      return LoginResult(
        token: AuthToken(
          token: dto.token,
          tokenType: dto.tokenType,
          expiresAt: dto.expiresAt,
        ),
        user: User(
          userId: dto.user.userId,
          phone: dto.user.phone,
          nickname: dto.user.nickname,
          avatar: dto.user.avatar,
        ),
      );
    });
  }

  @override
  Future<Result<User>> fetchMe() async {
    return guardAsync(() async {
      final json = await _client.get(ApiConfig.authMePath);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => UserDto.fromJson(raw as Map<String, dynamic>),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      final dto = apiRes.data!;
      return User(
        userId: dto.userId,
        phone: dto.phone,
        nickname: dto.nickname,
        avatar: dto.avatar,
      );
    });
  }

  @override
  Future<Result<User>> updateNickname(String nickname) async {
    return guardAsync(() async {
      final json = await _client.put(ApiConfig.authNicknamePath, body: {
        'nickname': nickname,
      });
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => UserDto.fromJson(raw as Map<String, dynamic>),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      final dto = apiRes.data!;
      return User(
        userId: dto.userId,
        phone: dto.phone,
        nickname: dto.nickname,
        avatar: dto.avatar,
      );
    });
  }

  /// 清除本地 token（退出登录）
  @override
  Future<void> clearToken() => _authStorage.clear();
}
