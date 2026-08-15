import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/http/api_client.dart';
import '../../core/result.dart';
import '../../domain/entities/streamer.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../models/api_response.dart';
import '../models/streamer.dart';

/// 基于 HTTP 的订阅仓库实现
///
/// 通过 [ApiClient] 调用后端，把响应 DTO 映射为领域实体。
/// 切换为其他数据源时，实现 [SubscriptionRepository] 即可。
class RestSubscriptionRepository implements SubscriptionRepository {
  // ignore: prefer_initializing_formals
  RestSubscriptionRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<Streamer>> subscribeById(String streamerId) async {
    return guardAsync(() async {
      final json =
          await _client.post(ApiConfig.streamerSubscribePath(streamerId));
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => StreamerDto.fromJson(raw as Map<String, dynamic>).toDomain(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<int>> wish(String douyinId) async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.streamersWishPath, body: {
        'douyin_id': douyinId,
      });
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as Map<String, dynamic>)['want_count'] as int,
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<List<Streamer>>> list() async {
    return guardAsync(() async {
      final json = await _client.get(ApiConfig.streamersPath);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as List<dynamic>)
            .map((e) =>
                StreamerDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<List<Streamer>>> listPopular({int limit = 20}) async {
    return guardAsync(() async {
      final json = await _client.get(
        '${ApiConfig.streamersPopularPath}?limit=$limit',
      );
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as List<dynamic>)
            .map((e) =>
                StreamerDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<void>> unsubscribe(String streamerId) async {
    return guardAsync(() async {
      final json = await _client.delete(ApiConfig.streamerPath(streamerId));
      final apiRes = ApiResponse.fromJson(json, (_) => null);
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
    });
  }

  @override
  Future<Result<CheckLiveResult>> checkLive(String streamerId) async {
    return guardAsync(() async {
      final json =
          await _client.post(ApiConfig.streamerCheckLivePath(streamerId));
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => CheckLiveDto.fromJson(raw as Map<String, dynamic>).toDomain(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<List<LiveNotify>>> poll() async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.streamersPollPath);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => ((raw as Map<String, dynamic>)['notifies'] as List<dynamic>)
            .map((e) =>
                LiveNotifyDto.fromJson(e as Map<String, dynamic>).toDomain())
            .toList(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }
}
