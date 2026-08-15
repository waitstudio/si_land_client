import '../entities/notice.dart';

/// 通知领域服务抽象
///
/// 封装通知编排逻辑（校验、调用仓库、结果转换）。
/// UI / ViewModel 通过此抽象调用，便于替换实现或测试。
abstract class NoticeService {
  /// 分页查询通知列表
  Future<({bool success, NoticePage? page, String? message})> list({
    required int page,
    required int pageSize,
  });

  /// 查询当前用户未读数（冷启动校准红点）
  Future<({bool success, int count, String? message})> unreadCount();

  /// 标记单条已读
  Future<({bool success, String? message})> markRead(String noticeId);

  /// 标记全部已读，返回受影响条数
  Future<({bool success, int affected, String? message})> markAllRead();

  /// 删除单条通知
  Future<({bool success, String? message})> delete(String noticeId);
}
