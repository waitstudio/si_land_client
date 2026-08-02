import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/http/api_client.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/services/auth_service.dart';
import 'domain/services/auth_service_impl.dart';
import 'state/auth_view_model.dart';
import 'ui/pages/login/login_page.dart';
import 'ui/theme/app_theme.dart';

/// 应用根 Widget
///
/// 在此组装依赖注入：ApiClient → AuthRepository → AuthService → AuthViewModel。
/// 替换实现（如 mock 数据源、GraphQL）时，只需在此处替换 Provider。
class SiLandApp extends StatelessWidget {
  const SiLandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 基础设施：HTTP 客户端
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          dispose: (_, client) => client.close(),
        ),
        // data 层：仓库实现 → 抽象
        Provider<AuthRepository>(
          create: (ctx) => RestAuthRepository(client: ctx.read<ApiClient>()),
        ),
        // domain 层：服务实现 → 抽象
        Provider<AuthService>(
          create: (ctx) => AuthServiceImpl(ctx.read<AuthRepository>()),
        ),
        // state 层：ViewModel
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(ctx.read<AuthService>()),
        ),
      ],
      child: MaterialApp(
        title: '硅基星球',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const LoginPage(),
      ),
    );
  }
}
