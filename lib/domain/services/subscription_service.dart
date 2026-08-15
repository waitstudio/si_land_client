import '../entities/streamer.dart';

/// 订阅领域服务抽象
///
/// 封装订阅编排逻辑（校验、调用仓库、结果转换）。
/// UI / ViewModel 通过此抽象调用，便于替换实现或测试。
abstract class SubscriptionService {
  /// 订阅主播
  Future<({bool success, Streamer? streamer, String? message})> subscribe(
      String douyinId);

  /// 拉取订阅列表
  Future<({bool success, List<Streamer> list, String? message})> list();

  /// 拉取热门主播列表
  Future<({bool success, List<Streamer> list, String? message})> listPopular({
    int limit = 20,
  });

  /// 取消订阅
  Future<({bool success, String? message})> unsubscribe(String streamerId);

  /// 检测主播开播状态
  Future<
      ({
        bool success,
        CheckLiveResult? result,
        String? message,
      })> checkLive(String streamerId);

  /// 批量轮询订阅主播
  Future<({bool success, List<LiveNotify> notifies, String? message})> poll();
}
