import '../../core/config.dart';
import '../../core/errors.dart';
import '../../core/http/api_client.dart';
import '../../core/result.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../models/api_response.dart';

/// 基于 HTTP 的问题反馈仓库实现
class RestFeedbackRepository implements FeedbackRepository {
  // ignore: prefer_initializing_formals
  RestFeedbackRepository({required ApiClient client}) : _client = client;

  final ApiClient _client;

  @override
  Future<Result<String>> submit(String content) {
    return guardAsync(() async {
      final json = await _client.post(
        ApiConfig.feedbackPath,
        body: {'content': content},
      );
      final apiRes = ApiResponse.fromJson(
        json,
        (raw) => (raw as Map<String, dynamic>)['id'] as String? ?? '',
      );
      if (!apiRes.isSuccess) {
        throw ApiError(code: apiRes.code, message: apiRes.msg);
      }
      return apiRes.data!;
    });
  }
}
