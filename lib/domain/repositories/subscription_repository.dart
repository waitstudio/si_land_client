import '../../core/result.dart';
import '../entities/streamer.dart';

/// 主播订阅仓库抽象
///
/// data 层提供实现（如 RestSubscriptionRepository）；
/// 测试时可注入 mock 实现，业务层与 UI 层不依赖具体实现。
abstract class SubscriptionRepository {
  /// 订阅主播（按抖音号）
  Future<Result<Streamer>> subscribe(String douyinId);

  /// 我的订阅列表
  Future<Result<List<Streamer>>> list();

  /// 热门主播列表（按人气降序，跨用户共享）
  Future<Result<List<Streamer>>> listPopular({int limit = 20});

  /// 取消订阅
  Future<Result<void>> unsubscribe(String streamerId);

  /// 检测主播开播状态（访问 live.douyin.com/{douyin_id}）
  Future<Result<CheckLiveResult>> checkLive(String streamerId);

  /// 批量轮询订阅主播，返回新开播的通知列表
  Future<Result<List<LiveNotify>>> poll();
}
