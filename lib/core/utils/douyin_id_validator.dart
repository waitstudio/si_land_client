import '../config.dart';

/// 抖音号校验（与后端 validate_douyin_id 对齐）
///
/// 抖音官方号支持 2-20 位字母/数字/下划线/连字符，
/// 但禁止 URL 特征字符（:/?#&=）以防止用户粘贴链接或分享口令。
class DouyinIdValidator {
  DouyinIdValidator._();

  static final RegExp _urlChars = RegExp(r'[/ :?#&=]');

  /// 返回 null 表示合法，否则返回错误文案
  static String? validate(String v) {
    final t = v.trim();
    if (t.isEmpty) return null;
    if (t.length < AppConstants.douyinIdMinLength ||
        t.length > AppConstants.douyinIdMaxLength) {
      return '抖音号长度需为 ${AppConstants.douyinIdMinLength}-${AppConstants.douyinIdMaxLength} 位';
    }
    if (_urlChars.hasMatch(t)) {
      return '请输入抖音号，不要粘贴链接或分享口令';
    }
    return null;
  }

  static bool isValid(String v) => validate(v) == null && v.trim().isNotEmpty;
}
