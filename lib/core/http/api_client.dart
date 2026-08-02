import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../errors.dart';
import '../result.dart';

/// HTTP 客户端封装
///
/// 统一处理：
/// - 请求构造（baseUrl + path + headers）
/// - JSON 序列化 / 反序列化
/// - 网络异常归并为 [AppException]
///
/// 业务层通过 [ApiClient] 调用，不直接接触 http 包。
class ApiClient {
  ApiClient({http.Client? client, Duration? timeout})
      : _client = client ?? http.Client(),
        _timeout = timeout ?? const Duration(seconds: 15);

  final http.Client _client;
  final Duration _timeout;

  /// POST JSON 请求，返回响应体（已解析为 Map）。
  ///
  /// 网络失败抛 [NetworkError]，解析失败抛 [ParseError]。
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    try {
      final res = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
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

  /// 释放底层 client
  void close() => _client.close();

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
