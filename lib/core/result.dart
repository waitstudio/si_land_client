import 'errors.dart';

/// Result 包装：显式区分成功与失败，避免抛异常的隐式控制流
///
/// 用法：
/// ```dart
/// final result = await repo.login(phone, code);
/// switch (result) {
///   case Success(:final data):
///     // 处理成功
///   case Failure(:final error):
///     // 处理失败
/// }
/// ```
sealed class Result<T> {
  const Result();
}

/// 成功
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// 失败
class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

/// 便利构造：从异步操作构造 Result
Future<Result<T>> guardAsync<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } catch (e) {
    return Failure(toAppException(e));
  }
}
