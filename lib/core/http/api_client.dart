import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../auth/auth_storage.dart';
import '../config.dart';
import '../errors.dart';
import '../result.dart';

/// HTTP 客户端封装
///
/// 统一处理：
/// - 请求构造（baseUrl + path + headers + 自动注入 Authorization）
/// - JSON 序列化 / 反序列化
/// - 网络异常归并为 [AppException]
///
/// 业务层通过 [ApiClient] 调用，不直接接触 http 包。
class ApiClient {
  ApiClient({http.Client? client, Duration? timeout, AuthStorage? authStorage})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15),
        _authStorage = authStorage;

  final http.Client _client;
  final Duration _timeout;
  final AuthStorage? _authStorage;

  /// POST JSON 请求，返回响应体（已解析为 Map）。
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .post(
            uri,
            headers: await _buildHeaders(auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res.body);
    } on SocketException {
      throw NetworkError();
    } on TimeoutException {
      throw NetworkError('请求超时，请稍后再试');
    }
  }

  /// GET 请求，返回响应体（已解析为 Map）。
  Future<Map<String, dynamic>> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .get(uri, headers: await _buildHeaders(auth))
          .timeout(_timeout);
      return _decode(res.body);
    } on SocketException {
      throw NetworkError();
    } on TimeoutException {
      throw NetworkError('请求超时，请稍后再试');
    }
  }

  /// PUT JSON 请求，返回响应体（已解析为 Map）。
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .put(
            uri,
            headers: await _buildHeaders(auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout);
      return _decode(res.body);
    } on SocketException {
      throw NetworkError();
    } on TimeoutException {
      throw NetworkError('请求超时，请稍后再试');
    }
  }

  /// DELETE 请求，返回响应体（已解析为 Map）。
  Future<Map<String, dynamic>> delete(String path, {bool auth = true}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .delete(uri, headers: await _buildHeaders(auth))
          .timeout(_timeout);
      return _decode(res.body);
    } on SocketException {
      throw NetworkError();
    } on TimeoutException {
      throw NetworkError('请求超时，请稍后再试');
    }
  }

  /// 释放底层 client
  void close() => _client.close();

  Future<Map<String, String>> _buildHeaders(bool auth) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth && _authStorage != null) {
      final token = _authStorage.read();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Map<String, dynamic> _decode(String body) {
    if (body.isEmpty) throw const ParseError('空响应');
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ParseError('响应非 JSON 对象');
    }
    return decoded;
  }
}

/// 把 Result 转成可读的 message（用于 UI 提示）
String resultMessage<T>(Result<T> result) {
  return switch (result) {
    Success<T>() => '',
    Failure<T>(:final error) => error.message,
  };
}
