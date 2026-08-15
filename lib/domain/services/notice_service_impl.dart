import '../../core/result.dart';
import '../entities/notice.dart';
import '../repositories/notice_repository.dart';
import 'notice_service.dart';

/// 通知领域服务默认实现
///
/// 编排：调用仓库 → 结果转换。
class NoticeServiceImpl implements NoticeService {
  NoticeServiceImpl(this._repo);

  final NoticeRepository _repo;

  @override
  Future<({bool success, NoticePage? page, String? message})> list({
    required int page,
    required int pageSize,
  }) async {
    final result = await _repo.list(page: page, pageSize: pageSize);
    return switch (result) {
      Success<NoticePage>(:final data) => (
          success: true,
          page: data,
          message: null,
        ),
      Failure<NoticePage>(:final error) => (
          success: false,
          page: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, int count, String? message})> unreadCount() async {
    final result = await _repo.unreadCount();
    return switch (result) {
      Success<int>(:final data) => (success: true, count: data, message: null),
      Failure<int>(:final error) => (
          success: false,
          count: 0,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, String? message})> markRead(String noticeId) async {
    final result = await _repo.markRead(noticeId);
    return switch (result) {
      Success<void>() => (success: true, message: null),
      Failure<void>(:final error) => (success: false, message: error.message),
    };
  }

  @override
  Future<({bool success, int affected, String? message})> markAllRead() async {
    final result = await _repo.markAllRead();
    return switch (result) {
      Success<int>(:final data) => (
          success: true,
          affected: data,
          message: null,
        ),
      Failure<int>(:final error) => (
          success: false,
          affected: 0,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, String? message})> delete(String noticeId) async {
    final result = await _repo.delete(noticeId);
    return switch (result) {
      Success<void>() => (success: true, message: null),
      Failure<void>(:final error) => (success: false, message: error.message),
    };
  }
}
