/// 手机号校验
///
/// 规则：1 开头、第二位 3-9、共 11 位数字。
/// 覆盖现有全部号段（13x-19x，含 192/195/196/197/198/199 等新号段）。
final RegExp phoneRegex = RegExp(r'^1[3-9]\d{9}$');

/// 校验手机号格式
bool isValidPhone(String phone) => phoneRegex.hasMatch(phone);
