import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/resource_provider.dart';
import '../ui_constants.dart';

// ================================================================
// 数据模型
// ================================================================

/// 分类图标选项
class CategoryIconOption {
  final IconData icon;
  final String name;
  const CategoryIconOption({required this.icon, required this.name});
}

/// 分类颜色选项
class CategoryColorOption {
  final String hex;
  final String name;
  const CategoryColorOption(this.hex, this.name);
}

/// 创建结果（页面 pop 时回传给调用方）
class CategoryCreateResult {
  final String name;
  final String iconName;
  final String colorHex;
  const CategoryCreateResult({
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}

// ================================================================
// 预设数据（不跟随主题：颜色属于用户自定义品牌色，固定色值）
// ================================================================

/// 48 个内置图标（覆盖支出/收入/通用三大类）
const List<CategoryIconOption> kCategoryIcons = [
  // 餐饮 8
  CategoryIconOption(icon: Icons.restaurant, name: '餐饮'),
  CategoryIconOption(icon: Icons.fastfood, name: '快餐'),
  CategoryIconOption(icon: Icons.local_cafe, name: '咖啡'),
  CategoryIconOption(icon: Icons.local_bar, name: '酒水'),
  CategoryIconOption(icon: Icons.restaurant_menu, name: '餐厅'),
  CategoryIconOption(icon: Icons.cake, name: '甜品'),
  CategoryIconOption(icon: Icons.icecream, name: '冷饮'),
  CategoryIconOption(icon: Icons.local_pizza, name: '比萨'),
  // 购物 6
  CategoryIconOption(icon: Icons.shopping_bag, name: '购物'),
  CategoryIconOption(icon: Icons.shopping_cart, name: '日用'),
  CategoryIconOption(icon: Icons.local_grocery_store, name: '生鲜'),
  CategoryIconOption(icon: Icons.checkroom, name: '服装'),
  CategoryIconOption(icon: Icons.diamond, name: '首饰'),
  CategoryIconOption(icon: Icons.pets, name: '宠物'),
  // 交通 6
  CategoryIconOption(icon: Icons.directions_car, name: '交通'),
  CategoryIconOption(icon: Icons.directions_bus, name: '公交'),
  CategoryIconOption(icon: Icons.local_taxi, name: '打车'),
  CategoryIconOption(icon: Icons.subway, name: '地铁'),
  CategoryIconOption(icon: Icons.local_gas_station, name: '加油'),
  CategoryIconOption(icon: Icons.local_parking, name: '停车'),
  // 居家 6
  CategoryIconOption(icon: Icons.home, name: '居家'),
  CategoryIconOption(icon: Icons.bolt, name: '水电'),
  CategoryIconOption(icon: Icons.water_drop, name: '水费'),
  CategoryIconOption(icon: Icons.wifi, name: '网络'),
  CategoryIconOption(icon: Icons.phone_iphone, name: '话费'),
  CategoryIconOption(icon: Icons.build, name: '维修'),
  // 文娱 6
  CategoryIconOption(icon: Icons.sports_esports, name: '游戏'),
  CategoryIconOption(icon: Icons.movie, name: '电影'),
  CategoryIconOption(icon: Icons.music_note, name: '音乐'),
  CategoryIconOption(icon: Icons.menu_book, name: '书籍'),
  CategoryIconOption(icon: Icons.fitness_center, name: '健身'),
  CategoryIconOption(icon: Icons.spa, name: '美容'),
  // 健康教育 5
  CategoryIconOption(icon: Icons.medical_services, name: '药品'),
  CategoryIconOption(icon: Icons.local_hospital, name: '医疗'),
  CategoryIconOption(icon: Icons.school, name: '教育'),
  CategoryIconOption(icon: Icons.edit, name: '学习'),
  CategoryIconOption(icon: Icons.child_friendly, name: '母婴'),
  // 礼物转账 4
  CategoryIconOption(icon: Icons.card_giftcard, name: '礼物'),
  CategoryIconOption(icon: Icons.swap_horiz, name: '转账'),
  CategoryIconOption(icon: Icons.undo, name: '退款'),
  CategoryIconOption(icon: Icons.celebration, name: '节日'),
  // 收入 4
  CategoryIconOption(icon: Icons.payments, name: '工资'),
  CategoryIconOption(icon: Icons.attach_money, name: '收入'),
  CategoryIconOption(icon: Icons.account_balance, name: '银行'),
  CategoryIconOption(icon: Icons.credit_card, name: '信用卡'),
  // 投资理财 2
  CategoryIconOption(icon: Icons.trending_up, name: '投资'),
  CategoryIconOption(icon: Icons.savings, name: '理财'),
  // 通用 1
  CategoryIconOption(icon: Icons.more_horiz, name: '其他'),
];

/// 24 个预设颜色（按色相渐变排列，覆盖完整色环 + 中性灰）
const List<CategoryColorOption> kCategoryColors = [
  // 暖色系
  CategoryColorOption('#F5222D', '鲜红'),
  CategoryColorOption('#FA541C', '朱橙'),
  CategoryColorOption('#FA8C16', '暖橙'),
  CategoryColorOption('#FFA940', '浅橙'),
  CategoryColorOption('#FAAD14', '金黄'),
  CategoryColorOption('#FADB14', '鹅黄'),
  // 绿色系
  CategoryColorOption('#A0D911', '嫩绿'),
  CategoryColorOption('#52C41A', '翠绿'),
  // 蓝青系
  CategoryColorOption('#13C2C2', '青绿'),
  CategoryColorOption('#36CFC9', '天青'),
  CategoryColorOption('#1890FF', '天蓝'),
  CategoryColorOption('#1677FF', '海蓝'),
  CategoryColorOption('#2F54EB', '宝蓝'),
  // 紫色系
  CategoryColorOption('#722ED1', '深紫'),
  CategoryColorOption('#B37FEB', '浅紫'),
  CategoryColorOption('#CB60E2', '紫红'),
  // 粉色系
  CategoryColorOption('#EB2F96', '玫红'),
  CategoryColorOption('#F759AB', '粉红'),
  CategoryColorOption('#FF85C0', '浅粉'),
  // 土色
  CategoryColorOption('#D4B106', '土黄'),
  CategoryColorOption('#874D00', '棕褐'),
  // 中性灰
  CategoryColorOption('#8C8C8C', '中灰'),
  CategoryColorOption('#595959', '深灰'),
  CategoryColorOption('#262626', '炭黑'),
];

// ================================================================
// 公开工具方法
// ================================================================

/// IconData → 入库字符串名
String iconDataToString(IconData iconData) {
  if (iconData == Icons.restaurant) return 'restaurant';
  if (iconData == Icons.fastfood) return 'fastfood';
  if (iconData == Icons.local_cafe) return 'local_cafe';
  if (iconData == Icons.local_bar) return 'local_bar';
  if (iconData == Icons.restaurant_menu) return 'restaurant_menu';
  if (iconData == Icons.cake) return 'cake';
  if (iconData == Icons.icecream) return 'icecream';
  if (iconData == Icons.local_pizza) return 'local_pizza';
  if (iconData == Icons.shopping_bag) return 'shopping_bag';
  if (iconData == Icons.shopping_cart) return 'shopping_cart';
  if (iconData == Icons.local_grocery_store) return 'local_grocery_store';
  if (iconData == Icons.checkroom) return 'checkroom';
  if (iconData == Icons.diamond) return 'diamond';
  if (iconData == Icons.pets) return 'pets';
  if (iconData == Icons.directions_car) return 'directions_car';
  if (iconData == Icons.directions_bus) return 'directions_bus';
  if (iconData == Icons.local_taxi) return 'local_taxi';
  if (iconData == Icons.subway) return 'subway';
  if (iconData == Icons.local_gas_station) return 'local_gas_station';
  if (iconData == Icons.local_parking) return 'local_parking';
  if (iconData == Icons.home) return 'home';
  if (iconData == Icons.bolt) return 'bolt';
  if (iconData == Icons.water_drop) return 'water_drop';
  if (iconData == Icons.wifi) return 'wifi';
  if (iconData == Icons.phone_iphone) return 'phone_iphone';
  if (iconData == Icons.build) return 'build';
  if (iconData == Icons.sports_esports) return 'sports_esports';
  if (iconData == Icons.movie) return 'movie';
  if (iconData == Icons.music_note) return 'music_note';
  if (iconData == Icons.menu_book) return 'menu_book';
  if (iconData == Icons.fitness_center) return 'fitness_center';
  if (iconData == Icons.spa) return 'spa';
  if (iconData == Icons.medical_services) return 'medical_services';
  if (iconData == Icons.local_hospital) return 'local_hospital';
  if (iconData == Icons.school) return 'school';
  if (iconData == Icons.edit) return 'edit';
  if (iconData == Icons.child_friendly) return 'child_friendly';
  if (iconData == Icons.card_giftcard) return 'card_giftcard';
  if (iconData == Icons.swap_horiz) return 'swap_horiz';
  if (iconData == Icons.undo) return 'undo';
  if (iconData == Icons.celebration) return 'celebration';
  if (iconData == Icons.payments) return 'payments';
  if (iconData == Icons.attach_money) return 'attach_money';
  if (iconData == Icons.account_balance) return 'account_balance';
  if (iconData == Icons.credit_card) return 'credit_card';
  if (iconData == Icons.trending_up) return 'trending_up';
  if (iconData == Icons.savings) return 'savings';
  if (iconData == Icons.more_horiz) return 'more_horiz';
  return 'category';
}

/// #RRGGBB → Color（忽略 alpha，默认 FF）
Color hexToColor(String hex) {
  final clean = hex.replaceAll('#', '').toUpperCase();
  if (clean.length != 6) return Colors.grey;
  final value = int.tryParse('FF$clean', radix: 16);
  return value == null ? Colors.grey : Color(value);
}

// ================================================================
// 添加大分类页面
// ================================================================

class AddCategoryPage extends StatelessWidget {
  /// 'expense' / 'income' / 'other'
  final String type;
  final ValueChanged<CategoryCreateResult> onCreated;

  const AddCategoryPage({
    super.key,
    required this.type,
    required this.onCreated,
  });

  String get _typeLabel {
    switch (type) {
      case 'income':
        return '收入';
      case 'other':
        return '其他';
      default:
        return '支出';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _CategoryFormPage(
      appBarTitle: '添加分类',
      subtitle: '为你创建一个新的$_typeLabel分类',
      nameHint: '请输入分类名称',
      onSubmit: (result) async {
        try {
          await context.read<CategoryManagementProvider>().addParentCategory(
                name: result.name,
                type: type,
                icon: result.iconName,
                color: result.colorHex,
              );
          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已添加分类：${result.name}')),
          );
          onCreated(result);
        } catch (e, st) {
          debugPrint('添加分类失败: $e\n$st');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加分类失败：$e')),
          );
        }
      },
    );
  }
}

// ================================================================
// 添加小分类页面
// ================================================================

class AddSubCategoryPage extends StatelessWidget {
  final String parentId;
  final String parentName;
  final String parentColorHex;
  final ValueChanged<CategoryCreateResult> onCreated;

