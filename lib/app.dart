import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/auth/auth_storage.dart';
import 'core/http/api_client.dart';
import 'core/notifications/notice_coordinator.dart';
import 'core/ws/ws_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/feedback_repository_impl.dart';
import 'data/repositories/notice_repository_impl.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/feedback_repository.dart';
import 'domain/repositories/notice_repository.dart';
import 'domain/repositories/subscription_repository.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/auth_service_impl.dart';
import 'domain/services/notice_service.dart';
import 'domain/services/notice_service_impl.dart';
import 'domain/services/subscription_service.dart';
import 'domain/services/subscription_service_impl.dart';
import 'state/auth_view_model.dart';
import 'state/notice_view_model.dart';
import 'state/subscription_view_model.dart';
import 'state/unread_badge.dart';
import 'ui/components/loading_indicator.dart';
import 'ui/main_shell.dart';
import 'ui/pages/login/login_page.dart';
import 'ui/services/local_notifier.dart';
import 'ui/theme/app_theme.dart';

/// 应用根 Widget
///
/// 在此组装依赖注入：基础设施 → 仓库 → 服务 → ViewModel。
/// 替换实现（如 mock 数据源、GraphQL）时，只需在此处替换 Provider。
class SiLandApp extends StatelessWidget {
  const SiLandApp({required this.authStorage, super.key});

  final AuthStorage authStorage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 基础设施：token 存储 + HTTP 客户端（自动注入 Authorization）
        Provider<AuthStorage>.value(value: authStorage),
        Provider<ApiClient>(
          create: (_) => ApiClient(authStorage: authStorage),
          dispose: (_, client) => client.close(),
        ),
        // 全局未读红点（WS / 冷启动 / 消息页操作共同维护）
        ChangeNotifierProvider<UnreadBadge>(create: (_) => UnreadBadge()),
        Provider<NoticeCoordinator>(
          create: (_) => NoticeCoordinator(),
          dispose: (_, coordinator) => coordinator.dispose(),
        ),
        // WS 长连接（由 _WsGate 按登录态编排连接）
        Provider<WsService>(
          create: (ctx) => WsService(ctx.read<ApiClient>()),
          dispose: (_, service) => service.disconnect(),
        ),
        // 认证
        Provider<AuthRepository>(
          create: (ctx) => RestAuthRepository(
            client: ctx.read<ApiClient>(),
            authStorage: ctx.read<AuthStorage>(),
          ),
        ),
        Provider<AuthService>(
          create: (ctx) => AuthServiceImpl(ctx.read<AuthRepository>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) {
            final vm = AuthViewModel(ctx.read<AuthService>());
            // 启动即尝试恢复会话（/auth/me），结果通过 state.restored 暴露
            vm.restoreSession();
            return vm;
          },
        ),
        // 主播订阅
        Provider<SubscriptionRepository>(
          create: (ctx) =>
              RestSubscriptionRepository(client: ctx.read<ApiClient>()),
        ),
        Provider<SubscriptionService>(
          create: (ctx) =>
              SubscriptionServiceImpl(ctx.read<SubscriptionRepository>()),
        ),
        ChangeNotifierProvider<SubscriptionViewModel>(
          create: (ctx) =>
              SubscriptionViewModel(ctx.read<SubscriptionService>()),
        ),
        // 开播通知
        Provider<NoticeRepository>(
          create: (ctx) => RestNoticeRepository(client: ctx.read<ApiClient>()),
        ),
        Provider<NoticeService>(
          create: (ctx) => NoticeServiceImpl(ctx.read<NoticeRepository>()),
        ),
        ChangeNotifierProvider<NoticeViewModel>(
          create: (ctx) =>
              NoticeViewModel(ctx.read<NoticeService>(), ctx.read<UnreadBadge>()),
        ),
        // 问题反馈
        Provider<FeedbackRepository>(
          create: (ctx) => RestFeedbackRepository(client: ctx.read<ApiClient>()),
        ),
      ],
      child: MaterialApp(
        title: '硅基星球',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        navigatorKey: LocalNotifier.instance.navigatorKey,
        home: const _WsGate(child: _SplashGate()),
      ),
    );
  }
}

/// 启动决策页
///
/// 监听 [AuthViewModel] 状态：
/// - restoring 中 → 显示启动占位
/// - 已恢复且 currentUser 存在 → 进入主壳
/// - 已恢复且无 currentUser → 进入登录页
///
/// 登录成功后 ViewModel 的 currentUser 会被设置，本 widget 自动重建进入主壳。
/// 退出登录后 currentUser 清空，自动回到登录页。
class _SplashGate extends StatelessWidget {
  const _SplashGate();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final s = vm.state;

    if (s.restoring) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    if (s.currentUser != null) {
      return const MainShell();
    }

    return const LoginPage();
  }
}

/// WS 实时通知编排层
///
/// 按登录态编排 [WsService] 连接 / 断开，并桥接到 UI：
/// - 登录 → 冷启动拉取未读数（HTTP 权威值）+ 建立 WS 长连接
/// - 登出 → 断开 WS、红点清零
/// - WS notice → id 去重（防重复弹窗）→ 红点 +1 → 前台时弹顶部通知弹窗
/// - WS unread → 服务端权威未读数覆盖本地（计数容错）
/// - 切后台 → 不再展示 App 内弹窗；回前台 → 立即重连断线的 WS
class _WsGate extends StatefulWidget {
  const _WsGate({required this.child});

  final Widget child;

  @override
  State<_WsGate> createState() => _WsGateState();
}

class _WsGateState extends State<_WsGate> with WidgetsBindingObserver {
  bool _appResumed = true;
  bool _wired = false;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() => _appResumed = state == AppLifecycleState.resumed);
    if (_appResumed) {
      // 回前台：iOS 挂起的 WS 可能已死，跳过退避立即重连
      context.read<WsService>().resume();
    }
  }

  void _wireCallbacks(WsService ws, UnreadBadge badge, NoticeViewModel noticeVm) {
    if (_wired) return;
    _wired = true;
    ws.onNotice = (data) => context.read<NoticeCoordinator>().handleNotice(
          data,
          badge: badge,
          noticeViewModel: noticeVm,
          appResumed: _appResumed,
        );
    ws.onUnread = badge.setCount;
  }

  /// 登录后：拉取权威未读数 + 建立 WS 连接（token 变化时自动重连）
  Future<void> _onLoggedIn(
      WsService ws, UnreadBadge badge, AuthStorage storage, NoticeService noticeService) async {
    final token = await storage.read();
    if (token == null || !mounted) return;
    _wireCallbacks(ws, badge, context.read<NoticeViewModel>());
    if (!_connected) {
      _connected = true;
      // 冷启动主动拉取未读数（WS 不可用时红点也有权威值）
      final res = await noticeService.unreadCount();
      if (res.success) badge.setCount(res.count);
    }
    ws.connect();
  }

  void _onLoggedOut(WsService ws, UnreadBadge badge) {
    _connected = false;
    ws.disconnect();
    badge.clear();
    context.read<NoticeCoordinator>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final loggedIn = auth.state.currentUser != null;

    // build 中不做连接副作用，帧后执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ws = context.read<WsService>();
      final badge = context.read<UnreadBadge>();
      if (loggedIn) {
        _onLoggedIn(
          ws,
          badge,
          context.read<AuthStorage>(),
          context.read<NoticeService>(),
        );
      } else if (_connected) {
        _onLoggedOut(ws, badge);
      }
    });

    return widget.child;
  }
}
