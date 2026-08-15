import 'package:shared_preferences/shared_preferences.dart';

/// Token 本地持久化
///
/// 仅持久化 JWT 与过期时间，用户信息不持久化（每次启动通过 /auth/me 获取最新）。
/// 实现简单可靠，无加密（生产环境如需加密可用 flutter_secure_storage 替换）。
class AuthStorage {
  AuthStorage._(this._prefs);

  static const _kToken = 'auth_token';
  static const _kExpiresAt = 'auth_expires_at';

  final SharedPreferences _prefs;

  /// 初始化（需在 runApp 前调用）
  static Future<AuthStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthStorage._(prefs);
  }

  /// 保存 token 与过期时间
  Future<void> save(String token, int expiresAt) async {
    await _prefs.setString(_kToken, token);
    await _prefs.setInt(_kExpiresAt, expiresAt);
  }

  /// 读取 token（未保存或已过期返回 null）
  String? read() {
    final token = _prefs.getString(_kToken);
    final expiresAt = _prefs.getInt(_kExpiresAt) ?? 0;
    if (token == null || token.isEmpty) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt <= now) return null;
    return token;
  }

  /// 清除 token
  Future<void> clear() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kExpiresAt);
  }
}
