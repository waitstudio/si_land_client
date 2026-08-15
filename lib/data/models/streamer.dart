import '../../domain/entities/streamer.dart';

/// 主播信息 DTO（与后端响应字段对齐）
class StreamerDto {
  final String id;
  final String secUid;
  final String douyinId;
  final String nickname;
  final String avatar;
  final bool live;
  final int? liveStartedAt;
  final int subscribedAt;
  final int popularity;

  StreamerDto({
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

  factory StreamerDto.fromJson(Map<String, dynamic> json) {
    return StreamerDto(
      id: json['id'] as String,
      secUid: json['sec_uid'] as String,
      douyinId: json['douyin_id'] as String? ?? '',
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String? ?? '',
      live: json['live'] as bool? ?? false,
      liveStartedAt: json['live_started_at'] as int?,
      subscribedAt: json['subscribed_at'] as int? ?? 0,
      popularity: (json['popularity'] as num?)?.toInt() ?? 0,
    );
  }

  Streamer toDomain() => Streamer(
        id: id,
        secUid: secUid,
        douyinId: douyinId,
        nickname: nickname,
        avatar: avatar,
        live: live,
        liveStartedAt: liveStartedAt,
        subscribedAt: subscribedAt,
        popularity: popularity,
      );
}

/// 开播通知响应 DTO
class LiveNotifyDto {
  final StreamerDto streamer;
  final bool live;
  final String message;

  LiveNotifyDto({
    required this.streamer,
    required this.live,
    required this.message,
  });

  factory LiveNotifyDto.fromJson(Map<String, dynamic> json) {
    return LiveNotifyDto(
      streamer: StreamerDto.fromJson(json['streamer'] as Map<String, dynamic>),
      live: json['live'] as bool? ?? false,
      message: json['message'] as String,
    );
  }

  LiveNotify toDomain() => LiveNotify(
        streamer: streamer.toDomain(),
        message: message,
      );
}

/// 检测开播响应 DTO
class CheckLiveDto {
  final StreamerDto streamer;
  final bool live;
  final String? message;

  CheckLiveDto({
    required this.streamer,
    required this.live,
    required this.message,
  });

  factory CheckLiveDto.fromJson(Map<String, dynamic> json) {
    return CheckLiveDto(
      streamer: StreamerDto.fromJson(json['streamer'] as Map<String, dynamic>),
      live: json['live'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  CheckLiveResult toDomain() => CheckLiveResult(
        streamer: streamer.toDomain(),
        live: live,
        message: message,
      );
}
