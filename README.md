# si_land_client

硅基星球（si_land）项目移动端，基于 Flutter 构建。

> 当前阶段：完成手机号验证码登录页面的 UI 与流程，接入 [si_land_server](../si_land_server) 的 mock 接口。

## 技术栈

- 框架：Flutter（Dart SDK ^3.12.2）
- 状态管理：[provider](https://pub.dev/packages/provider) ^6.1.2（ChangeNotifier + ViewModel）
- 网络：[http](https://pub.dev/packages/http) ^1.2.2
- 设计语言：白底金色（Material 3，Light 主题）

## 架构概览

采用 **Clean Architecture 分层** 架构，与后端呼应，关注点分离：

```
UI 事件
   │
   ▼
ui/                          表现层
   pages/<模块>/              页面：组装 widgets，转发事件给 ViewModel
   widgets/                  可复用组件 + 页面私有组件
   theme/                    主题与颜色
   │  Widget 只做 UI 组装，不写业务逻辑
   ▼
state/                       状态层（ViewModel）
   auth_view_model.dart      AuthViewModel + AuthState（ChangeNotifier）
   │  持有状态，编排 domain 服务，UI 通过 Provider 订阅
   ▼
domain/                      领域层（纯 Dart，不依赖 Flutter / http）
   entities/                 领域实体（User、AuthToken、LoginResult）
   repositories/             仓库抽象（AuthRepository）
   services/                 服务抽象 + 默认实现（AuthService）
   utils/                    校验工具（phone.dart）
   │  定义契约，不依赖具体实现
   ▼
data/                        数据层
   models/                  DTO（与后端响应字段对齐）
   repositories/            仓库实现（RestAuthRepository 调 HTTP）
   │  实现 domain 抽象，把 DTO 映射为领域实体
   ▼
core/                        基础设施
   config.dart              全局配置（baseUrl、接口路径）
   errors.dart              统一错误类型（sealed AppException）
   result.dart              Result<T> 包装（成功/失败）
   http/api_client.dart     HTTP 客户端封装
```

### 依赖注入

在 [app.dart](lib/app.dart) 通过 `MultiProvider` 装配：

``ApiClient → AuthRepository → AuthService → AuthViewModel``

UI 通过 `context.watch<AuthViewModel>()` 拿状态，通过 `context.read<AuthViewModel>().login()` 调方法，不直接接触 service / repository。

### 扩展指引

- **新增功能模块**：在 `domain/` 定义实体与抽象 → `data/` 实现 → `state/` 加 ViewModel → `ui/pages/` 加页面。
- **替换数据源（如 GraphQL）**：实现 `AuthRepository`，在 [app.dart](lib/app.dart) 替换 Provider 即可，UI 与 domain 不动。
- **替换状态管理（如 Riverpod / Bloc）**：只需替换 `state/` 层实现，domain / data 不动。
- **替换 HTTP 库（如 dio）**：只需改 `core/http/api_client.dart`，上层不动。

## 目录结构

```
si_land_client/
├── lib/
│   ├── main.dart                          # 入口
│   ├── app.dart                           # MaterialApp + 主题 + Provider 装配
│   ├── core/
│   │   ├── config.dart
│   │   ├── errors.dart
│   │   ├── result.dart
│   │   └── http/api_client.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── api_response.dart
│   │   │   ├── sms.dart
│   │   │   └── user.dart
│   │   └── repositories/
│   │       └── auth_repository_impl.dart
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart
│   │   │   └── auth.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── services/
│   │   │   ├── auth_service.dart
│   │   │   └── auth_service_impl.dart
│   │   └── utils/phone.dart
│   ├── state/
│   │   └── auth_view_model.dart
│   └── ui/
│       ├── theme/app_theme.dart
│       └── pages/
│           └── login/
│               ├── login_page.dart
│               └── widgets/
│                   ├── login_header.dart
│                   ├── phone_field.dart
│                   ├── code_field.dart
│                   ├── send_code_button.dart
│                   ├── login_button.dart
│                   └── agreement.dart
├── test/
│   └── widget_test.dart                   # 登录页冒烟测试（注入 mock AuthService）
└── pubspec.yaml
```

## 登录页功能

- 手机号输入：11 位数字，自动过滤非数字字符
- 手机号校验：正则 `^1[3-9]\d{9}$`（覆盖 13x-19x 全号段）
- 验证码输入：4–6 位数字
- 获取验证码：60 秒倒计时，倒计时中按钮置灰
- 登录按钮：手机号、验证码均有效并勾选用户协议后激活
- 网络异常、业务错误统一通过 SnackBar 提示
- 设计风格：白底金色，按钮无图标
- 文案：主动语态（"进入硅基星球" / "使用手机号验证码即可继续"）

## 快速开始

### 1. 安装依赖

```bash
flutter pub get
```

### 2. 启动后端 mock 服务

参见 [../si_land_server/README.md](../si_land_server/README.md)，默认监听 `http://127.0.0.1:8080`。

### 3. 配置后端地址

默认 `lib/core/config.dart` 中 `baseUrl` 为 `http://127.0.0.1:8080`，可通过启动参数覆盖：

```bash
# iOS 模拟器
flutter run --dart-define=BASE_URL=http://127.0.0.1:8080

# Android 模拟器（宿主机服务需用 10.0.2.2）
flutter run --dart-define=BASE_URL=http://10.0.2.2:8080

# 真机调试（替换为你的本机局域网 IP）
flutter run --dart-define=BASE_URL=http://192.168.1.100:8080
```

### 4. 运行

```bash
flutter run
```

### 5. 测试

```bash
flutter test
```

测试使用 mock `AuthService` 注入，不依赖真实网络。

## Mock 验证码

当前后端为 mock 实现，固定验证码为 `1234`，输入任意 11 位手机号点击「获取验证码」后，用 `1234` 登录即可。

## 后续路线

- [ ] token 持久化（flutter_secure_storage）
- [ ] 全局用户状态（AuthStore）
- [ ] 路由模块化（go_router）+ 鉴权守卫
- [ ] 国际化与多语言
- [ ] 主题深浅色切换
