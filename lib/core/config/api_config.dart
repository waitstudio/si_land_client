// API 配置：后端地址与接口路径

class ApiConfig {
  ApiConfig._();

  /// 后端基础地址
  ///
  /// - iOS 模拟器访问本机服务用 `http://127.0.0.1:8080`
  /// - Android 模拟器访问本机服务用 `http://10.0.2.2:8080`
  /// - 真机调试请改为本机局域网 IP，如 `http://192.168.1.100:8080`
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  /// 接口路径（App 端统一 /api/v1/app 前缀）
  static const String sendSmsPath = '/api/v1/app/sms/send';
  static const String loginPath = '/api/v1/app/auth/login';
  static const String authMePath = '/api/v1/app/auth/me';
  static const String authNicknamePath = '/api/v1/app/auth/nickname';
  static const String wsTicketPath = '/api/v1/app/auth/ws-ticket';

  /// 主播订阅
  static const String streamersPath = '/api/v1/app/streamers';
  static const String streamersPopularPath = '/api/v1/app/streamers/popular';
  static const String streamersWishPath = '/api/v1/app/streamers/wishes';
  static String streamerPath(String id) => '/api/v1/app/streamers/$id';
  static String streamerCheckLivePath(String id) =>
      '/api/v1/app/streamers/$id/check-live';
  static String streamerSubscribePath(String id) =>
      '/api/v1/app/streamers/$id/subscribe';
  static const String streamersPollPath = '/api/v1/app/streamers/poll';

  /// 开播通知
  static const String noticesPath = '/api/v1/app/notices';
  static const String noticesReadAllPath = '/api/v1/app/notices/read-all';
  static const String noticesUnreadCountPath = '/api/v1/app/notices/unread-count';
  static String noticeReadPath(String id) => '/api/v1/app/notices/$id/read';
  static String noticePath(String id) => '/api/v1/app/notices/$id';
  /// 分页查询 URL（page 从 1 开始）
  static String noticesPagePath({required int page, required int pageSize}) =>
      '$noticesPath?page=$page&page_size=$pageSize';

  /// 问题反馈
  static const String feedbackPath = '/api/v1/app/feedback';

  /// WebSocket 端点（一次性短期 ticket 走 query，避免长期 JWT 出现在 URL）。
  static String wsUrl(String ticket) {
    final base = baseUrl.replaceFirst(RegExp(r'^http'), 'ws');
    return '$base/api/v1/app/ws?ticket=${Uri.encodeComponent(ticket)}';
  }
}
