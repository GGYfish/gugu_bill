import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../ui_constants.dart';
import 'selector_widgets.dart';

/// 银行分类静态映射（不存数据，只定义 code 集合）
class BankData {
  /// 各分类对应的银行 code 集合
  static const Map<String, List<String>> categoryCodes = {
    '国有大型银行': ['ICBC', 'ABC', 'BOC', 'CCB', 'BCOM', 'PSBC'],
    '股份制商业银行': [
      'CMB', 'SPDB', 'CITIC', 'CEB', 'HXB', 'CMBC',
      'CGB', 'CIB', 'PAB', 'CZB', 'EGC', 'CBHB', 'ZSB', 'HFB', 'BOH',
    ],
    '城市商业银行': [
      'BJB', 'SHB', 'JSB', 'NJCB', 'HZB', 'NBCB',
      'HSB', 'CSRCB', 'CQB', 'ZZB', 'JNB', 'LYB', 'XMB', 'SZSB', 'DLB',
      'WHB', 'TJB', 'NJB', 'QDB', 'CZB', 'GZB', 'LZCB', 'HNB', 'GLB',
      'JZB', 'HEBB', 'URB', 'LZSB', 'ZZSB', 'DYB', 'YTB', 'WFB', 'JZB2',
      'LFB', 'ZYB', 'ZBB', 'LCB', 'BYB', 'BHB', 'ZCB',
      'HKB', 'NCB', 'GDB', 'SJB', 'YLCB', 'ZYCB', 'TLB', 'ASB', 'FXB',
      'BDCB', 'DDD', 'YYB', 'LXB', 'ZHB', 'NNB',
    ],
    '农村商业银行': [
      'BJRCB', 'SHRCB', 'GDNYB', 'SZRCB', 'JSRCB',
      'ZJRCB', 'AHRCB', 'SDRCB', 'WHRCB', 'CDRCB', 'TJRCB', 'CQRCB',
      'YNRB', 'SXCB',
    ],
    '互联网银行': ['MYBANK', 'WEBANK', 'XWB', 'ZBANK', 'XKB', 'YSB', 'ALB', 'WLB'],
    '外资银行': [
      'HSBC', 'SCB', 'CITI', 'BEA', 'OCBC', 'UOB', 'DBS',
      'MIZUHO', 'SMBC', 'BNP', 'DB',
    ],
  };

  /// 把银行列表按 code 分组；不匹配任何已知分类的归入"其他银行"
  static Map<String, List<LocalBanksData>> groupBanks(List<LocalBanksData> banks) {
    final result = <String, List<LocalBanksData>>{};
    final knownCodes = <String>{};
    categoryCodes.forEach((cat, codes) {
      result[cat] = [];
      knownCodes.addAll(codes);
    });

    final others = <LocalBanksData>[];
    for (final bank in banks) {
      String? matched;
      for (final entry in categoryCodes.entries) {
        if (entry.value.contains(bank.code)) {
          matched = entry.key;
          break;
        }
      }
      if (matched != null) {
        result[matched]!.add(bank);
      } else {
        others.add(bank);
      }
    }
    if (others.isNotEmpty) {
      result['其他银行'] = others;
    }
    result.removeWhere((_, v) => v.isEmpty);
    return result;
  }
}

/// 银行项（向上层传递的 UI 模型）
class BankItem {
  final String name;
  final String code;
  final String icon;
  final String color;

  const BankItem({
    required this.name,
    required this.code,
    required this.icon,
    required this.color,
  });
}

/// 银行选择器弹窗
class BankSelector {
  /// 显示银行选择器
  /// 返回选中的银行，如果取消返回 null
  static Future<BankItem?> show(BuildContext context, {BankItem? currentBank}) {
    return showModalBottomSheet<BankItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BankSelectorSheet(currentBank: currentBank),
    );
  }
}

class _BankSelectorSheet extends StatefulWidget {
  final BankItem? currentBank;

  const _BankSelectorSheet({this.currentBank});

  @override
  State<_BankSelectorSheet> createState() => _BankSelectorSheetState();
}

