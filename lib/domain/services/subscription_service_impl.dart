import '../../core/result.dart';
import '../entities/streamer.dart';
import '../repositories/subscription_repository.dart';
import 'subscription_service.dart';

/// 订阅领域服务默认实现
///
/// 编排：参数校验 → 调用仓库 → 结果转换。
/// 不依赖具体仓库实现，便于替换 / 测试。
class SubscriptionServiceImpl implements SubscriptionService {
  SubscriptionServiceImpl(this._repo);

  final SubscriptionRepository _repo;

  @override
  Future<({bool success, Streamer? streamer, String? message})> subscribeById(
      String streamerId) async {
    final result = await _repo.subscribeById(streamerId);
    return switch (result) {
      Success<Streamer>(:final data) => (
          success: true,
          streamer: data,
          message: null,
        ),
      Failure<Streamer>(:final error) => (
          success: false,
          streamer: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, int wantCount, String? message})> wish(
      String douyinId) async {
    final id = douyinId.trim();
    if (id.isEmpty) {
      return (success: false, wantCount: 0, message: '请输入抖音号');
    }
    final result = await _repo.wish(id);
    return switch (result) {
      Success<int>(:final data) => (
          success: true,
          wantCount: data,
          message: null,
        ),
      Failure<int>(:final error) => (
          success: false,
          wantCount: 0,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, List<Streamer> list, String? message})> list() async {
    final result = await _repo.list();
    return switch (result) {
      Success<List<Streamer>>(:final data) => (
          success: true,
          list: data,
          message: null,
        ),
      Failure<List<Streamer>>(:final error) => (
          success: false,
          list: const <Streamer>[],
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, List<Streamer> list, String? message})> listPopular({
    int limit = 20,
  }) async {
    final result = await _repo.listPopular(limit: limit);
    return switch (result) {
      Success<List<Streamer>>(:final data) => (
          success: true,
          list: data,
          message: null,
        ),
      Failure<List<Streamer>>(:final error) => (
          success: false,
          list: const <Streamer>[],
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, String? message})> unsubscribe(
      String streamerId) async {
    final result = await _repo.unsubscribe(streamerId);
    return switch (result) {
      Success<void>() => (success: true, message: null),
      Failure<void>(:final error) => (success: false, message: error.message),
    };
  }

  @override
  Future<({bool success, CheckLiveResult? result, String? message})> checkLive(
      String streamerId) async {
    final result = await _repo.checkLive(streamerId);
    return switch (result) {
      Success<CheckLiveResult>(:final data) => (
          success: true,
          result: data,
          message: null,
        ),
      Failure<CheckLiveResult>(:final error) => (
          success: false,
          result: null,
          message: error.message,
        ),
    };
  }

  @override
  Future<({bool success, List<LiveNotify> notifies, String? message})> poll() async {
    final result = await _repo.poll();
    return switch (result) {
      Success<List<LiveNotify>>(:final data) => (
          success: true,
          notifies: data,
          message: null,
        ),
      Failure<List<LiveNotify>>(:final error) => (
          success: false,
          notifies: const <LiveNotify>[],
          message: error.message,
        ),
    };
  }
}
