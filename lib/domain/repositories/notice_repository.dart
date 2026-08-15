import '../../core/result.dart';
import '../entities/notice.dart';

/// 开播通知仓库抽象
///
/// data 层提供实现（如 RestNoticeRepository）；
/// 测试时可注入 mock 实现，业务层与 UI 层不依赖具体实现。
abstract class NoticeRepository {
  /// 分页查询通知列表（page 从 1 开始）
  Future<Result<NoticePage>> list({required int page, required int pageSize});

  /// 查询当前用户未读数（冷启动校准红点）
  Future<Result<int>> unreadCount();

  /// 标记单条通知为已读
  Future<Result<void>> markRead(String noticeId);

  /// 标记全部通知为已读，返回受影响条数
  Future<Result<int>> markAllRead();

  /// 删除单条通知
  Future<Result<void>> delete(String noticeId);
}
