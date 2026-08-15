/// 抖音主播领域实体
///
/// 与 DTO 解耦：后端字段变化时只需调整映射，领域层与 UI 不受影响。
class Streamer {
  final String id;
  final String secUid;
  final String douyinId;
  final String nickname;
  final String avatar;
  final bool live;
  final int? liveStartedAt;
  final int subscribedAt;
  /// 人气值（被订阅次数，热门列表排序依据）
  final int popularity;

  const Streamer({
    required this.id,
    required this.secUid,
    required this.douyinId,
    required this.nickname,
    required this.avatar,
    required this.live,
    required this.liveStartedAt,
    required this.subscribedAt,
    this.popularity = 0,
  });

  Streamer copyWith({
    bool? live,
    int? liveStartedAt,
    int? popularity,
  }) =>
      Streamer(
        id: id,
        secUid: secUid,
        douyinId: douyinId,
        nickname: nickname,
        avatar: avatar,
        live: live ?? this.live,
        liveStartedAt: liveStartedAt ?? this.liveStartedAt,
        subscribedAt: subscribedAt,
        popularity: popularity ?? this.popularity,
      );
}

/// 开播通知结果
class LiveNotify {
  final Streamer streamer;
  final String message;

  const LiveNotify({required this.streamer, required this.message});
}

/// 检测开播结果
class CheckLiveResult {
  final Streamer streamer;
  final bool live;
  /// 若"未播→在播"，包含通知文案；否则为 null
  final String? message;

  const CheckLiveResult({
    required this.streamer,
    required this.live,
    this.message,
  });
}
