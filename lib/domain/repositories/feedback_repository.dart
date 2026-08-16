import '../../core/result.dart';

/// 问题反馈仓库抽象
///
/// data 层提供实现（如 RestFeedbackRepository）；
/// 测试时可注入 mock 实现，业务层与 UI 层不依赖具体实现。
abstract class FeedbackRepository {
  /// 提交问题反馈（BUG / 功能建议），成功返回反馈 ID
  Future<Result<String>> submit(String content);
}
