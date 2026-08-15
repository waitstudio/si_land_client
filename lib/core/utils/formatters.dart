/// 字符串脱敏 / 格式化工具
class Formatters {
  Formatters._();

  /// 手机号脱敏：保留前 3 后 4，中间 4 位替换为 *
  ///
  /// 例：13812345678 → 138****5678
  /// 长度不足 7 时原样返回（短号等异常情况）
  static String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4)}';
  }

  /// 抖音号脱敏：仅用于"我的"页等不需要完整号的场景，目前保留原样
  static String maskDouyinId(String id) => id;
}
