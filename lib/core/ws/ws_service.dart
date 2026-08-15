import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';

/// WebSocket 长连接服务
///
/// 职责：连接管理、应用层心跳、断线指数退避重连。
/// 消息语义（协议见后端 `api/v1/app/ws/mod.rs`）：
/// - 收到 `{"type":"notice","data":{...}}` → [onNotice]
/// - 收到 `{"type":"unread","data":{"count":n}}` → [onUnread]
/// - 握手 401（token 失效）→ [onAuthFailed]，停止重连
///
/// UI 层（弹窗/红点）不在此处理，由上层（如 WsGate）通过回调编排。
class WsService {
  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  Timer? _heartbeat;
  Timer? _reconnectTimer;

  String? _token;
  int _retry = 0;
  bool _wantConnect = false;
  bool _authFailed = false;

  /// 当前是否已建立连接（hello 收到即视为连通）
  bool get isConnected => _channel != null;

  /// 收到实时开播通知（data 为 notice 字段 Map）
  void Function(Map<String, dynamic> data)? onNotice;

  /// 收到权威未读数（连接建立/新通知后由服务端下发）
  void Function(int count)? onUnread;

  /// 握手鉴权失败（token 失效），已停止重连，需重新登录
  void Function()? onAuthFailed;

  /// 建立连接（幂等：已连接则跳过；token 变化时重连）
  void connect(String token) {
    if (_channel != null && token == _token) return;
    _token = token;
    _authFailed = false;
    _wantConnect = true;
    _retry = 0;
    _reconnectTimer?.cancel();
    _open();
  }

  /// 主动断开并停止重连（登出/销毁时调用）
  void disconnect() {
    _wantConnect = false;
    _token = null;
    _retry = 0;
    _authFailed = false;
    _teardown();
  }

  /// 回到前台：若已断线则跳过退避等待立即重连
  void resume() {
    if (!_wantConnect || _channel != null || _token == null || _authFailed) {
      return;
    }
    _reconnectTimer?.cancel();
    _open();
  }

  void _open() {
    final token = _token;
    if (token == null) return;
    final channel = WebSocketChannel.connect(Uri.parse(ApiConfig.wsUrl(token)));
    _channel = channel;

    _sub = channel.stream.listen(
      (data) => _onMessage(data.toString()),
      onError: (_) => _scheduleReconnect(),
      onDone: () => _scheduleReconnect(),
      cancelOnError: true,
    );

    _startHeartbeat();
  }

  void _onMessage(String text) {
    Map<String, dynamic> msg;
    try {
      msg = jsonDecode(text) as Map<String, dynamic>;
    } catch (_) {
      return; // 非 JSON 文本忽略
    }
    final type = msg['type'] as String?;
    final data = msg['data'];
    switch (type) {
      case 'hello':
        _retry = 0; // 连通即重置退避
        break;
      case 'notice':
        if (data is Map<String, dynamic>) onNotice?.call(data);
        break;
      case 'unread':
        final count = (data is Map<String, dynamic>)
            ? (data['count'] as num?)?.toInt() ?? 0
            : 0;
        onUnread?.call(count);
        break;
      case 'auth_failed':
        _authFailed = true;
        _wantConnect = false;
        _teardown();
        onAuthFailed?.call();
        break;
      default:
        break; // pong 等
    }
  }

  /// 应用层心跳：服务端 90s 空闲超时，客户端 30s 一跳
  void _startHeartbeat() {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(
      const Duration(seconds: AppConstants.wsHeartbeatSeconds),
      (_) => _sendPing(),
    );
  }

  void _sendPing() {
    final ch = _channel;
    if (ch == null) return;
    try {
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      ch.sink.add('{"type":"ping","ts":$ts}');
    } catch (_) {
      // sink 已关闭，交给 onDone 触发重连
    }
  }

  /// 断线重连：指数退避 1s → 2s → 4s ... 上限 60s
  void _scheduleReconnect() {
    _teardown();
    if (!_wantConnect || _authFailed) return;

    final delay = (AppConstants.wsReconnectBaseDelaySeconds << _retry)
        .clamp(0, AppConstants.wsReconnectMaxDelaySeconds);
    _retry = (_retry + 1).clamp(0, 6);
    _reconnectTimer = Timer(Duration(seconds: delay), _open);
  }

  void _teardown() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
  }
}
