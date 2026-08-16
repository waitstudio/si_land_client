import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token 本地持久化
///
/// 仅持久化 JWT 与过期时间，用户信息不持久化（每次启动通过 /auth/me 获取最新）。
class AuthStorage {
  AuthStorage._(this._storage);

  static const _kToken = 'auth_token';
  static const _kExpiresAt = 'auth_expires_at';

  final FlutterSecureStorage _storage;

  /// 初始化（需在 runApp 前调用）
  static Future<AuthStorage> create() async {
    return AuthStorage._(const FlutterSecureStorage());
  }

  /// 保存 token 与过期时间
  Future<void> save(String token, int expiresAt) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kExpiresAt, value: '$expiresAt');
  }

  /// 读取 token（未保存或已过期返回 null）
  Future<String?> read() async {
    final token = await _storage.read(key: _kToken);
    final expiresAt = int.tryParse(await _storage.read(key: _kExpiresAt) ?? '') ?? 0;
    if (token == null || token.isEmpty) return null;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt <= now) {
      await clear();
      return null;
    }
    return token;
  }

  /// 清除 token
  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kExpiresAt);
  }
}
