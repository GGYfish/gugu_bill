import 'package:flutter/material.dart';

/// 主题颜色数据（不可变快照）
class AppColorsData {
  final String id;
  final String name;
  final String? emoji;
  // 主色系
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  // 卡片渐变
  final Color cardBlue;
  final Color cardBlueLight;
  final Color cardBlueGradientEnd;
  // 背景与表面
  final Color background;
  final Color surface;
  // 收入支出
  final Color income;
  final Color expense;
  // 文字
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  // 分割线
  final Color divider;
  // 是否深色主题
  final bool isDark;

  const AppColorsData({
    required this.id,
    required this.name,
    this.emoji,
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.cardBlue,
    required this.cardBlueLight,
    required this.cardBlueGradientEnd,
    required this.background,
    required this.surface,
    required this.income,
    required this.expense,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    this.isDark = false,
  });

  AppColorsData copyWith({
    String? id,
    String? name,
    String? emoji,
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? cardBlue,
    Color? cardBlueLight,
    Color? cardBlueGradientEnd,
    Color? background,
    Color? surface,
    Color? income,
    Color? expense,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    bool? isDark,
  }) {
    return AppColorsData(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      cardBlue: cardBlue ?? this.cardBlue,
      cardBlueLight: cardBlueLight ?? this.cardBlueLight,
      cardBlueGradientEnd: cardBlueGradientEnd ?? this.cardBlueGradientEnd,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      isDark: isDark ?? this.isDark,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'primary': primary.toARGB32(),
        'primaryLight': primaryLight.toARGB32(),
        'primaryDark': primaryDark.toARGB32(),
        'cardBlue': cardBlue.toARGB32(),
        'cardBlueLight': cardBlueLight.toARGB32(),
        'cardBlueGradientEnd': cardBlueGradientEnd.toARGB32(),
        'background': background.toARGB32(),
        'surface': surface.toARGB32(),
        'income': income.toARGB32(),
        'expense': expense.toARGB32(),
        'textPrimary': textPrimary.toARGB32(),
        'textSecondary': textSecondary.toARGB32(),
        'textTertiary': textTertiary.toARGB32(),
        'divider': divider.toARGB32(),
        'isDark': isDark,
      };

  factory AppColorsData.fromJson(Map<String, dynamic> json) => AppColorsData(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String?,
        primary: Color(json['primary'] as int),
        primaryLight: Color(json['primaryLight'] as int),
        primaryDark: Color(json['primaryDark'] as int),
        cardBlue: Color(json['cardBlue'] as int),
        cardBlueLight: Color(json['cardBlueLight'] as int),
        cardBlueGradientEnd: Color(json['cardBlueGradientEnd'] as int),
        background: Color(json['background'] as int),
        surface: Color(json['surface'] as int),
        income: Color(json['income'] as int),
        expense: Color(json['expense'] as int),
        textPrimary: Color(json['textPrimary'] as int),
        textSecondary: Color(json['textSecondary'] as int),
        textTertiary: Color(json['textTertiary'] as int),
        divider: Color(json['divider'] as int),
        isDark: (json['isDark'] as bool?) ?? false,
      );
}

/// 内置主题预设
class AppPresets {
  /// 默认蓝（原主题）
  static const AppColorsData defaultBlue = AppColorsData(
    id: 'preset_default_blue',
    name: '默认蓝',
    emoji: '🌊',
    primary: Color(0xFF3B82F6),
    primaryLight: Color(0xFF93C5FD),
    primaryDark: Color(0xFF1D4ED8),
    cardBlue: Color(0xFF3B82F6),
    cardBlueLight: Color(0xFFDBEAFE),
    cardBlueGradientEnd: Color(0xFFBFDBFE),
    background: Color(0xFFF3F4F6),
    surface: Colors.white,
    income: Color(0xFF10B981),
    expense: Color(0xFF222222),
    textPrimary: Color(0xFF222222),
    textSecondary: Color(0xFF666666),
    textTertiary: Color(0xFF888888),
    divider: Color(0xFFF0F0F0),
  );

  /// 薄荷绿
  static const AppColorsData mintGreen = AppColorsData(
    id: 'preset_mint_green',
    name: '薄荷绿',
    emoji: '🌿',
    primary: Color(0xFF10B981),
    primaryLight: Color(0xFF6EE7B7),
    primaryDark: Color(0xFF047857),
    cardBlue: Color(0xFF10B981),
    cardBlueLight: Color(0xFFD1FAE5),
    cardBlueGradientEnd: Color(0xFFA7F3D0),
    background: Color(0xFFF3F4F6),
    surface: Colors.white,
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    divider: Color(0xFFE5E7EB),
  );

