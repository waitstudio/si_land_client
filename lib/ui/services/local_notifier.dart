import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../core/config.dart';
import 'top_banner.dart';

/// 本地通知服务
///
/// 提供两路通知：
/// 1. 系统通知（`flutter_local_notifications`）：需运行时权限，
///    iOS 模拟器不支持弹窗，未授权或失败时静默忽略。
/// 2. 应用内顶部 banner（[TopBannerController]）：不依赖权限，
///    iOS / Android 均稳定可见。
///
/// 后续接入远程推送（FCM / APNs）时，可在此扩展或组合，调用方无需改动。
class LocalNotifier {
  LocalNotifier._();

  static final LocalNotifier instance = LocalNotifier._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// 全局 navigatorKey，用于获取 Overlay 注入顶部 banner。
  /// 在 `main.dart` 中赋值给 `MaterialApp.navigatorKey`。
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 顶部 banner 控制器（独立组件，便于复用与测试）
  final TopBannerController banner = TopBannerController();

  static const _channelId = 'streamer_live';
  static const _channelName = '主播开播提醒';
  static const _channelDesc = '订阅的主播开播时通知';

  /// 初始化通知插件与 Android 渠道，并请求运行时通知权限。
  /// 失败不抛异常，仅标记为不可用。
  Future<void> init() async {
    try {
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      _ready = await _plugin.initialize(initSettings) ?? false;

      // 创建 Android 通知渠道
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );

      // 请求运行时通知权限（Android 13+ / iOS）
      await requestPermission();
    } catch (_) {
      _ready = false;
    }
  }

  /// 请求通知权限。Android 13+ 必须运行时请求，否则 [showLive] 会静默失败。
  Future<void> requestPermission() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        await android.requestNotificationsPermission();
      }
    } catch (_) {
      // 权限请求失败不阻塞，[showLive] 时若未授权会静默忽略
    }
  }

  /// 弹出一条"主播开播"通知。
  ///
  /// 同时触发：① 系统通知（需权限）② 应用内顶部 banner（兜底，一定可见）。
  void showLive({required String title, required String body}) {
    // 1) 系统通知
    _showSystem(title, body);
    // 2) 应用内顶部 banner
    _showTopBanner(body);
  }

  /// 安排一条延迟 [delay] 秒后触发的"主播开播"系统通知。
  ///
  /// 用 [FlutterLocalNotificationsPlugin.zonedSchedule] 交给系统层调度，
  /// APP 切到后台 / 锁屏后仍能弹通知；APP 被彻底杀进程后不会触发。
  /// 用于模拟"后台收到推送"的效果（真实生产应改用 FCM / APNs）。
  ///
  /// 不弹应用内 banner——因为 APP 切后台后 Overlay 不渲染，
  /// 此方法的目标就是模拟后台推送，banner 没意义。
  Future<void> scheduleLive({
    required String title,
    required String body,
    int delay = AppConstants.notifyScheduleDelaySeconds,
  }) async {
    if (!_ready) return;
    try {
      await _plugin.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        tz.TZDateTime.now(tz.local).add(Duration(seconds: delay)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // 允许在 APP 处于后台时由系统触发（iOS 必须为 true 才能在后台弹）
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // 调度失败不影响业务流程
    }
  }

  Future<void> _showSystem(String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (_) {
      // 通知失败不影响业务流程
    }
  }

  void _showTopBanner(String msg) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) return;
    banner.show(overlay, msg);
  }
}
