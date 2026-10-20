import 'package:flutter/material.dart';
import '../ui_constants.dart';

/// 选择器弹窗公共组件
///
/// 把 BankSelector 和 CreditInstitutionSelector 共用的视觉部分抽出来，
/// 避免在两个文件里复制粘贴同一套 UI 代码。所有颜色跟随 AppColors，
/// 不写 const 冻结，确保主题切换实时刷新。

/// 解析十六进制颜色（"#RRGGBB" 或 "#AARRGGBB"）
Color parseHexColor(String hex, {Color fallback = const Color(0xFF1677FF)}) {
  try {
    var v = hex.replaceFirst('#', '');
    if (v.length == 6) v = 'FF$v';
    return Color(int.parse('0x$v'));
  } catch (_) {
    return fallback;
  }
}

/// 从字符串名称解析 Material Icon
/// 兼容以下来源：
/// - 标准 icon name：credit_card / payments / account_balance 等
/// - 已经写入的 emoji：🏦 💳 💰 等（直接展示为文字）
IconData resolveSelectorIcon(String name) {
  const map = <String, IconData>{
    'account_balance': Icons.account_balance,
    'account_balance_wallet': Icons.account_balance_wallet,
    'payments': Icons.payments,
    'credit_card': Icons.credit_card,
    'wallet': Icons.account_balance_wallet,
    'shopping_cart': Icons.shopping_cart,
    'shopping_bag': Icons.shopping_bag,
    'savings': Icons.savings,
    'payments_outlined': Icons.payments_outlined,
    'payment': Icons.payment,
  };
  return map[name] ?? Icons.category;
}

/// emoji 还是 icon（数据库 icon 字段可能是 emoji 也可能是 icon name）
/// 返回值若为 null 表示是 emoji（用 Text 渲染）；非 null 表示是 IconData
IconData? iconDataOrNull(String name) {
  if (name.isEmpty) return null;
  final first = name.runes.isNotEmpty ? name.runes.first : 0;
  // emoji 通常在 0x1F300+ 或 0x2000+ 范围
  if (first > 0x2000) return null;
  return resolveSelectorIcon(name);
}

/// 选择器顶部 Header：渐变色背景 + 标题 + 关闭按钮
class SelectorSheetHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onClose;

  const SelectorSheetHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onClose,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.current.isDark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [accentColor.withValues(alpha: 0.85), accentColor.withValues(alpha: 0.55)]
              : [accentColor, accentColor.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部拖拽条
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Material(
                color: Colors.white.withValues(alpha: 0.2),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onClose,
                  child: const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 选择器搜索框（带阴影 + 聚焦边框）
class SelectorSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const SelectorSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!AppColors.current.isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            prefixIcon: Icon(Icons.search, color: AppColors.textTertiary, size: 20),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(Icons.close, size: 18, color: AppColors.textTertiary),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                );
              },
            ),
            filled: true,
            fillColor: AppColors.surface,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
        ),
      ),
    );
  }
}

/// 渐变图标圆形徽章
///
/// [icon] 既可以是 IconData 也可以是 emoji（用 String 传入，自动判断）。
/// [color] 作为渐变起点色；终点色由主题和深浅决定。
class GradientIconBadge extends StatelessWidget {
  final Color color;
  final String? iconName;
  final IconData? iconData;
  final double size;

  const GradientIconBadge({
    super.key,
    required this.color,
    this.iconName,
    this.iconData,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.current.isDark;
    final lightenAmount = isDark ? 0.3 : 0.18;
    final gradient = LinearGradient(
      colors: [color, Color.lerp(color, Colors.white, lightenAmount)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Widget child;
    final data = iconData ?? iconDataOrNull(iconName ?? '');
    if (data != null) {
      child = Icon(data, color: Colors.white, size: size * 0.5);
    } else {
      child = Text(
        iconName ?? '',
        style: TextStyle(fontSize: size * 0.5),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.5 : 0.32),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

/// 选择器列表项
///
/// 左侧渐变图标 + 中间名称/副标题 + 右侧选中钩；选中态整张卡片有浅色背景 + 左侧主色高亮条。
class SelectorListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? codeBadge; // 单色背景的小标签（如银行代码）
  final Color accentColor;
  final String? iconName;
  final IconData? iconData;
  final bool selected;
  final VoidCallback onTap;

  const SelectorListItem({
    super.key,
    required this.title,
    required this.accentColor,
    required this.onTap,
    this.subtitle,
    this.codeBadge,
    this.iconName,
    this.iconData,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              if (selected)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    GradientIconBadge(
                      color: accentColor,
                      iconName: iconName,
                      iconData: iconData,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (codeBadge != null && codeBadge!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.divider,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    codeBadge!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (subtitle != null && subtitle!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedScale(
                      scale: selected ? 1 : 0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(Icons.check_circle,
                          color: AppColors.primary, size: 22),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分类标题（左侧 4px 主色条 + 加粗文字）
class CategorySectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const CategorySectionHeader({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 空状态：图标 + 标题 + 副标题 + "添加 XXX" 大按钮
class SelectorEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String addLabel;
  final VoidCallback onAdd;

  const SelectorEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.addLabel,
    required this.onAdd,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: Text(addLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 列表底部"添加 XXX"卡片（搜索有部分结果时）
class SelectorAddInlineTile extends StatelessWidget {
  final String keyword;
  final VoidCallback onTap;

  const SelectorAddInlineTile({
    super.key,
    required this.keyword,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.add_circle, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '添加 "$keyword"',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