  const AddSubCategoryPage({
    super.key,
    required this.parentId,
    required this.parentName,
    required this.parentColorHex,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context) {
    return _CategoryFormPage(
      appBarTitle: '添加$parentName小分类',
      subtitle: '为「$parentName」新增一个子分类',
      nameHint: '请输入小分类名称',
      defaultColorHex: parentColorHex,
      onSubmit: (result) async {
        try {
          await context.read<CategoryManagementProvider>().addSubCategory(
                parentId: parentId,
                name: result.name,
                icon: result.iconName,
                color: result.colorHex,
              );
          if (!context.mounted) return;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('已添加小分类：${result.name}')),
          );
          onCreated(result);
        } catch (e, st) {
          debugPrint('添加小分类失败: $e\n$st');
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('添加小分类失败：$e')),
          );
        }
      },
    );
  }
}

// ================================================================
// 内部：表单页面（Scaffold + body）
// ================================================================

class _CategoryFormPage extends StatelessWidget {
  final String appBarTitle;
  final String subtitle;
  final String nameHint;
  final String? defaultColorHex;
  final Future<void> Function(CategoryCreateResult) onSubmit;

  const _CategoryFormPage({
    required this.appBarTitle,
    required this.subtitle,
    required this.nameHint,
    required this.onSubmit,
    this.defaultColorHex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(appBarTitle),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _CategoryFormBody(
        subtitle: subtitle,
        nameHint: nameHint,
        defaultColorHex: defaultColorHex,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _CategoryFormBody extends StatefulWidget {
  final String subtitle;
  final String nameHint;
  final String? defaultColorHex;
  final Future<void> Function(CategoryCreateResult) onSubmit;

  const _CategoryFormBody({
    required this.subtitle,
    required this.nameHint,
    required this.onSubmit,
    this.defaultColorHex,
  });

  @override
  State<_CategoryFormBody> createState() => _CategoryFormBodyState();
}

class _CategoryFormBodyState extends State<_CategoryFormBody> {
  static const int _maxLength = 8;

  final _nameController = TextEditingController();
  int _charCount = 0;
  IconData? _selectedIcon;
  late String _selectedColorHex;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _selectedColorHex = widget.defaultColorHex ?? kCategoryColors.first.hex;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _nameController.text.trim().isNotEmpty &&
      _selectedIcon != null &&
      !_submitting;

  String get _previewName =>
      _nameController.text.trim().isEmpty ? '分类名预览' : _nameController.text.trim();

  Future<void> _handleSubmit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final result = CategoryCreateResult(
      name: _nameController.text.trim(),
      iconName: iconDataToString(_selectedIcon!),
      colorHex: _selectedColorHex,
    );
    await widget.onSubmit(result);
    // 失败时 onSubmit 内部会保持页面，由用户重试或取消
    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(_selectedColorHex);
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 2),
                child: Text(
                  widget.subtitle,
                  style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
                ),
              ),
              _CategoryPreviewCard(
                name: _previewName,
                icon: _selectedIcon,
                color: color,
              ),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildIconPicker(),
              const SizedBox(height: 24),
              _buildColorPicker(),
            ],
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '分类名称',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$_charCount/$_maxLength',
              style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          autofocus: false,
          maxLength: _maxLength,
          onChanged: (v) => setState(() => _charCount = v.length),
          decoration: InputDecoration(
            hintText: widget.nameHint,
            hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surface,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '选择图标',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              _selectedIcon == null ? '请选择' : '已选',
              style: TextStyle(
                fontSize: 12,
                color: _selectedIcon == null
                    ? AppColors.textTertiary
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 220, // 约显示 4 行，剩余可上下滑动
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: kCategoryIcons.map((opt) {
                final isSelected = _selectedIcon == opt.icon;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = opt.icon),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Tooltip(
                      message: opt.name,
                      child: Icon(
                        opt.icon,
                        size: 22,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_vert, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              '上下滑动查看更多图标',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    final selectedColor = hexToColor(_selectedColorHex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '选择颜色',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(color: selectedColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  _colorNameOf(_selectedColorHex),
                  style: TextStyle(
                    fontSize: 12,
                    color: selectedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90, // 约显示 2 行，剩余可上下滑动
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kCategoryColors.map((c) {
                final isSelected = _selectedColorHex == c.hex;
                final cColor = hexToColor(c.hex);
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorHex = c.hex),
                  behavior: HitTestBehavior.opaque,
                  child: Tooltip(
                    message: c.name,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: cColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cColor.withValues(alpha: isSelected ? 0.45 : 0.2),
                            blurRadius: isSelected ? 10 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(Icons.check_rounded, size: 18, color: Colors.white)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_vert, size: 12, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              '上下滑动查看更多颜色',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _submitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.divider),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text('取消', style: TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canSubmit ? _handleSubmit : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.divider,
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      '保存分类',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _colorNameOf(String hex) {
    final m = kCategoryColors.where((c) => c.hex == hex).toList();
    return m.isNotEmpty ? m.first.name : '';
  }
}

// ================================================================
// 实时预览卡（左侧大图标 + 右侧名称 + 颜色标识）
// ================================================================

class _CategoryPreviewCard extends StatelessWidget {
  final String name;
  final IconData? icon;
  final Color color;

  const _CategoryPreviewCard({
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final hasIcon = icon != null;
    final hasName = name.isNotEmpty && name != '分类名预览';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.14),
            color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: hasIcon
                  ? color.withValues(alpha: 0.22)
                  : AppColors.divider.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon ?? Icons.help_outline,
              size: 28,
              color: hasIcon ? color : AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hasName ? name : '请输入分类名称',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: hasName ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasIcon ? '已选图标 · 实时预览' : '上方选择图标与颜色',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
