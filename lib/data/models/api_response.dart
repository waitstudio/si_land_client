/// 统一响应体
class ApiResponse<T> {
  final int code;
  final String msg;
  final T? data;

  ApiResponse({
    required this.code,
    required this.msg,
    this.data,
  });

  bool get isSuccess => code == 0;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromData,
  ) {
    return ApiResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] == null ? null : fromData(json['data']),
    );
  }
}
