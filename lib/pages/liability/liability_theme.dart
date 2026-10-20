import 'package:flutter/material.dart';

import '../../ui_constants.dart';

/// 负债模块业务色：深浅主题各一套色值
///
/// 浅色主题用 500-700 级别（饱和度高），深色主题用 200-400 级别（明度高，避免对比度不足）。
/// 全部为 getter，每次访问从 [AppColors] 读取当前主题，主题切换后自动生效。
class DebtColors {
  DebtColors._();

  static bool get _isDark => AppColors.current.isDark;

  /// 逾期 / 待还风险红
  static Color get danger => _isDark ? const Color(0xFFF87171) : const Color(0xFFFF6B6B);

  /// 风险红渐变
  static List<Color> get dangerGradient =>
      _isDark ? const [Color(0xFFEF4444), Color(0xFFF87171)] : const [Color(0xFFFF6B6B), Color(0xFFFF8E8E)];

  /// 已还 / 结清绿
  static Color get success => _isDark ? const Color(0xFF34D399) : const Color(0xFF10B981);

  /// 待还提醒橙
  static Color get warning => _isDark ? const Color(0xFFFBBF24) : const Color(0xFFFF9800);

  /// 本月待还渐变橙
  static List<Color> get warningGradient =>
      _isDark ? const [Color(0xFFF59E0B), Color(0xFFFB923C)] : const [Color(0xFFFF7043), Color(0xFFFF5722)];

  /// 统计蓝渐变
  static List<Color> get infoGradient =>
      _isDark ? const [Color(0xFF60A5FA), Color(0xFF3B82F6)] : const [Color(0xFF4A90E2), Color(0xFF357ABD)];

  /// 按钮禁用态渐变（浅色用中性灰，深色用偏暗的灰以保留按钮轮廓）
  static List<Color> get disabledGradient =>
      _isDark ? const [Color(0xFF3F3F46), Color(0xFF52525B)] : const [Color(0xFFE0E0E0), Color(0xFFBDBDBD)];

  /// 按负债类型取标识色
  static Color typeColor(String type) {
    switch (type) {
      case 'mortgage':
        return _isDark ? const Color(0xFF38BDF8) : const Color(0xFF0EA5E9);
      case 'car_loan':
        return _isDark ? const Color(0xFF4ADE80) : const Color(0xFF22C55E);
      case 'installment':
        return _isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
      case 'personal':
        return _isDark ? const Color(0xFFC084FC) : const Color(0xFFA855F7);
      case 'other':
        return _isDark ? const Color(0xFF2DD4BF) : const Color(0xFF14B8A6);
      case 'credit_card':
      default:
        return _isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
    }
  }

  /// 按负债类型取渐变色（深色主题整体提亮，保证深底上的层次）
  static List<Color> typeGradient(String type) {
    final base = typeColor(type);
    return [base, Color.lerp(base, Colors.white, _isDark ? 0.25 : 0.15)!];
  }
}

/// 负债类型配置
class LiabilityTypeConfig {
  final String value;
  final String label;
  final IconData icon;
  final String description;

  const LiabilityTypeConfig({
    required this.value,
    required this.label,
    required this.icon,
    required this.description,
  });

  /// 类型标识色，跟随主题切换
  Color get color => DebtColors.typeColor(value);

  /// 类型渐变色，跟随主题切换
  List<Color> get gradient => DebtColors.typeGradient(value);
}

/// 负债类型配置表
const List<LiabilityTypeConfig> liabilityTypeConfigs = [
  LiabilityTypeConfig(
    value: 'credit_card',
    label: '信用卡',
    icon: Icons.credit_card,
    description: '信用卡账单',
  ),
  LiabilityTypeConfig(
    value: 'mortgage',
    label: '房贷',
    icon: Icons.home,
    description: '房屋贷款',
  ),
  LiabilityTypeConfig(
    value: 'car_loan',
    label: '车贷',
    icon: Icons.directions_car,
    description: '汽车贷款',
  ),
  LiabilityTypeConfig(
    value: 'installment',
    label: '消费分期',
    icon: Icons.payments,
    description: '分期付款',
  ),
  LiabilityTypeConfig(
    value: 'personal',
    label: '私人借款',
    icon: Icons.person,
    description: '向个人借款',
  ),
  LiabilityTypeConfig(
    value: 'other',
    label: '月付信贷',
    icon: Icons.account_balance,
    description: '其他信贷机构月付',
  ),
];

/// 根据类型获取配置
LiabilityTypeConfig getTypeConfig(String type) {
  return liabilityTypeConfigs.firstWhere(
    (c) => c.value == type,
    orElse: () => liabilityTypeConfigs.first,
  );
}

/// 根据类型获取图标
IconData getTypeIcon(String type) {
  return getTypeConfig(type).icon;
}

/// 根据类型获取颜色
Color getTypeColor(String type) {
  return getTypeConfig(type).color;
}

/// 根据类型获取名称
String getTypeName(String type) {
  return getTypeConfig(type).label;
}
