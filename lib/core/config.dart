/// 客户端全局配置
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

  /// 验证码有效期（秒），与后端保持一致，用于客户端倒计时
  static const int smsExpireIn = 300;

  /// 重新发送间隔（秒）
  static const int resendCooldown = 60;
}
