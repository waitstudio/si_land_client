import '../../domain/entities/notice.dart';

/// 开播通知 DTO（与后端响应字段对齐）
class NoticeDto {
  final String id;
  final String streamerId;
  final String streamerNickname;
  final String? avatar;
  final String title;
  final String body;
  final int? liveStartedAt;
  final int createdAt;
  final bool read;

  NoticeDto({
    required this.id,
    required this.streamerId,
    required this.streamerNickname,
    required this.avatar,
    required this.title,
    required this.body,
    required this.liveStartedAt,
    required this.createdAt,
    required this.read,
  });

  factory NoticeDto.fromJson(Map<String, dynamic> json) {
    return NoticeDto(
      id: json['id'] as String,
      streamerId: json['streamer_id'] as String? ?? '',
      streamerNickname: json['streamer_nickname'] as String? ?? '',
      avatar: json['avatar'] as String?,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      liveStartedAt: json['live_started_at'] as int?,
      createdAt: (json['created_at'] as num?)?.toInt() ?? 0,
      read: json['read'] as bool? ?? false,
    );
  }

  LiveNotice toDomain() => LiveNotice(
        id: id,
        streamerId: streamerId,
        streamerNickname: streamerNickname,
        avatar: avatar ?? '',
        title: title,
        body: body,
        liveStartedAt: liveStartedAt,
        createdAt: createdAt,
        read: read,
      );
}

/// 通知列表响应 DTO
class NoticeListDto {
  final List<NoticeDto> items;
  final int total;
  final int unreadCount;

  NoticeListDto({
    required this.items,
    required this.total,
    required this.unreadCount,
  });

  factory NoticeListDto.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? const [])
        .map((e) => NoticeDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return NoticeListDto(
      items: list,
      total: (json['total'] as num?)?.toInt() ?? 0,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }

  NoticePage toDomain() => NoticePage(
        items: items.map((e) => e.toDomain()).toList(),
        total: total,
        unreadCount: unreadCount,
      );
}
