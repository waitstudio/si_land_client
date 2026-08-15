/// 开播通知领域实体
///
/// 与 DTO 解耦：后端字段变化时只需调整映射，领域层与 UI 不受影响。
class LiveNotice {
  final String id;
  final String streamerId;
  final String streamerNickname;
  final String avatar;
  final String title;
  final String body;
  final int? liveStartedAt;
  final int createdAt;
  final bool read;

  const LiveNotice({
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

  LiveNotice copyWith({bool? read}) => LiveNotice(
        id: id,
        streamerId: streamerId,
        streamerNickname: streamerNickname,
        avatar: avatar,
        title: title,
        body: body,
        liveStartedAt: liveStartedAt,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

/// 通知分页结果
class NoticePage {
  final List<LiveNotice> items;
  final int total;
  final int unreadCount;

  const NoticePage({
    required this.items,
    required this.total,
    required this.unreadCount,
  });
}
