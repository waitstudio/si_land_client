/// 发送验证码响应
class SendSmsDto {
  final String phone;
  final int expireIn;

  SendSmsDto({required this.phone, required this.expireIn});

  factory SendSmsDto.fromJson(Map<String, dynamic> json) {
    return SendSmsDto(
      phone: json['phone'] as String,
      expireIn: json['expire_in'] as int,
    );
  }
}
