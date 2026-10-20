import 'package:flutter/material.dart';
import '../theme/app_colors_data.dart';
import '../theme/theme_manager.dart';

/// `UI` 常量
///
/// `AppColors`：所有颜色均为动态 getter，从 `ThemeManager` 读取当前主题。
/// 当 `ThemeManager` 切换主题时，`Consumer<ThemeManager>` 会让整棵 `Widget` 树重建，
/// 所有 `AppColors.xxx` 自动应用新主题色。
///
/// 注意：所有使用 AppColors 的位置必须**不能带 const**，
/// 例如 const Color(AppColors.primary) ❌ → AppColors.primary ✅
class AppColors {
  AppColors._();

  static AppColorsData get _data => ThemeManager.instance.current;

  static Color get primary => _data.primary;
  static Color get primaryLight => _data.primaryLight;
  static Color get primaryDark => _data.primaryDark;
  static Color get cardBlue => _data.cardBlue;
  static Color get cardBlueLight => _data.cardBlueLight;
  static Color get cardBlueGradientEnd => _data.cardBlueGradientEnd;
  static Color get background => _data.background;
  static Color get surface => _data.surface;
  static Color get income => _data.income;
  static Color get textPrimary => _data.textPrimary;
  static Color get textSecondary => _data.textSecondary;
  static Color get textTertiary => _data.textTertiary;
  static Color get divider => _data.divider;
  static Color get expense => _data.expense;

  /// 便捷访问当前主题数据
  static AppColorsData get current => _data;
}

/// AppTheme 便捷访问
class AppTheme {
  AppTheme._();

  /// 当前主题颜色数据
  static AppColorsData get data => ThemeManager.instance.current;

  /// 从 BuildContext 获取 ThemeExtension（与 ThemeData 集成）
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>()!;
  }
}

class AppDimensions {
  static const cardRadius = 16.0;
  static const cardPadding = 16.0;
  static const pagePadding = 16.0;
  static const iconSizeSm = 20.0;
  static const iconSizeMd = 24.0;
  static const iconSizeLg = 32.0;
}

class AppTextStyles {
  // 注意：TextStyle 是动态构造的（因为 color 依赖当前主题）
  static TextStyle get title => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  static TextStyle get headline => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  static TextStyle get headlineLarge => TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
  static TextStyle get body => TextStyle(
        fontSize: 16,
        color: AppColors.textPrimary,
      );
  static TextStyle get bodySmall => TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
      );
  static TextStyle get caption => TextStyle(
        fontSize: 12,
        color: AppColors.textTertiary,
      );
  // 白色金额样式（不受主题影响）
  static const moneyLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static const moneyMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const moneySmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );
  static TextStyle get expenseAmount => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}
