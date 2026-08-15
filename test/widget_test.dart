// 登录页冒烟测试
//
// 使用 mock AuthService 注入，不依赖真实网络。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:si_land_client/domain/entities/auth.dart';
import 'package:si_land_client/domain/entities/user.dart';
import 'package:si_land_client/domain/services/auth_service.dart';
import 'package:si_land_client/state/auth_view_model.dart';
import 'package:si_land_client/ui/pages/login/login_page.dart';
import 'package:si_land_client/ui/theme/app_theme.dart';

/// 始终成功的 mock AuthService
class _MockAuthService implements AuthService {
  @override
  Future<({bool success, int? expireIn, String? message})> sendCode(
      String phone) async {
    return (success: true, expireIn: 300, message: null);
  }

  @override
  Future<({bool success, LoginResult? result, String? message})> login({
    required String phone,
    required String code,
  }) async {
    return (
      success: true,
      result: LoginResult(
        token: const AuthToken(
          token: 't',
          tokenType: 'Bearer',
          expiresAt: 0,
        ),
        user: User(
          userId: 'u',
          phone: phone,
          nickname: '硅基星球用户',
          avatar: '',
        ),
      ),
      message: null,
    );
  }

  @override
  Future<({bool success, User? user, String? message})> restoreSession() async {
    return (success: false, user: null, message: 'mock');
  }

  @override
  Future<void> logout() async {}
}

Widget _buildApp() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: ChangeNotifierProvider<AuthViewModel>(
      create: (_) => AuthViewModel(_MockAuthService()),
      child: const LoginPage(),
    ),
  );
}

void main() {
  testWidgets('LoginPage renders title and inputs', (tester) async {
    await tester.pumpWidget(_buildApp());

    expect(find.text('进入硅基星球'), findsWidgets);
    expect(find.text('请输入手机号'), findsOneWidget);
    expect(find.text('请输入验证码'), findsOneWidget);
    expect(find.textContaining('《用户协议》'), findsOneWidget);
    expect(find.textContaining('《隐私政策》'), findsOneWidget);
  });

  testWidgets('login button disabled until phone+code+agreement filled',
      (tester) async {
    await tester.pumpWidget(_buildApp());

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);

    // 输入手机号 + 验证码 + 勾选协议后按钮可用
    await tester.enterText(find.byType(TextField).at(0), '13800138000');
    await tester.enterText(find.byType(TextField).at(1), '1234');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    final buttonAfter =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(buttonAfter.onPressed, isNotNull);
  });
}
