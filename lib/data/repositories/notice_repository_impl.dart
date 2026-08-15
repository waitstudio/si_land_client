import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/http/api_client.dart';
import '../../core/result.dart';
import '../../domain/entities/notice.dart';
import '../../domain/repositories/notice_repository.dart';
import '../models/api_response.dart';
import '../models/notice.dart';

/// 基于 HTTP 的通知仓库实现
///
/// 通过 [ApiClient] 调用后端，把响应 DTO 映射为领域实体。
class RestNoticeRepository implements NoticeRepository {
  // ignore: prefer_initializing_formals
  RestNoticeRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<NoticePage>> list({
    required int page,
    required int pageSize,
  }) async {
    return guardAsync(() async {
      final json = await _client.get(
        ApiConfig.noticesPagePath(page: page, pageSize: pageSize),
      );
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) =>
            NoticeListDto.fromJson(raw as Map<String, dynamic>).toDomain(),
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<int>> unreadCount() async {
    return guardAsync(() async {
      final json = await _client.get(ApiConfig.noticesUnreadCountPath);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as Map<String, dynamic>)['count'] as int? ?? 0,
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<void>> markRead(String noticeId) async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.noticeReadPath(noticeId));
      final apiRes = ApiResponse.fromJson(json, (_) => null);
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
    });
  }

  @override
  Future<Result<int>> markAllRead() async {
    return guardAsync(() async {
      final json = await _client.post(ApiConfig.noticesReadAllPath);
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as Map<String, dynamic>)['affected'] as int? ?? 0,
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }

  @override
  Future<Result<void>> delete(String noticeId) async {
    return guardAsync(() async {
      final json = await _client.delete(ApiConfig.noticePath(noticeId));
      final apiRes = ApiResponse.fromJson(json, (_) => null);
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
    });
  }
}
