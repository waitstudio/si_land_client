import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'app.dart';
import 'core/auth/auth_storage.dart';
import 'ui/services/local_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // timezone 数据用于本地通知的 zonedSchedule（系统层调度，APP 后台也能触发）
  tz_data.initializeTimeZones();
  // 通知初始化异步进行，不阻塞首帧
  LocalNotifier.instance.init();
  // 初始化 token 本地存储（在 runApp 前完成，保证 ApiClient / Repository 可用）
  final authStorage = await AuthStorage.create();
  runApp(SiLandApp(authStorage: authStorage));
}
