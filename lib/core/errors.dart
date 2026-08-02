/// 统一错误类型
///
/// - [NetworkError]：网络连接失败 / 超时
/// - [ApiError]：后端返回的业务错误（含 code 与 msg）
/// - [ParseError]：响应解析失败
/// - [UnknownError]：其他未预期错误
sealed class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// 网络错误（连接失败 / 超时）
class NetworkError extends AppException {
  const NetworkError([super.message = '网络连接失败，请检查网络']);
}

/// 后端业务错误
class ApiError extends AppException {
  final int code;

  const ApiError({required this.code, required String message})
      : super(message);
}

/// 响应解析失败
class ParseError extends AppException {
  const ParseError([super.message = '响应解析失败']);
}

/// 未预期错误
class UnknownError extends AppException {
  const UnknownError([super.message = '操作失败，请稍后再试']);
}

/// 把任意异常归并到 [AppException]
AppException toAppException(Object e) {
  if (e is AppException) return e;
  if (e is FormatException) return const ParseError();
  return UnknownError(e.toString());
}
