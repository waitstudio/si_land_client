// 应用常量：时间、长度、限制类配置

class AppConstants {
  AppConstants._();

  /// HTTP 请求超时（秒）
  static const int httpTimeoutSeconds = 15;

  /// 验证码有效期（秒），与后端保持一致
  static const int smsExpireIn = 300;

  /// 验证码重发冷却（秒）
  static const int resendCooldown = 60;

  /// 验证码最小有效长度
  static const int smsCodeMinLength = 4;

  /// 验证码最大长度
  static const int smsCodeMaxLength = 6;

  /// 手机号最大长度
  static const int phoneMaxLength = 11;

  /// 抖音号最小长度
  static const int douyinIdMinLength = 2;

  /// 抖音号最大长度
  static const int douyinIdMaxLength = 20;

  /// 热门主播列表拉取上限
  static const int popularListLimit = 100;

  /// 通知列表每页条数
  static const int noticePageSize = 20;

  /// 开播通知调度延迟（秒）
  static const int notifyScheduleDelaySeconds = 15;

  /// Toast 显示时长（秒）
  static const int toastDurationSeconds = 2;

  /// 顶部 banner 自动消失时长（秒）
  static const int bannerDismissSeconds = 3;

  /// banner 滑入动画时长（毫秒）
  static const int bannerAnimDurationMs = 250;

  /// WS 心跳间隔（秒），服务端 90s 空闲超时的三分之一余量
  static const int wsHeartbeatSeconds = 30;

  /// WS 断线重连基础延迟（秒），指数退避起点
  static const int wsReconnectBaseDelaySeconds = 1;

  /// WS 断线重连最大延迟（秒）
  static const int wsReconnectMaxDelaySeconds = 60;

  /// WS 通知弹窗自动消失时长（秒）
  static const int noticeBannerDismissSeconds = 4;

  /// 防重复弹窗的 notice id 缓存容量
  static const int noticeDedupCacheSize = 100;
}
