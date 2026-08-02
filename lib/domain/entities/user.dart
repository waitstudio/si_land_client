/// 用户领域实体
///
/// 与 DTO 解耦：未来 DTO 字段变化时，只需调整映射，领域层与 UI 不受影响。
class User {
  final String userId;
  final String phone;
  final String nickname;
  final String avatar;

  const User({
    required this.userId,
    required this.phone,
    required this.nickname,
    required this.avatar,
  });
}
