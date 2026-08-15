import '../core/config.dart';
import '../domain/entities/streamer.dart';
import '../domain/services/subscription_service.dart';
import 'base_view_model.dart';
import 'subscription_state.dart';

/// 订阅 ViewModel
///
/// 持有 [SubscriptionState]，通过 [SubscriptionService] 编排业务，
/// UI 通过 Provider 订阅。UI 不直接接触 service / repository。
class SubscriptionViewModel extends BaseViewModel {
  SubscriptionViewModel(this._service);

  final SubscriptionService _service;

  SubscriptionState _state = const SubscriptionState();
  SubscriptionState get state => _state;

  void _set(SubscriptionState newState) {
    _state = newState;
    emit();
  }

  /// 拉取订阅列表
  Future<void> load() async {
    _set(_state.copyWith(loading: true, clearError: true));
    final res = await _service.list();
    if (res.success) {
      _set(_state.copyWith(loading: false, streamers: res.list));
    } else {
      _set(_state.copyWith(loading: false, error: res.message));
    }
  }

  /// 拉取热门主播列表（添加订阅弹框使用，最多 100 条）
  Future<void> loadPopular() async {
    _set(_state.copyWith(loadingPopular: true, clearError: true));
    final res =
        await _service.listPopular(limit: AppConstants.popularListLimit);
    if (res.success) {
      _set(_state.copyWith(loadingPopular: false, popular: res.list));
    } else {
      _set(_state.copyWith(loadingPopular: false, error: res.message));
    }
  }

  /// 订阅主播
  Future<void> subscribe(String douyinId) async {
    _set(_state.copyWith(subscribing: true, clearError: true));
    final res = await _service.subscribe(douyinId);

    if (res.success && res.streamer != null) {
      final streamer = res.streamer!;
      final next = [..._state.streamers];
      final idx = next.indexWhere((s) => s.id == streamer.id);
      if (idx >= 0) {
        next[idx] = streamer;
      } else {
        next.insert(0, streamer);
      }
      // 同步更新 popular 列表：若该主播在 popular 中，刷新信息并 popularity+1
      final popularNext = _state.popular.map((s) {
        if (s.id == streamer.id) {
          return streamer.copyWith(popularity: s.popularity + 1);
        }
        return s;
      }).toList();
      _set(_state.copyWith(
        subscribing: false,
        streamers: next,
        popular: popularNext,
      ));
    } else {
      _set(_state.copyWith(subscribing: false, error: res.message));
    }
  }

  /// 取消订阅
  Future<void> unsubscribe(String streamerId) async {
    final res = await _service.unsubscribe(streamerId);
    if (res.success) {
      final next = _state.streamers.where((s) => s.id != streamerId).toList();
      _set(_state.copyWith(streamers: next));
    } else {
      _set(_state.copyWith(error: res.message));
    }
  }

  /// 检测主播开播状态（真实请求 live.douyin.com/{douyin_id}）
  Future<void> checkLive(String streamerId) async {
    _set(_state.copyWith(clearError: true));
    final res = await _service.checkLive(streamerId);
    if (res.success && res.result != null) {
      final r = res.result!;
      final next = _state.streamers.map((s) {
        if (s.id == streamerId) {
          return s.copyWith(
              live: r.live, liveStartedAt: r.streamer.liveStartedAt);
        }
        return s;
      }).toList();
      // 若"未播→在播"，走延迟通知通道
      if (r.message != null) {
        _set(_state.copyWith(
          streamers: next,
          pendingNotify: LiveNotify(streamer: r.streamer, message: r.message!),
        ));
      } else {
        final msg = r.live ? '主播正在直播' : '主播未在直播';
        _set(_state.copyWith(streamers: next, error: msg));
      }
    } else {
      _set(_state.copyWith(error: res.message));
    }
  }

  /// 批量轮询订阅主播，新开播的会走 pendingNotify 通道
  Future<void> poll() async {
    _set(_state.copyWith(loading: true, clearError: true));
    final res = await _service.poll();
    if (res.success) {
      // 刷新列表状态（后端已更新存储）
      final liveIds = res.notifies.map((n) => n.streamer.id).toSet();
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final next = _state.streamers.map((s) {
        if (liveIds.contains(s.id)) {
          return s.copyWith(live: true, liveStartedAt: now);
        }
        return s;
      }).toList();
      // 取第一条作为 pendingNotify（UI 会逐条消费）
      final notify = res.notifies.isNotEmpty ? res.notifies.first : null;
      _set(_state.copyWith(
        streamers: next,
        loading: false,
        pendingNotify: notify,
        error: res.notifies.isEmpty ? '暂无主播开播' : null,
      ));
    } else {
      _set(_state.copyWith(loading: false, error: res.message));
    }
  }

  void clearError() => _set(_state.copyWith(clearError: true));

  void clearPendingNotify() => _set(_state.copyWith(clearNotify: true));
}
