/// 用户信息 DTO（与后端响应字段对齐）
class UserDto {
  final String userId;
  final String phone;
  final String nickname;
  final String avatar;

  UserDto({
    required this.userId,
    required this.phone,
    required this.nickname,
    required this.avatar,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['user_id'] as String,
      phone: json['phone'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String? ?? '',
    );
  }
}

/// 登录响应 DTO
class LoginResultDto {
  final String token;
  final String tokenType;
  final int expiresAt;
  final UserDto user;

  LoginResultDto({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  factory LoginResultDto.fromJson(Map<String, dynamic> json) {
    return LoginResultDto(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      expiresAt: json['expires_at'] as int,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
