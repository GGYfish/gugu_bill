import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../providers/resource_provider.dart';
import '../ui_constants.dart';
import '../widgets/add_sub_category_dialog.dart';
import '../widgets/common_widgets.dart';

/// 资源管理页面（分类、银行、信贷机构）
class ResourceManagementPage extends StatelessWidget {
  final String type; // 'category' | 'bank' | 'credit'

  const ResourceManagementPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _getTitle() {
    switch (type) {
      case 'category':
        return '分类管理';
      case 'bank':
        return '银行机构';
      case 'credit':
        return '信贷机构';
      default:
        return '资源管理';
    }
  }

  Widget _buildBody() {
    switch (type) {
      case 'category':
        return const _CategoryList();
      case 'bank':
        return const _BankList();
      case 'credit':
        return const _CreditInstitutionList();
      default:
        return const Center(child: Text('未知类型'));
    }
  }

  void _showAddDialog(BuildContext context) {
    switch (type) {
      case 'category':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _AddCategoryPage()),
        );
        break;
      case 'bank':
        _showBankDialog(context);
        break;
      case 'credit':
        _showCreditDialog(context);
        break;
    }
  }

  void _showBankDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _BankDialog(),
    );
  }

  void _showCreditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _CreditDialog(),
    );
  }
}

// ============================================================
// 公共：图标选择器、颜色选择器、搜索框、渐变图标圆
// ============================================================

/// 通用搜索框（主题色边框聚焦）
class _SearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (!AppColors.current.isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
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
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: AppColors.textTertiary),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              borderSide: BorderSide(color: AppColors.primary, width: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

/// 渐变图标圆形（背景从 base 渐变到 white alpha 调和）
class _GradientIconCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final double size;
  const _GradientIconCircle({
    required this.color,
    required this.icon,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.current.isDark;
    final bg = [color, Color.lerp(color, Colors.white, isDark ? 0.3 : 0.18)!];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bg,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.4 : 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.5),
    );
  }
}

class _IconPicker extends StatelessWidget {
  final String iconName;
  final ValueChanged<String> onChanged;
  const _IconPicker({required this.iconName, required this.onChanged});

