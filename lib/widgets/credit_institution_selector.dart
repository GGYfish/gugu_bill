import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../ui_constants.dart';
import 'selector_widgets.dart';

/// 信贷机构选择器
/// 直接从数据库读取信贷机构数据，支持搜索功能
class CreditInstitutionSelector {
  /// 显示信贷机构选择器
  /// 返回选中的信贷机构，如果取消返回 null
  static Future<LocalCreditInstitutionsData?> show(
    BuildContext context, {
    LocalCreditInstitutionsData? currentInstitution,
  }) {
    return showModalBottomSheet<LocalCreditInstitutionsData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreditInstitutionSelectorSheet(
        currentInstitution: currentInstitution,
      ),
    );
  }
}

class _CreditInstitutionSelectorSheet extends StatefulWidget {
  final LocalCreditInstitutionsData? currentInstitution;

  const _CreditInstitutionSelectorSheet({
    this.currentInstitution,
  });

  @override
  State<_CreditInstitutionSelectorSheet> createState() =>
      _CreditInstitutionSelectorSheetState();
}

class _CreditInstitutionSelectorSheetState
    extends State<_CreditInstitutionSelectorSheet> {
  final _searchController = TextEditingController();
  List<LocalCreditInstitutionsData> _allInstitutions = [];
  List<LocalCreditInstitutionsData> _filteredInstitutions = [];
  String _searchKeyword = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFromDatabase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFromDatabase() async {
    final db = context.read<AppDatabase>();
    final results = await db.getAllCreditInstitutions();
    if (mounted) {
      setState(() {
        _allInstitutions = results;
        _filteredInstitutions = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _searchFromDatabase(String keyword) async {
    setState(() {
      _searchKeyword = keyword;
      _isLoading = true;
    });
    final db = context.read<AppDatabase>();
    final results = await db.searchCreditInstitutions(keyword);
    if (mounted) {
      setState(() {
        _filteredInstitutions = results;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _searchKeyword = '';
        _filteredInstitutions = _allInstitutions;
      });
    } else {
      _searchFromDatabase(keyword);
    }
  }

  Map<String, List<LocalCreditInstitutionsData>> get _institutionsByType {
    final Map<String, List<LocalCreditInstitutionsData>> result = {};
    for (final inst in _filteredInstitutions) {
      String categoryName = _getTypeName(inst.type);
      result.putIfAbsent(categoryName, () => []).add(inst);
    }
    // 固定排序：先按优先级排，再保留数据库原始顺序
    const order = [
      '银行贷款', '电商分期', '消费金融', '小贷产品', '典当担保', '其他',
    ];
    final sorted = <String, List<LocalCreditInstitutionsData>>{};
    for (final key in order) {
      if (result.containsKey(key)) sorted[key] = result[key]!;
    }
    result.forEach((k, v) {
      if (!sorted.containsKey(k)) sorted[k] = v;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SelectorSheetHeader(
            title: '选择信贷机构',
            subtitle: widget.currentInstitution == null
                ? '共 ${_allInstitutions.length} 家机构可选'
                : '当前已选：${widget.currentInstitution!.name}',
            icon: Icons.payments,
            accentColor: const Color(0xFFFF5722),
            onClose: () => Navigator.pop(context),
          ),
          SelectorSearchField(
            controller: _searchController,
            hint: '搜索机构名称或类型',
            onChanged: _onSearchChanged,
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchKeyword.isEmpty
                    ? _buildCategorizedList()
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorizedList() {
    final institutionsByType = _institutionsByType;
    final categories = institutionsByType.keys.toList();

    if (categories.isEmpty) {
      return SelectorEmptyState(
        icon: Icons.payments_outlined,
        title: '还没有信贷机构',
        subtitle: '点击下方按钮添加借贷机构',
        addLabel: '添加机构',
        onAdd: () => _showAddInstitutionDialog(''),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final institutions = institutionsByType[category]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySectionHeader(
              title: '$category (${institutions.length})',
              icon: _typeIcon(category),
            ),
            ...institutions.map((inst) => _buildInstitutionItem(inst)),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final keyword = _searchKeyword.trim();
    final keywordExists =
        keyword.isEmpty || _filteredInstitutions.any((i) => i.name == keyword);

    if (_filteredInstitutions.isEmpty) {
      return SelectorEmptyState(
        icon: Icons.search_off,
        title: '没有匹配的机构',
        subtitle: '试试其他关键词，或直接添加新机构',
        addLabel: '添加 "$keyword"',
        onAdd: () => _showAddInstitutionDialog(keyword),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _filteredInstitutions.length + (keywordExists ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == _filteredInstitutions.length) {
          return SelectorAddInlineTile(
            keyword: keyword,
            onTap: () => _showAddInstitutionDialog(keyword),
          );
        }
        return _buildInstitutionItem(_filteredInstitutions[index]);
      },
    );
  }

  Widget _buildInstitutionItem(LocalCreditInstitutionsData inst) {
    final isSelected =
        widget.currentInstitution?.institutionId == inst.institutionId;
    final accent = parseHexColor(inst.color);

    return SelectorListItem(
      title: inst.name,
      subtitle: _getTypeName(inst.type),
      accentColor: accent,
      iconName: inst.icon,
      selected: isSelected,
      onTap: () => Navigator.pop(context, inst),
    );
  }

  IconData? _typeIcon(String categoryName) {
    switch (categoryName) {
      case '银行贷款':
        return Icons.account_balance;
      case '电商分期':
        return Icons.shopping_bag;
      case '消费金融':
        return Icons.credit_card;
      case '小贷产品':
        return Icons.payments;
      case '典当担保':
        return Icons.shield;
      default:
        return Icons.category;
    }
  }

  /// 弹窗：让用户编辑名字 + 选择类型
  Future<void> _showAddInstitutionDialog(String initialName) async {
    final result = await _AddCreditInstitutionDialog.show(context, initialName);
    if (result == null || !mounted) return;
    final name = result['name']!;
    final type = result['type']!;

    final db = context.read<AppDatabase>();
    final institutionId = const Uuid().v4();
    await db.insertCreditInstitution(LocalCreditInstitutionsCompanion(
      institutionId: Value(institutionId),
      name: Value(name),
      type: Value(type),
      icon: const Value('account_balance'),
      color: const Value('#1677FF'),
      sortOrder: const Value(99),
      isEnabled: const Value(true),
      createdAt: Value(DateTime.now()),
    ));

    if (!mounted) return;
    final all = await db.getAllCreditInstitutions();
    final created = all.firstWhere(
      (i) => i.institutionId == institutionId,
      orElse: () => all.first,
    );
    if (!mounted) return;
    Navigator.pop(context, created);
  }

  /// 获取类型中文名
  String _getTypeName(String type) {
    switch (type) {
      case 'credit':
        return '电商分期';
      case 'microloan':
        return '小贷产品';
      case 'consumer':
        return '消费金融';
      case 'loan':
        return '银行贷款';
      case 'pawn':
        return '典当担保';
      default:
        return '其他';
    }
  }
}

/// 添加信贷机构弹窗
class _AddCreditInstitutionDialog extends StatefulWidget {
  final String initialName;
  const _AddCreditInstitutionDialog({required this.initialName});

  static Future<Map<String, String>?> show(BuildContext context, String initialName) {
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _AddCreditInstitutionDialog(initialName: initialName),
    );
  }

  @override
  State<_AddCreditInstitutionDialog> createState() =>
      _AddCreditInstitutionDialogState();
}

class _AddCreditInstitutionDialogState
    extends State<_AddCreditInstitutionDialog> {
  late final TextEditingController _nameCtrl;
  String _selectedType = 'loan';

  static const Map<String, String> _types = {
    'loan': '银行贷款',
    'credit': '电商分期',
    'consumer': '消费金融',
    'microloan': '小贷产品',
    'pawn': '典当担保',
    'other': '其他',
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.payments, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '添加信贷机构',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '信息将保存到本地',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: _inputDecoration('机构名称', hint: '如：招商银行信用卡'),
            ),
            const SizedBox(height: 16),
            Text('机构类型', style: _labelStyle()),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _types.entries.map((e) {
                final isSelected = _selectedType == e.key;
                return ChoiceChip(
                  label: Text(e.value),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedType = e.key),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.background,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: isSelected ? 1 : 0.5,
                  ),
                );
              }).toList(),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('保存', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppColors.background,
      labelStyle: TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(color: AppColors.textTertiary),
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
        borderSide: BorderSide(color: AppColors.primary, width: 1.4),
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
    Navigator.pop(context, {'name': name, 'type': _selectedType});
  }
}
