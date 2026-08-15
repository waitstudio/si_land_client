import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/auth/auth_storage.dart';
import 'core/http/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/subscription_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/subscription_repository.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/auth_service_impl.dart';
import 'domain/services/subscription_service.dart';
import 'domain/services/subscription_service_impl.dart';
import 'state/auth_view_model.dart';
import 'state/subscription_view_model.dart';
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
      ],
      child: MaterialApp(
        title: '硅基星球',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        navigatorKey: LocalNotifier.instance.navigatorKey,
        home: const _SplashGate(),
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