  static const Map<String, IconData> _icons = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'movie': Icons.movie,
    'home': Icons.home,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'work': Icons.work,
    'card_giftcard': Icons.card_giftcard,
    'trending_up': Icons.trending_up,
    'attach_money': Icons.attach_money,
    'more_horiz': Icons.more_horiz,
    'category': Icons.category,
    'account_balance': Icons.account_balance,
    'payments': Icons.payments,
    'phone_android': Icons.phone_android,
    'house': Icons.house,
    'flight': Icons.flight,
    'directions_bus': Icons.directions_bus,
    'local_cafe': Icons.local_cafe,
    'fitness_center': Icons.fitness_center,
    'pets': Icons.pets,
    'wallet': Icons.account_balance_wallet,
  };

  static IconData resolve(String? name) => _icons[name] ?? Icons.category;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: _icons.length,
        itemBuilder: (_, i) {
          final entry = _icons.entries.elementAt(i);
          final selected = entry.key == iconName;
          return InkWell(
            onTap: () => onChanged(entry.key),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                ),
              ),
              child: Icon(
                entry.value,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ColorPicker extends StatelessWidget {
  final String colorHex;
  final ValueChanged<String> onChanged;
  const _ColorPicker({required this.colorHex, required this.onChanged});

  static const List<String> _palette = [
    '#1976D2',
    '#43A047',
    '#FB8C00',
    '#E53935',
    '#8E24AA',
    '#00897B',
    '#5E35B1',
    '#3949AB',
    '#F4511E',
    '#FF5722',
    '#6D4C41',
    '#546E7A',
  ];

  static Color parse(String hex) {
    final v = hex.replaceFirst('#', '0xFF');
    return Color(int.parse(v));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _palette.map((hex) {
        final selected = hex.toUpperCase() == colorHex.toUpperCase();
        return GestureDetector(
          onTap: () => onChanged(hex),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: parse(hex),
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.textPrimary : Colors.transparent,
                width: 2,
              ),
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// 银行机构：列表 + 弹窗
// ============================================================

/// 银行列表（支持搜索 + 点击编辑）
class _BankList extends StatefulWidget {
  const _BankList();
  @override
  State<_BankList> createState() => _BankListState();
}

class _BankListState extends State<_BankList> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BankManagementProvider>(
      builder: (_, provider, __) {
        final allBanks = provider.banks;
        final banks = _filterBanks(allBanks, _keyword);

        return Column(
          children: [
            if (allBanks.isNotEmpty) _BankStatHeader(count: allBanks.length),
            _SearchField(
              hint: '搜索银行名称或代码',
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _keyword = v),
            ),
            Expanded(
              child: banks.isEmpty
                  ? EmptyState(
                      icon: _keyword.isEmpty
                          ? Icons.account_balance_outlined
                          : Icons.search_off,
                      title: _keyword.isEmpty ? '还没有银行' : '没有匹配的银行',
                      subtitle: _keyword.isEmpty
                          ? '点击右下角添加常用银行'
                          : '试试其他关键词',
                      actionText: _keyword.isEmpty ? '添加银行' : null,
                      onAction: _keyword.isEmpty
                          ? () => _showBankDialog(context, null)
                          : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: banks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _BankCard(
                        bank: banks[i],
                        onEdit: () => _showBankDialog(context, banks[i]),
                        onDelete: () => _confirmDelete(context, banks[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<LocalBanksData> _filterBanks(List<LocalBanksData> src, String kw) {
    if (kw.isEmpty) return src;
    final lower = kw.toLowerCase();
    return src
        .where((b) =>
            b.name.toLowerCase().contains(lower) ||
            (b.code?.toLowerCase().contains(lower) ?? false))
        .toList();
  }

  void _showBankDialog(BuildContext context, LocalBanksData? bank) {
    showDialog(
      context: context,
      builder: (_) => _BankDialog(existing: bank),
    );
  }

  void _confirmDelete(BuildContext context, LocalBanksData bank) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('删除银行', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '确定要删除「${bank.name}」吗？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && context.mounted) {
        context.read<BankManagementProvider>().deleteBank(bank.bankId);
      }
    });
  }
}

/// 顶部统计
class _BankStatHeader extends StatelessWidget {
  final int count;
  const _BankStatHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.current.isDark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.4 : 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.account_balance, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '已收录银行',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count 家',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.touch_app, color: Colors.white70, size: 18),
          const SizedBox(width: 4),
          const Text(
            '点击编辑',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// 单个银行卡片
class _BankCard extends StatelessWidget {
  final LocalBanksData bank;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BankCard({
    required this.bank,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final base = _ColorPicker.parse(bank.color);
    final isDark = AppColors.current.isDark;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      elevation: isDark ? 0 : 2,
      shadowColor: base.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _GradientIconCircle(
                color: base,
                icon: _IconPicker.resolve(bank.icon),
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bank.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if ((bank.code ?? '').isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                              color: AppColors.divider, width: 0.5),
                        ),
                        child: Text(
                          bank.code!,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '编辑',
                icon: Icon(Icons.edit_outlined,
                    color: AppColors.textTertiary, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: '删除',
                icon: Icon(Icons.delete_outline,
                    color: AppColors.expense, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BankDialog extends StatefulWidget {
  final LocalBanksData? existing;
  const _BankDialog({this.existing});

  @override
  State<_BankDialog> createState() => _BankDialogState();
}

class _BankDialogState extends State<_BankDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late String _icon;
  late String _color;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _icon = e?.icon ?? 'account_balance';
    _color = e?.color ?? '#1976D2';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _ColorPicker.parse(_color);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _GradientIconCircle(color: base, icon: _IconPicker.resolve(_icon), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEdit ? '编辑银行' : '新增银行',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: _decoration('银行名称'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                decoration: _decoration('银行代码（如 ICBC）'),
              ),
              const SizedBox(height: 16),
              Text('选择图标', style: _labelStyle()),
              _IconPicker(
                iconName: _icon,
                onChanged: (v) => setState(() => _icon = v),
              ),
              const SizedBox(height: 8),
              Text('选择颜色', style: _labelStyle()),
              _ColorPicker(
                colorHex: _color,
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('取消',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _isEdit ? '保存修改' : '保存',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );

  TextStyle _labelStyle() => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  void _onSubmit() {
    final name = _nameCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    if (name.isEmpty) {
      _toast('请输入银行名称');
      return;
    }
    if (code.isEmpty) {
      _toast('请输入银行代码');
      return;
    }
    final provider = context.read<BankManagementProvider>();
    if (_isEdit) {
      provider.updateBank(
        widget.existing!.bankId,
        name: name,
        code: code,
        icon: _icon,
        color: _color,
      );
    } else {
      provider.addBank(name: name, code: code, icon: _icon, color: _color);
    }
    Navigator.pop(context);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ============================================================
// 信贷机构：列表 + 弹窗
// ============================================================

class _CreditInstitutionList extends StatefulWidget {
  const _CreditInstitutionList();
  @override
  State<_CreditInstitutionList> createState() => _CreditInstitutionListState();
}

class _CreditInstitutionListState extends State<_CreditInstitutionList> {
  final _searchCtrl = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreditInstitutionManagementProvider>(
      builder: (_, provider, __) {
        final all = provider.institutions;
        final list = _filter(all, _keyword);
        // 按类型分组统计
        final typeCount = <String, int>{};
        for (final i in all) {
          typeCount[i.type] = (typeCount[i.type] ?? 0) + 1;
        }

        return Column(
          children: [
            if (all.isNotEmpty)
              _CreditStatHeader(
                total: all.length,
                typeCount: typeCount,
              ),
            _SearchField(
              hint: '搜索机构名称',
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _keyword = v),
            ),
            Expanded(
              child: list.isEmpty
                  ? EmptyState(
                      icon: _keyword.isEmpty
                          ? Icons.payments_outlined
                          : Icons.search_off,
                      title: _keyword.isEmpty ? '还没有信贷机构' : '没有匹配的机构',
                      subtitle: _keyword.isEmpty
                          ? '点击右下角添加借贷机构'
                          : '试试其他关键词',
                      actionText: _keyword.isEmpty ? '添加机构' : null,
                      onAction: _keyword.isEmpty
                          ? () => _showCreditDialog(context, null)
                          : null,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _CreditCard(
                        inst: list[i],
                        onEdit: () => _showCreditDialog(context, list[i]),
                        onDelete: () => _confirmDelete(context, list[i]),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List<LocalCreditInstitutionsData> _filter(
      List<LocalCreditInstitutionsData> src, String kw) {
    if (kw.isEmpty) return src;
    final lower = kw.toLowerCase();
    return src
        .where((i) =>
            i.name.toLowerCase().contains(lower) ||
            _typeLabel(i.type).toLowerCase().contains(lower))
        .toList();
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'loan':
        return '银行贷款';
      case 'microloan':
        return '小额贷款';
      case 'consumer':
        return '消费金融';
      case 'mortgage':
        return '房贷';
      case 'credit':
        return '信用卡';
      default:
        return type;
    }
  }

  void _showCreditDialog(BuildContext context, LocalCreditInstitutionsData? inst) {
    showDialog(
      context: context,
      builder: (_) => _CreditDialog(existing: inst),
    );
  }

  void _confirmDelete(BuildContext context, LocalCreditInstitutionsData inst) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('删除信贷机构', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '确定要删除「${inst.name}」吗？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('删除', style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true && context.mounted) {
        context.read<CreditInstitutionManagementProvider>().deleteInstitution(inst.institutionId);
      }
    });
  }
}

/// 顶部统计
class _CreditStatHeader extends StatelessWidget {
  final int total;
  final Map<String, int> typeCount;
  const _CreditStatHeader({required this.total, required this.typeCount});

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.current.isDark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF7C2D12), const Color(0xFFF97316)]
              : [const Color(0xFFFF7043), const Color(0xFFFF5722)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.payments, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('已收录机构',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('$total 家',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Icon(Icons.touch_app, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              const Text('点击编辑',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
          if (typeCount.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: typeCount.entries.map((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_shortTypeLabel(e.key)} ${e.value}',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _shortTypeLabel(String type) {
    switch (type) {
      case 'loan':
        return '银行';
      case 'microloan':
        return '小贷';
      case 'consumer':
        return '消金';
      case 'mortgage':
        return '房贷';
      case 'credit':
        return '信用卡';
      default:
        return type;
    }
  }
}

/// 单个信贷机构卡片
class _CreditCard extends StatelessWidget {
  final LocalCreditInstitutionsData inst;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CreditCard({
    required this.inst,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final base = _ColorPicker.parse(inst.color);
    final isDark = AppColors.current.isDark;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      elevation: isDark ? 0 : 2,
      shadowColor: base.withValues(alpha: 0.2),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _GradientIconCircle(
                color: base,
                icon: _IconPicker.resolve(inst.icon),
                size: 44,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inst.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _TypeBadge(type: inst.type),
                  ],
                ),
              ),
              IconButton(
                tooltip: '编辑',
                icon: Icon(Icons.edit_outlined,
                    color: AppColors.textTertiary, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: '删除',
                icon: Icon(Icons.delete_outline,
                    color: AppColors.expense, size: 20),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 类型徽章（主题感知，深色提亮、浅色饱和）
class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final info = _typeMeta(type);
    final isDark = AppColors.current.isDark;
    final fg = isDark ? info.lightColor : info.darkColor;
    final bg = fg.withValues(alpha: isDark ? 0.18 : 0.12);
    final border = fg.withValues(alpha: isDark ? 0.4 : 0.55);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Text(
        info.label,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  static ({String label, Color darkColor, Color lightColor}) _typeMeta(String t) {
    switch (t) {
      case 'loan':
        return (label: '银行贷款', darkColor: const Color(0xFF1677FF), lightColor: const Color(0xFF60A5FA));
      case 'microloan':
        return (label: '小额贷款', darkColor: const Color(0xFFEA580C), lightColor: const Color(0xFFFB923C));
      case 'consumer':
        return (label: '消费金融', darkColor: const Color(0xFFA855F7), lightColor: const Color(0xFFC084FC));
      case 'mortgage':
        return (label: '房贷', darkColor: const Color(0xFF0284C7), lightColor: const Color(0xFF38BDF8));
      case 'credit':
        return (label: '信用卡', darkColor: const Color(0xFFDC2626), lightColor: const Color(0xFFF87171));
      default:
        return (label: t, darkColor: const Color(0xFF64748B), lightColor: const Color(0xFF94A3B8));
    }
  }
}

class _CreditDialog extends StatefulWidget {
  final LocalCreditInstitutionsData? existing;
  const _CreditDialog({this.existing});

  @override
  State<_CreditDialog> createState() => _CreditDialogState();
}

class _CreditDialogState extends State<_CreditDialog> {
  late final TextEditingController _nameCtrl;
  late String _type;
  late String _icon;
  late String _color;

  bool get _isEdit => widget.existing != null;

  static const List<Map<String, String>> _types = [
    {'value': 'loan', 'label': '银行贷款'},
    {'value': 'microloan', 'label': '小额贷款'},
    {'value': 'consumer', 'label': '消费金融'},
    {'value': 'mortgage', 'label': '房贷'},
    {'value': 'credit', 'label': '信用卡'},
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _type = e?.type ?? 'loan';
    _icon = e?.icon ?? 'payments';
    _color = e?.color ?? '#FF5722';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = _ColorPicker.parse(_color);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _GradientIconCircle(color: base, icon: _IconPicker.resolve(_icon), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isEdit ? '编辑信贷机构' : '新增信贷机构',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: '机构名称',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('机构类型', style: _labelStyle()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final selected = t['value'] == _type;
                  final meta = _TypeBadge._typeMeta(t['value']!);
                  final isDark = AppColors.current.isDark;
                  final color = isDark ? meta.lightColor : meta.darkColor;
                  return ChoiceChip(
                    label: Text(t['label']!),
                    selected: selected,
                    onSelected: (_) => setState(() => _type = t['value']!),
                    selectedColor: color.withValues(alpha: isDark ? 0.22 : 0.15),
                    backgroundColor: AppColors.background,
                    side: BorderSide(
                      color: selected ? color : AppColors.divider,
                      width: selected ? 1 : 0.5,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? color : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('选择图标', style: _labelStyle()),
              _IconPicker(
                iconName: _icon,
                onChanged: (v) => setState(() => _icon = v),
              ),
              const SizedBox(height: 8),
              Text('选择颜色', style: _labelStyle()),
              _ColorPicker(
                colorHex: _color,
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('取消',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text(
                        _isEdit ? '保存修改' : '保存',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _labelStyle() => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  void _onSubmit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入机构名称')),
      );
      return;
    }
    final provider = context.read<CreditInstitutionManagementProvider>();
    if (_isEdit) {
      provider.updateInstitution(
        widget.existing!.institutionId,
        name: name,
        type: _type,
        icon: _icon,
        color: _color,
      );
    } else {
      provider.addInstitution(
        name: name,
        type: _type,
        icon: _icon,
        color: _color,
      );
    }
    Navigator.pop(context);
  }
}

// ============================================================
// 分类管理：列表 + 新增分类页面
// ============================================================

class _CategoryList extends StatelessWidget {
  const _CategoryList();

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryManagementProvider>(
      builder: (_, provider, __) {
        final expenseParents = provider.expenseParentCategories;
        final incomeParents = provider.incomeParentCategories;
        if (expenseParents.isEmpty && incomeParents.isEmpty) {
          return Center(
            child: Text(
              '暂无分类，点击右下角添加',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (expenseParents.isNotEmpty)
              _CategorySection(
                title: '支出分类',
                parents: expenseParents,
                type: 'expense',
                provider: provider,
              ),
            if (incomeParents.isNotEmpty)
              _CategorySection(
                title: '收入分类',
                parents: incomeParents,
                type: 'income',
                provider: provider,
              ),
          ],
        );
      },
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String title;
  final List<LocalCategoriesData> parents;
  final String type;
  final CategoryManagementProvider provider;

  const _CategorySection({
    required this.title,
    required this.parents,
    required this.type,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...parents.map((p) {
          final subs = provider.getSubCategories(p.categoryId);
          return _CategoryTile(parent: p, subs: subs);
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final LocalCategoriesData parent;
  final List<LocalCategoriesData> subs;
  const _CategoryTile({required this.parent, required this.subs});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _ColorPicker.parse(parent.color),
                child: Icon(
                  _IconPicker.resolve(parent.icon),
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  parent.name,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline,
                    color: AppColors.primary, size: 20),
                tooltip: '添加子分类',
                onPressed: () => _showAddSubCategoryDialog(context, parent),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    color: AppColors.expense, size: 20),
                onPressed: () => context
                    .read<CategoryManagementProvider>()
                    .deleteCategory(parent.categoryId),
              ),
            ],
          ),
          if (subs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subs.map((s) {
                  // Chip 配色：浅色分类色背景 + 半透明分类色边框 + 主题主文字色
                  // 避免文字与背景同色系导致看不清
                  final tagColor = _ColorPicker.parse(s.color);
                  return Chip(
                    label: Text(s.name),
                    backgroundColor: tagColor.withValues(alpha: 0.12),
                    side: BorderSide(
                      color: tagColor.withValues(alpha: 0.55),
                      width: 1,
                    ),
                    labelStyle: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    deleteIconColor: AppColors.textSecondary,
                    onDeleted: () => context
                        .read<CategoryManagementProvider>()
                        .deleteSubCategory(s.categoryId),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  /// 新增子分类：仅弹窗输入名称即可，子分类的图标/颜色继承父分类
  Future<void> _showAddSubCategoryDialog(
    BuildContext context,
    LocalCategoriesData parent,
  ) async {
    await showAddSubCategoryDialog(
      context,
      parentId: parent.categoryId,
      parentName: parent.name,
      parentIcon: _IconPicker.resolve(parent.icon),
      parentColor: _ColorPicker.parse(parent.color),
    );
  }
}

/// 新增大分类页面
class _AddCategoryPage extends StatefulWidget {
  const _AddCategoryPage();

  @override
  State<_AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<_AddCategoryPage> {
  final _nameCtrl = TextEditingController();
  String _type = 'expense';
  String _icon = 'category';
  String _color = '#1976D2';

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('新增分类'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildIconSection(),
            const SizedBox(height: 16),
            _buildColorSection(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('保存', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameCtrl,
      decoration: InputDecoration(
        labelText: '分类名称',
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('分类类型', style: _labelStyle()),
        const SizedBox(height: 8),
        Row(
          children: [
            _typeButton('支出', 'expense'),
            const SizedBox(width: 12),
            _typeButton('收入', 'income'),
          ],
        ),
      ],
    );
  }

  Widget _typeButton(String label, String value) {
    final selected = _type == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择图标', style: _labelStyle()),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _IconPicker(
            iconName: _icon,
            onChanged: (v) => setState(() => _icon = v),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择颜色', style: _labelStyle()),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _ColorPicker(
            colorHex: _color,
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
      ],
    );
  }

  TextStyle _labelStyle() => TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      );

  void _onSubmit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入分类名称')),
      );
      return;
    }
    context.read<CategoryManagementProvider>().addParentCategory(
          name: name,
          type: _type,
          icon: _icon,
          color: _color,
        );
    Navigator.pop(context);
  }
}
