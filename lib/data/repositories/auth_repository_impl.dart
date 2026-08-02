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
/// 切换为其他数据源（如本地缓存、GraphQL）时，实现 [AuthRepository] 即可。
class RestAuthRepository implements AuthRepository {
  // ignore: prefer_initializing_formals
  RestAuthRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<int>> sendSmsCode(String phone) async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.sendSmsPath, body: {
        'phone': phone,
      });
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
      });
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => LoginResultDto.fromJson(raw as Map<String, dynamic>),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      final dto = apiRes.data!;
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
}
