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

  /// 接口路径
  static const String sendSmsPath = '/api/v1/sms/send';
  static const String loginPath = '/api/v1/auth/login';
  static const String authMePath = '/api/v1/auth/me';

  /// 主播订阅
  static const String streamersPath = '/api/v1/streamers';
  static const String streamersPopularPath = '/api/v1/streamers/popular';
  static String streamerPath(String id) => '/api/v1/streamers/$id';
  static String streamerCheckLivePath(String id) =>
      '/api/v1/streamers/$id/check-live';
  static const String streamersPollPath = '/api/v1/streamers/poll';
}