class _BankSelectorSheetState extends State<_BankSelectorSheet> {
  final _searchController = TextEditingController();
  List<LocalBanksData> _allBanks = [];
  List<LocalBanksData> _filteredBanks = [];
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
    final results = await db.getAllBanks();
    if (!mounted) return;
    setState(() {
      _allBanks = results;
      _filteredBanks = results;
      _isLoading = false;
    });
  }

  Future<void> _searchFromDatabase(String keyword) async {
    final db = context.read<AppDatabase>();
    final results = await db.searchBanks(keyword);
    if (!mounted) return;
    setState(() {
      _filteredBanks = results;
    });
  }

  void _onSearchChanged(String keyword) {
    setState(() => _searchKeyword = keyword);
    if (keyword.trim().isEmpty) {
      setState(() => _filteredBanks = _allBanks);
    } else {
      _searchFromDatabase(keyword);
    }
  }

  BankItem _toBankItem(LocalBanksData data) {
    return BankItem(
      name: data.name,
      code: data.code ?? data.bankId,
      icon: data.icon,
      color: data.color,
    );
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
            title: '选择银行',
            subtitle: widget.currentBank == null
                ? '共 ${_allBanks.length} 家银行可选'
                : '当前已选：${widget.currentBank!.name}',
            icon: Icons.account_balance,
            accentColor: const Color(0xFF1677FF),
            onClose: () => Navigator.pop(context),
          ),
          SelectorSearchField(
            controller: _searchController,
            hint: '搜索银行名称或代码',
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

  /// 按分类显示银行列表
  Widget _buildCategorizedList() {
    final banksByCategory = BankData.groupBanks(_allBanks);
    final categories = banksByCategory.keys.toList();

    if (categories.isEmpty) {
      return SelectorEmptyState(
        icon: Icons.account_balance_outlined,
        title: '还没有银行',
        subtitle: '点击下方按钮添加你的第一笔银行',
        addLabel: '添加银行',
        onAdd: () => _showAddBankDialog(''),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final banks = banksByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategorySectionHeader(
              title: '$category (${banks.length})',
              icon: Icons.account_balance,
            ),
            ...banks.map((bank) => _buildBankRow(bank)),
          ],
        );
      },
    );
  }

  /// 搜索结果
  Widget _buildSearchResults() {
    final keyword = _searchKeyword.trim();
    final keywordExists =
        keyword.isEmpty || _filteredBanks.any((b) => b.name == keyword);

    if (_filteredBanks.isEmpty) {
      return SelectorEmptyState(
        icon: Icons.search_off,
        title: '没有匹配的银行',
        subtitle: '试试其他关键词，或直接添加新银行',
        addLabel: '添加 "$keyword"',
        onAdd: () => _showAddBankDialog(keyword),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _filteredBanks.length + (keywordExists ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == _filteredBanks.length) {
          return SelectorAddInlineTile(
            keyword: keyword,
            onTap: () => _showAddBankDialog(keyword),
          );
        }
        return _buildBankRow(_filteredBanks[index]);
      },
    );
  }

  /// 单个银行项
  Widget _buildBankRow(LocalBanksData bank) {
    final isSelected = widget.currentBank?.code == bank.code;
    final accent = parseHexColor(bank.color);

    return SelectorListItem(
      title: bank.name,
      codeBadge: bank.code,
      accentColor: accent,
      iconName: bank.icon,
      selected: isSelected,
      onTap: () => Navigator.pop(context, _toBankItem(bank)),
    );
  }

  /// 弹 dialog：让用户编辑名字 + 选 icon 和 color，确认后构造 BankItem 返回
  Future<void> _showAddBankDialog(String initialName) async {
    final result = await _AddBankDialog.show(context, initialName);
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }
}

/// 添加银行弹窗（独立 widget，逻辑从 _BankSelectorSheet 拆出来）
class _AddBankDialog extends StatefulWidget {
  final String initialName;
  const _AddBankDialog({required this.initialName});

  static Future<BankItem?> show(BuildContext context, String initialName) {
    return showDialog<BankItem>(
      context: context,
      builder: (_) => _AddBankDialog(initialName: initialName),
    );
  }

  @override
  State<_AddBankDialog> createState() => _AddBankDialogState();
}

class _AddBankDialogState extends State<_AddBankDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  String _icon = '🏦';
  String _color = '#1677FF';

  static const _iconOptions = ['🏦', '💳', '🏛️', '🌾', '🌍', '📱', '💰', '💴'];
  static const _colorOptions = [
    '#E53935', '#43A047', '#1E88E5', '#1565C0', '#7B1FA2',
    '#D32F2F', '#F57C00', '#FBC02D', '#0288D1', '#1976D2',
    '#388E3C', '#00796B', '#C62828', '#FF6F00', '#757575',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName);
    _codeCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = parseHexColor(_color);
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  GradientIconBadge(color: accent, iconName: _icon, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '添加银行',
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
                decoration: _inputDecoration('银行名称', hint: '如：招商银行'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: _inputDecoration('银行代码（可选）', hint: '如 CMB / ICBC'),
              ),
              const SizedBox(height: 16),
              Text('图标', style: _labelStyle()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _iconOptions.map((e) {
                  final isSelected = _icon == e;
                  return GestureDetector(
                    onTap: () => setState(() => _icon = e),
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.divider,
                          width: isSelected ? 1.2 : 0.5,
                        ),
                      ),
                      child: Text(e, style: const TextStyle(fontSize: 22)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text('颜色', style: _labelStyle()),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _colorOptions.map((e) {
                  final isSelected = _color == e;
                  final color = parseHexColor(e);
                  return GestureDetector(
                    onTap: () => setState(() => _color = e),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppColors.textPrimary : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 16)
                          : null,
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

  Future<void> _onSubmit() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入银行名称')),
      );
      return;
    }
    final code = _codeCtrl.text.trim().isEmpty
        ? 'CUSTOM_${const Uuid().v4().substring(0, 8)}'
        : _codeCtrl.text.trim().toUpperCase();

    final db = context.read<AppDatabase>();
    await db.insertBank(LocalBanksCompanion(
      bankId: Value(code),
      name: Value(name),
      code: Value(code),
      icon: Value(_icon),
      color: Value(_color),
      sortOrder: const Value(99),
      isEnabled: const Value(true),
      createdAt: Value(DateTime.now()),
    ));

    if (!mounted) return;
    Navigator.pop(
      context,
      BankItem(name: name, code: code, icon: _icon, color: _color),
    );
  }
}
