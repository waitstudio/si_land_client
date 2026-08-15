import 'package:flutter/foundation.dart';

import '../domain/entities/streamer.dart';

/// 订阅页面状态
@immutable
class SubscriptionState {
  const SubscriptionState({
    this.streamers = const [],
    this.popular = const [],
    this.loading = false,
    this.loadingPopular = false,
    this.subscribing = false,
    this.wishing = false,
    this.error,
    this.pendingNotify,
  });

  final List<Streamer> streamers;

  /// 热门主播列表（添加订阅弹框展示，按 popularity 降序）
  final List<Streamer> popular;

  /// 加载订阅列表中
  final bool loading;

  /// 加载热门列表中
  final bool loadingPopular;

  /// 订阅中（热门主播订阅按钮）
  final bool subscribing;

  /// 想看意愿提交中（手动输入抖音号）
  final bool wishing;

  final String? error;

  /// 待展示的开播通知（UI 消费后清除）
  final LiveNotify? pendingNotify;

  SubscriptionState copyWith({
    List<Streamer>? streamers,
    List<Streamer>? popular,
    bool? loading,
    bool? loadingPopular,
    bool? subscribing,
    bool? wishing,
    String? error,
    LiveNotify? pendingNotify,
    bool clearError = false,
    bool clearNotify = false,
  }) {
    return SubscriptionState(
      streamers: streamers ?? this.streamers,
      popular: popular ?? this.popular,
      loading: loading ?? this.loading,
      loadingPopular: loadingPopular ?? this.loadingPopular,
      subscribing: subscribing ?? this.subscribing,
      wishing: wishing ?? this.wishing,
      error: clearError ? null : (error ?? this.error),
      pendingNotify: clearNotify ? null : (pendingNotify ?? this.pendingNotify),
    );
  }
}