  /// 樱花粉
  static const AppColorsData cherryPink = AppColorsData(
    id: 'preset_cherry_pink',
    name: '樱花粉',
    emoji: '🌸',
    primary: Color(0xFFEC4899),
    primaryLight: Color(0xFFF9A8D4),
    primaryDark: Color(0xFFBE185D),
    cardBlue: Color(0xFFEC4899),
    cardBlueLight: Color(0xFFFCE7F3),
    cardBlueGradientEnd: Color(0xFFFBCFE8),
    background: Color(0xFFF9FAFB),
    surface: Colors.white,
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    divider: Color(0xFFFCE7F3),
  );

  /// 阳光橙
  static const AppColorsData sunshineOrange = AppColorsData(
    id: 'preset_sunshine_orange',
    name: '阳光橙',
    emoji: '☀️',
    primary: Color(0xFFF59E0B),
    primaryLight: Color(0xFFFCD34D),
    primaryDark: Color(0xFFD97706),
    cardBlue: Color(0xFFF59E0B),
    cardBlueLight: Color(0xFFFEF3C7),
    cardBlueGradientEnd: Color(0xFFFDE68A),
    background: Color(0xFFF9FAFB),
    surface: Colors.white,
    income: Color(0xFF10B981),
    expense: Color(0xFFEF4444),
    textPrimary: Color(0xFF1F2937),
    textSecondary: Color(0xFF6B7280),
    textTertiary: Color(0xFF9CA3AF),
    divider: Color(0xFFFEF3C7),
  );

  /// 暗夜黑
  static const AppColorsData nightBlack = AppColorsData(
    id: 'preset_night_black',
    name: '暗夜黑',
    emoji: '🌙',
    primary: Color(0xFF818CF8),
    primaryLight: Color(0xFFA5B4FC),
    primaryDark: Color(0xFF6366F1),
    cardBlue: Color(0xFF6366F1),
    cardBlueLight: Color(0xFF312E81),
    cardBlueGradientEnd: Color(0xFF4338CA),
    background: Color(0xFF111827),
    surface: Color(0xFF1F2937),
    income: Color(0xFF34D399),
    expense: Color(0xFFF87171),
    textPrimary: Color(0xFFF3F4F6),
    textSecondary: Color(0xFF9CA3AF),
    textTertiary: Color(0xFF6B7280),
    divider: Color(0xFF374151),
    isDark: true,
  );

  /// 所有内置主题
  static const List<AppColorsData> all = [
    defaultBlue,
    mintGreen,
    cherryPink,
    sunshineOrange,
    nightBlack,
  ];
}

/// Flutter ThemeExtension 集成
/// 让 `Theme.of(context).extension<AppColorsExtension>()!` 可访问当前主题颜色
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color cardBlue;
  final Color cardBlueLight;
  final Color cardBlueGradientEnd;
  final Color background;
  final Color surface;
  final Color income;
  final Color expense;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color divider;

  const AppColorsExtension({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.cardBlue,
    required this.cardBlueLight,
    required this.cardBlueGradientEnd,
    required this.background,
    required this.surface,
    required this.income,
    required this.expense,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
  });

  factory AppColorsExtension.fromData(AppColorsData data) {
    return AppColorsExtension(
      primary: data.primary,
      primaryLight: data.primaryLight,
      primaryDark: data.primaryDark,
      cardBlue: data.cardBlue,
      cardBlueLight: data.cardBlueLight,
      cardBlueGradientEnd: data.cardBlueGradientEnd,
      background: data.background,
      surface: data.surface,
      income: data.income,
      expense: data.expense,
      textPrimary: data.textPrimary,
      textSecondary: data.textSecondary,
      textTertiary: data.textTertiary,
      divider: data.divider,
    );
  }

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? cardBlue,
    Color? cardBlueLight,
    Color? cardBlueGradientEnd,
    Color? background,
    Color? surface,
    Color? income,
    Color? expense,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      cardBlue: cardBlue ?? this.cardBlue,
      cardBlueLight: cardBlueLight ?? this.cardBlueLight,
      cardBlueGradientEnd: cardBlueGradientEnd ?? this.cardBlueGradientEnd,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      income: income ?? this.income,
      expense: expense ?? this.expense,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      cardBlue: Color.lerp(cardBlue, other.cardBlue, t)!,
      cardBlueLight: Color.lerp(cardBlueLight, other.cardBlueLight, t)!,
      cardBlueGradientEnd: Color.lerp(cardBlueGradientEnd, other.cardBlueGradientEnd, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// 便捷访问：`Theme.of(context).extension<AppColorsExtension>()!.primary`
extension ThemeColorsContext on BuildContext {
  AppColorsExtension get themeColors =>
      Theme.of(this).extension<AppColorsExtension>()!;
}
