import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/bill_provider.dart';
import '../providers/liability_provider.dart';
import '../providers/record_category_provider.dart';
import '../database/database.dart';
import '../ui_constants.dart';
import '../widgets/add_sub_category_dialog.dart';
import 'add_category_page.dart';

/// 记一笔页面（手动记账）。
/// 负债相关：负债创建已迁移到 add_liability_page.dart；
/// 这里只保留【还债】选择器（在"分类"里点"还款"子分类后弹出的负债列表）。
class RecordPage extends StatefulWidget {
  /// 编辑模式：传入要编辑的账单
  final LocalBillsData? bill;

  const RecordPage({super.key, this.bill});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with SingleTickerProviderStateMixin {
  // 支出/收入/其他 Tab 下标: 0=支出, 1=收入, 2=其他
  int _billTypeIndex = 0;
  late TabController _tabController;

  String get _billType {
    switch (_billTypeIndex) {
      case 0:
        return 'expense';
      case 1:
        return 'income';
      default:
        return 'other';
    }
  }

  double _amount = 0;
  String _amountStr = '0.00';
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _selectedSubCategoryId;
  String? _selectedSubCategoryName;
  String _remark = '';
  DateTime _billTime = DateTime.now();
  // 当前展开的大分类 ID（点击大分类时子分类在大分类下方展开显示）
  String? _expandedCategoryId;

  // 关联的负债记录（用于还债分类）
  LocalLiabilitiesData? _selectedLiability;
  List<LocalLiabilitiesData> _availableLiabilities = [];

  // 备注输入框
  final FocusNode _remarkFocusNode = FocusNode();
  final TextEditingController _remarkController = TextEditingController();

  // 键盘输入缓冲（含运算符表达式）
  String _inputBuffer = '0';

  /// 计算带运算符的表达式（从左到右，加减法）
  double _calculateExpression(String expr) {
    if (expr.isEmpty) return 0;
    try {
      double result = 0;
      String current = '';
      String lastOp = '+';
      for (int i = 0; i <= expr.length; i++) {
        final char = i < expr.length ? expr[i] : '+';
        if (char == '+' || char == '-') {
          if (current.isNotEmpty) {
            final num = double.tryParse(current) ?? 0;
            if (lastOp == '+') {
              result += num;
            } else {
              result -= num;
            }
          }
          current = '';
          lastOp = char;
        } else {
          current += char;
        }
      }
      return result;
    } catch (_) {
      return 0;
    }
  }

  /// 从 Provider 读取当前类型的分类列表（不订阅，可在任意上下文调用）
  List<CategoryItem> _readCurrentCategoriesFromDb(BuildContext ctx) {
    final provider = ctx.read<RecordCategoryProvider>();
    switch (_billTypeIndex) {
      case 0:
        return provider.expenseCategories;
      case 1:
        return provider.incomeCategories;
      case 2:
        return provider.otherCategories;
      default:
        return provider.expenseCategories;
    }
  }

  // ============================================================
  // 生命周期
  // ============================================================
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_onTabChanged);
    _remarkController.addListener(() {
      _remark = _remarkController.text;
    });

    // 编辑模式：初始化数据
    if (widget.bill != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initForEdit(widget.bill!);
      });
    } else {
      // 新增模式：默认选中第一个分类（异步重试直到分类数据就绪）
      _scheduleAutoSelectFirstCategory();
    }

    // 加载负债列表（供"还债"分类使用）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLiabilities();
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _billTypeIndex = _tabController.index;
      _expandedCategoryId = null; // 切换 Tab 时收起展开
      _selectFirstCategoryByDefault();
      // 切换Tab时重置负债选择
      _selectedLiability = null;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _remarkFocusNode.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  /// 初始化编辑模式的数据
  void _initForEdit(LocalBillsData bill) {
    switch (bill.type) {
      case 'expense':
        _billTypeIndex = 0;
        break;
      case 'income':
        _billTypeIndex = 1;
        break;
      default:
        _billTypeIndex = 2;
    }
    _tabController.index = _billTypeIndex;

    _inputBuffer = bill.amount.toStringAsFixed(2);
    _updateAmountDisplay();

    _initCategorySelection(bill.categoryId, bill.categoryName);

    _remark = bill.remark ?? '';
    _remarkController.text = _remark;
    _billTime = bill.billTime;

    // 还款关联的负债
    if (bill.liabilityId != null) {
      final liability = _availableLiabilities
          .where((l) => l.liabilityId == bill.liabilityId)
          .toList();
      if (liability.isNotEmpty) {
        _selectedLiability = liability.first;
      }
    }
  }

  /// 初始化分类选中状态（编辑模式）
  void _initCategorySelection(String? categoryId, String? categoryName) {
    if (categoryId == null) {
      _selectFirstCategoryByDefault();
      return;
    }

    final categories = _readCurrentCategoriesFromDb(context);
    if (categories.isEmpty) {
      _selectFirstCategoryByDefault();
      return;
    }

    // 先尝试匹配子分类
    for (final cat in categories) {
      for (final sub in cat.sub) {
        if (sub.id == categoryId) {
          setState(() {
            _selectedCategoryId = cat.id;
            _selectedCategoryName = cat.name;
            _selectedSubCategoryId = sub.id;
            _selectedSubCategoryName = sub.name;
          });
          return;
        }
      }
    }
    // 再尝试匹配父分类
    final match = categories.where((c) => c.id == categoryId).toList();
    if (match.isNotEmpty) {
      setState(() {
        _selectedCategoryId = match.first.id;
        _selectedCategoryName = match.first.name;
        _selectedSubCategoryId = null;
        _selectedSubCategoryName = null;
      });
      return;
    }

    _selectFirstCategoryByDefault();
  }

  /// 更新金额显示
  void _updateAmountDisplay() {
    final expr = _inputBuffer;
    if (expr.isEmpty || expr == '0') {
      _amountStr = '0.00';
      _amount = 0;
    } else {
      final hasOperator = expr.contains('+') || (expr.contains('-') && expr.indexOf('-') > 0);
      if (hasOperator) {
        _amount = _calculateExpression(expr);
        _amountStr = _amount.toStringAsFixed(2);
      } else {
        _amountStr = _inputBuffer.isEmpty ? '0.00' : _inputBuffer;
        if (!_amountStr.contains('.')) {
          _amountStr = _amountStr;
        }
        if (_amountStr.contains('.')) {
          final parts = _amountStr.split('.');
          final intPart = parts[0];
          final decPart = parts.length > 1 ? parts[1].padRight(2, '0').substring(0, 2) : '00';
          _amountStr = '$intPart.$decPart';
        }
        _amount = double.tryParse(_amountStr) ?? 0;
      }
    }
  }

  /// 默认选中第一个分类（包含 setState，会触发 UI 刷新）
  void _selectFirstCategoryByDefault() {
    final categories = _readCurrentCategoriesFromDb(context);
    if (categories.isEmpty) return;
    final first = categories.first;
    setState(() {
      if (first.sub.isNotEmpty) {
        final firstSub = first.sub.first;
        _selectedCategoryId = first.id;
        _selectedCategoryName = first.name;
        _selectedSubCategoryId = firstSub.id;
        _selectedSubCategoryName = firstSub.name;
      } else {
        _selectedCategoryId = first.id;
        _selectedCategoryName = first.name;
        _selectedSubCategoryId = null;
        _selectedSubCategoryName = null;
      }
      _selectedLiability = null;
      // 首个分类若有小分类，默认展开小分类面板，让用户直接看到所有可选小项
      _expandedCategoryId =  first.id;
    });
  }

  /// 异步重试默认选中：provider 加载分类是异步的，
  /// 第一次进页面 postFrameCallback 时数据可能还没好。
  /// 本方法持续到 categories 就绪后再 setState。
  void _scheduleAutoSelectFirstCategory() {
    _autoSelectAttempts = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoSelectFirstCategory();
    });
  }

  // 重试次数保护，避免极端情况（数据库异常等）下的无限递归
  int _autoSelectAttempts = 0;
  static const int _maxAutoSelectAttempts = 100; // ~100 帧，约 1.6 秒上限

  void _tryAutoSelectFirstCategory() {
    if (!mounted) return;
    // 已选中（编辑模式或手动选过）则跳过
    if (_selectedCategoryId != null) return;
    if (_autoSelectAttempts >= _maxAutoSelectAttempts) return;
    _autoSelectAttempts++;
    final categories = _readCurrentCategoriesFromDb(context);
    if (categories.isEmpty) {
      // 数据未就绪，等下一帧再试
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoSelectFirstCategory();
      });
      return;
    }
    _selectFirstCategoryByDefault();
  }

  /// 加载未结清的负债列表（供"还债"分类使用）
  Future<void> _loadLiabilities() async {
    final liabilityProvider = context.read<LiabilityProvider>();
    await liabilityProvider.refreshData();
    if (!mounted) return;
    setState(() {
      _availableLiabilities = liabilityProvider.liabilities
          .where((l) => l.status == 0)
          .toList();
    });
  }

  // ============================================================
  // 页面结构
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // 订阅分类 provider，分类数据变更时自动重建
    context.watch<RecordCategoryProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildTypeTabs(),
                    const SizedBox(height: 16),
                    _buildAmountCard(),
                    const SizedBox(height: 16),
                    _buildCategoryCard(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 1. 顶部导航栏
  // ============================================================
  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, size: 24, color: AppColors.textPrimary),
          ),
          Expanded(
            child: Text(
              widget.bill != null ? '编辑账单' : '记一笔',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  // ============================================================
  // 2. 类型切换 Tab
  // ============================================================
  Widget _buildTypeTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.all(4),
                labelPadding: EdgeInsets.zero,
                tabs: const [
                  Tab(text: '支出'),
                  Tab(text: '收入'),
                  Tab(text: '其他'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _showDateTimePicker,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MM月dd').format(_billTime),
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 3. 金额输入卡片（渐变风格）
  // ============================================================
  Widget _buildAmountCard() {
    final isExpense = _billTypeIndex == 0;
    final isIncome = _billTypeIndex == 1;
    final gradientColors = isExpense
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
        : isIncome
            ? [AppColors.income, const Color(0xFF34D399)]
            : [AppColors.textSecondary, const Color(0xFF9CA3AF)];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showKeyboardSheet,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _billTypeIndex == 0 ? '支出金额' : (_billTypeIndex == 1 ? '收入金额' : '其他金额'),
                    style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '¥',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _amountStr,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '点击输入金额',
                    style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 4. 分类选择卡片
  // ============================================================
  Widget _buildCategoryCard() {
    final categories = _readCurrentCategoriesFromDb(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(Icons.category, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('选择分类', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => _openAddCategoryPage(),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                    const SizedBox(width: 4),
                    Text('添加', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 大分类网格（手动行布局：让展开面板可插入到对应行的正下方）
          _buildCategoryGrid(categories),
          // 负债选项内联在子分类面板的 Wrap 中（当 _expandedCategoryId == 'debt' 时），
          // 不再需要大分类区域下方的独立负债选择器
        ],
      ),
    );
  }

  /// 把大分类按每行 4 个布局；展开大分类所在行的正下方插入子分类面板
  Widget _buildCategoryGrid(List<CategoryItem> categories) {
    final totalItems = categories.length;
    final rows = (totalItems / 4).ceil();

    // 当前展开的大分类所在行索引（-1 表示未展开）
    final expandedRow = _expandedCategoryId == null
        ? -1
        : categories.indexWhere((c) => c.id == _expandedCategoryId) ~/ 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int row = 0; row < rows; row++) ...[
          Row(
            children: [
              for (int col = 0; col < 4; col++) ...[
                Expanded(
                  child: _buildCategoryGridCell(categories, row * 4 + col),
                ),
                if (col < 3) const SizedBox(width: 8),
              ],
            ],
          ),
          // 展开的大分类所在行的正下方插入子分类面板
          if (row == expandedRow) ...[
            const SizedBox(height: 12),
            _buildSubCategoryExpandedPanel(),
          ],
          if (row < rows - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  /// 构造指定 index 的 cell：分类 cell / 空占位
  Widget _buildCategoryGridCell(List<CategoryItem> categories, int index) {
    // 超出范围的格子用空白占位（保持行布局稳定）
    if (index >= categories.length) {
      return const SizedBox.shrink();
    }
    final cat = categories[index];
    final isExpanded = _expandedCategoryId == cat.id;
    final isSelected = _selectedCategoryId == cat.id && _selectedSubCategoryId == null;
    return _buildCategoryGridItem(cat, isSelected, isExpanded);
  }

  Widget _buildCategoryGridItem(CategoryItem cat, bool isSelected, bool isExpanded) {
    final hasSub = cat.sub.isNotEmpty;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = cat.id;
          _selectedCategoryName = cat.name;
          _selectedSubCategoryId = null;
          _selectedSubCategoryName = null;
          _selectedLiability = null;
          // 切换展开/收起：点已展开项再次点击收起（包括无子分类时的空态面板）
          _expandedCategoryId = isExpanded ? null : cat.id;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected || isExpanded
              ? cat.color.withValues(alpha: 0.16)
              : cat.color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected || isExpanded ? cat.color : Colors.transparent,
            width: (isSelected || isExpanded) ? 1.5 : 0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 分类专属配色：圆形彩色图标背景
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cat.color.withValues(alpha: isSelected || isExpanded ? 0.28 : 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      cat.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: isSelected || isExpanded ? FontWeight.w600 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasSub) ...[
                    const SizedBox(width: 2),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 12,
                      color: Colors.black,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// inline 展开的子分类面板（淡色背景 + 大分类色文字）
  Widget _buildSubCategoryExpandedPanel() {
    final categories = _readCurrentCategoriesFromDb(context);
    final selectedCat = categories.firstWhere(
      (c) => c.id == _expandedCategoryId,
      orElse: () => categories.isNotEmpty ? categories.first : _emptyCategory(),
    );

    // 还债大类：负债作为"子项"嵌进 Wrap 内
    final isDebt = selectedCat.id == 'debt';
    final liabilities = isDebt
        ? _availableLiabilities.where((l) => l.status == 0).toList()
        : <LocalLiabilitiesData>[];

    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          // 面板背景用 5% 分类色已经足够淡，文字直接走主题色更清晰
          color: selectedCat.color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCat.color.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部信息行：图标 + 分类名 + 子项数/笔数 + [添加小分类] + 收起箭头
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: selectedCat.color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(selectedCat.icon, color: selectedCat.color, size: 14),
                ),
                const SizedBox(width: 8),
                Text(
                  selectedCat.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    // 大分类名称：黑色
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: selectedCat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isDebt ? '${liabilities.length} 笔负债' : '${selectedCat.sub.length} 项',
                    // badge 文字保持分类色
                    style: TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                // 还债大类不允许自定义子分类，隐藏"添加小分类"
                if (!isDebt) ...[
                  GestureDetector(
                    onTap: () => _openAddSubCategoryPage(selectedCat),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        // 添加小分类文字保持分类色
                        Text('添加小分类', style: TextStyle(fontSize: 12, color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                GestureDetector(
                  onTap: () => setState(() => _expandedCategoryId = null),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 20,
                    // 收起箭头还原分类色（带 0.7 alpha）
                    color: selectedCat.color.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // 子项 Wrap：还债用负债 chip；其他用子分类 chip
            if (isDebt)
              _buildLiabilityChips(liabilities, selectedCat.color)
            else if (selectedCat.sub.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    '该分类下暂无小分类，点击右上"添加"创建',
                    style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final sub in selectedCat.sub)
                    _buildSubCategoryItem(sub, _selectedSubCategoryId == sub.id, color: selectedCat.color),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// 负债 chip 列表（用在还债大类展开面板的内嵌位置）
  Widget _buildLiabilityChips(List<LocalLiabilitiesData> liabilities, Color color) {
    if (liabilities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            '暂无未结清负债，请到负债台账添加',
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final l in liabilities)
          _buildLiabilityChip(l, _selectedLiability?.liabilityId == l.liabilityId, color),
      ],
    );
  }

  /// 负债 chip：未选用大分类色淡化版，选中用大分类色实色 + 白字
  Widget _buildLiabilityChip(LocalLiabilitiesData liability, bool isSelected, Color color) {
    final pendingAmount = liability.totalAmount - liability.repaidAmount;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLiability = liability;
          _selectedSubCategoryId = 'repay_liability';
          _selectedSubCategoryName = liability.name;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // 未选中边框加深（0.5）让 chip 轮廓清晰
            color: isSelected ? color : color.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              '${liability.name} ¥${pendingAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 13,
                // 文字改为主题主色，避免和分类色背景同色系看不清
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubCategoryItem(SubCategoryItem sub, bool isSelected, {Color? color}) {
    final isLiabilitySub = sub.id == 'repay_liability';
    // chip 主色：传入 color 时优先使用（如大分类主色），否则用 AppColors.primary
    final effectiveColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSubCategoryId = sub.id;
          _selectedSubCategoryName = sub.name;
          if (sub.id != 'repay_liability') {
            _selectedLiability = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor
              : effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // 未选中边框加深（0.5）让 chip 轮廓清晰
            color: isSelected ? effectiveColor : effectiveColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLiabilitySub) ...[
              Icon(Icons.account_balance_wallet, size: 14, color: isSelected ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              sub.name,
              style: TextStyle(
                fontSize: 13,
                // 文字改为主题主色，避免和分类色背景同色系看不清
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 注：原 _buildLiabilitySelector 已废弃，负债选项内联在 _buildSubCategoryExpandedPanel
  // 的 Wrap 中以 chip 形式展示（_buildLiabilityChips / _buildLiabilityChip）。

  CategoryItem _emptyCategory() => CategoryItem(
        id: '',
        name: '',
        icon: Icons.help_outline,
        color: AppColors.textTertiary,
      );

  // ============================================================
  // 5. 底部保存按钮（渐变风格）
  // ============================================================
  Widget _buildSaveButton() {
    final isExpense = _billTypeIndex == 0;
    final isIncome = _billTypeIndex == 1;
    final gradientColors = isExpense
        ? [const Color(0xFFFF6B6B), const Color(0xFFFF8E8E)]
        : isIncome
            ? [AppColors.income, const Color(0xFF34D399)]
            : [AppColors.primary, AppColors.primaryLight];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 54,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _amount > 0 ? gradientColors : [Colors.grey[400]!, Colors.grey[500]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: _amount > 0
            ? [
                BoxShadow(
                  color: gradientColors[0].withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _amount > 0 ? _saveBill : null,
          borderRadius: BorderRadius.circular(27),
          child: Center(
            child: Text(
              widget.bill != null ? '保存修改' : '保存',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 添加分类（跳转到新增分类全屏页面）
  // ============================================================
  Future<void> _openAddCategoryPage() async {
    String type = 'expense';
    if (_billTypeIndex == 1) {
      type = 'income';
    } else if (_billTypeIndex == 2) {
      type = 'other';
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCategoryPage(
          type: type,
          onCreated: (result) {
            // 已在 AddCategoryPage 内部写入数据库 + SnackBar 提示
          },
        ),
      ),
    );
  }

  // ============================================================
  // 数字键盘（嵌入在金额卡片内）
  // ============================================================
  void _showKeyboardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      isDismissible: true,
      builder: (ctx) => _KeyboardSheet(
        initialValue: _inputBuffer,
        onValueChanged: (val) {
          setState(() {
            _inputBuffer = val;
            _updateAmountDisplay();
          });
        },
        onReRecord: () async {
          _updateAmountDisplay();
          Navigator.pop(context);
          if (_amount > 0) {
            await _saveAndClear();
          }
        },
        onDone: () async {
          _updateAmountDisplay();
          Navigator.pop(context);
          if (_amount > 0) {
            await _saveBill();
            if (widget.bill == null && mounted) {
              Navigator.of(context).pop();
            }
          }
        },
      ),
    );
  }

  Future<void> _saveAndClear() async {
    if (_amount <= 0) return;
    final displayCategory = _selectedSubCategoryName ?? _selectedCategoryName ?? '未选分类';
    if (_selectedCategoryId != null) {
      context.read<RecordCategoryProvider>().recordUsage(_selectedCategoryId!);
    }
    await context.read<BillProvider>().addBill(
      type: _billType,
      amount: _amount,
      accountId: 'cash',
      categoryId: _selectedSubCategoryId ?? _selectedCategoryId,
      categoryName: displayCategory,
      remark: _remark.isEmpty ? null : _remark,
      billTime: _billTime,
      source: 'manual',
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已保存：$displayCategory ${_amount.toStringAsFixed(2)}元'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
      setState(() {
        _inputBuffer = '0';
        _updateAmountDisplay();
        _remark = '';
        _remarkController.clear();
        _selectedLiability = null;
        _selectFirstCategoryByDefault();
      });
    }
  }

  // ============================================================
  // 日期时间选择弹窗
  // ============================================================
  void _showDateTimePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DateTimePickerSheet(
        initialDateTime: _billTime,
        onConfirm: (dt) {
          setState(() => _billTime = dt);
        },
      ),
    );
  }

  // ============================================================
  // 添加小分类（弹窗输入名称即可，icon/color/type 继承父分类）
  // ============================================================
  Future<void> _openAddSubCategoryPage(CategoryItem parentCat) async {
    await showAddSubCategoryDialog(
      context,
      parentId: parentCat.id,
      parentName: parentCat.name,
      parentIcon: parentCat.icon,
      parentColor: parentCat.color,
    );
  }

  // ============================================================
  // 保存账单
  // ============================================================
  Future<void> _saveBill() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入金额')),
      );
      return;
    }

    if ((_selectedCategoryId == 'debt' || _selectedSubCategoryId == 'repay_liability') && _selectedLiability == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择要还款的负债记录')),
      );
      return;
    }

    final displayCategory = _selectedSubCategoryName ?? _selectedCategoryName ?? '未选分类';
    final categoryId = _selectedSubCategoryId ?? _selectedCategoryId;

    // 编辑模式
    if (widget.bill != null) {
      await context.read<BillProvider>().updateBill(
        billId: widget.bill!.billId,
        type: _billType,
        amount: _amount,
        accountId: widget.bill!.accountId,
        categoryId: categoryId,
        categoryName: displayCategory,
        remark: _remark.isEmpty ? null : _remark,
        billTime: _billTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('修改成功'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.of(context).pop(true);
      }
      return;
    }

    final liabilityId = _selectedLiability?.liabilityId;

    // 负债还款路径：统一走 LiabilityProvider.addRepay
    // （addRepay 内部已包含：写入 repay 记录 + 账单 + 更新 repaidAmount）
    // 普通账单：走 BillProvider.addBill
    bool success = false;
    if (liabilityId != null && liabilityId.isNotEmpty) {
      await context.read<LiabilityProvider>().addRepay(
        liabilityId: liabilityId,
        amount: _amount,
        accountId: 'cash',
        remark: _remark.isEmpty ? null : _remark,
        repayTime: _billTime,
      );
      success = true;
    } else {
      success = await context.read<BillProvider>().addBill(
        type: _billType,
        amount: _amount,
        accountId: 'cash',
        categoryId: categoryId,
        categoryName: displayCategory,
        remark: _remark.isEmpty ? null : _remark,
        billTime: _billTime,
        source: 'manual',
      );
    }

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('保存失败，请重试'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (liabilityId != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('还款成功：${_selectedLiability!.name} ¥${_amount.toStringAsFixed(2)}元'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    if (mounted) {
      if (_selectedCategoryId != null) {
        context.read<RecordCategoryProvider>().recordUsage(_selectedCategoryId!);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存成功：$displayCategory ${_amount.toStringAsFixed(2)}元'),
          backgroundColor: AppColors.primary,
        ),
      );
      setState(() {
        _inputBuffer = '0';
        _updateAmountDisplay();
        _remark = '';
        _remarkController.clear();
        _selectedLiability = null;
        _selectFirstCategoryByDefault();
      });
    }
  }

}

// ================================================================
// 日期时间选择弹窗
// ================================================================
class _DateTimePickerSheet extends StatefulWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onConfirm;

  const _DateTimePickerSheet({required this.initialDateTime, required this.onConfirm});

  @override
  State<_DateTimePickerSheet> createState() => _DateTimePickerSheetState();
}

class _DateTimePickerSheetState extends State<_DateTimePickerSheet> {
  late int _year;
  late int _month;
  late int _day;
  late int _hour;
  late int _minute;
  bool _showTimePicker = false;
  bool _showDatePicker = true;

  late FixedExtentScrollController _yearCtrl;
  late FixedExtentScrollController _monthCtrl;
  late FixedExtentScrollController _dayCtrl;
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    final dt = widget.initialDateTime;
    _year = dt.year;
    _month = dt.month;
    _day = dt.day;
    _hour = dt.hour;
    _minute = dt.minute;

    final now = DateTime.now();
    final startYear = now.year - 10;
    _yearCtrl = FixedExtentScrollController(initialItem: _year - startYear);
    _monthCtrl = FixedExtentScrollController(initialItem: _month - 1);
    _dayCtrl = FixedExtentScrollController(initialItem: _day - 1);
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute ~/ 5);
  }

  @override
  void dispose() {
    _yearCtrl.dispose();
    _monthCtrl.dispose();
    _dayCtrl.dispose();
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  int get _daysInMonth {
    if (_month == 2) {
      return (_year % 4 == 0 && _year % 100 != 0) || (_year % 400 == 0) ? 29 : 28;
    }
    if ([4, 6, 9, 11].contains(_month)) return 30;
    return 31;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startYear = now.year - 10;
    final endYear = now.year + 1;
    final years = List.generate(endYear - startYear, (i) => startYear + i);
    final months = List.generate(12, (i) => i + 1);
    final days = List.generate(_daysInMonth, (i) => i + 1);
    final hours = List.generate(24, (i) => i);
    final minutes = List.generate(12, (i) => i * 5);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text('选择日期时间',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.divider),
            if (_showDatePicker) ...[
              SizedBox(
                height: 180,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildWheel(
                        controller: _yearCtrl,
                        items: years,
                        labelBuilder: (y) => y.toString(),
                        onChanged: (idx) {
                          setState(() {
                            _year = years[idx];
                            if (_day > _daysInMonth) _day = _daysInMonth;
                          });
                        },
                      ),
                    ),
                    Text('年', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildWheel(
                        controller: _monthCtrl,
                        items: months,
                        labelBuilder: (m) => m.toString().padLeft(2, '0'),
                        onChanged: (idx) {
                          setState(() {
                            _month = months[idx];
                            if (_day > _daysInMonth) _day = _daysInMonth;
                          });
                        },
                      ),
                    ),
                    Text('月', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildWheel(
                        controller: _dayCtrl,
                        items: days,
                        labelBuilder: (d) => d.toString().padLeft(2, '0'),
                        onChanged: (idx) {
                          setState(() => _day = days[idx]);
                        },
                      ),
                    ),
                    Text('日', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 20),
                  ],
                ),
              ),
            ],
            GestureDetector(
              onTap: () {
                setState(() {
                  _showTimePicker = !_showTimePicker;
                  _showDatePicker = !_showTimePicker;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.access_time, size: 18, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text('时刻', style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _showTimePicker ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      size: 22, color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            if (_showTimePicker) ...[
              Container(
                height: 150,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const SizedBox(width: 40),
                    Expanded(
                      child: _buildWheel(
                        controller: _hourCtrl,
                        items: hours,
                        labelBuilder: (h) => h.toString().padLeft(2, '0'),
                        onChanged: (idx) => setState(() => _hour = hours[idx]),
                      ),
                    ),
                    Text('时', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildWheel(
                        controller: _minuteCtrl,
                        items: minutes,
                        labelBuilder: (m) => m.toString().padLeft(2, '0'),
                        onChanged: (idx) => setState(() => _minute = minutes[idx]),
                      ),
                    ),
                    Text('分', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.divider),
                      ),
                      child: Text('取消', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          final dt = DateTime(_year, _month, _day, _hour, _minute);
                          widget.onConfirm(dt);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('确认', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<int> items,
    required String Function(int) labelBuilder,
    required ValueChanged<int> onChanged,
  }) {
    return SizedBox(
      height: 180,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        perspective: 0.004,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: items.length,
          builder: (context, index) => Center(
            child: Text(
              labelBuilder(items[index]),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

// ================================================================

// ================================================================
// 数字键盘底部弹窗
// ================================================================
class _KeyboardSheet extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onValueChanged;
  final VoidCallback onReRecord;
  final VoidCallback onDone;

  const _KeyboardSheet({
    required this.initialValue,
    required this.onValueChanged,
    required this.onReRecord,
    required this.onDone,
  });

  @override
  State<_KeyboardSheet> createState() => _KeyboardSheetState();
}

class _KeyboardSheetState extends State<_KeyboardSheet> {
  String _rawDisplay = '';
  String _currentNum = '';

  @override
  void initState() {
    super.initState();
    final init = widget.initialValue == '0.00' ? '' : widget.initialValue;
    if (init.isNotEmpty && init != '0') {
      _rawDisplay = init;
      _currentNum = init;
    }
  }

  void _onKey(String key) {
    setState(() {
      if (key == '删除') {
        if (_rawDisplay.isEmpty) return;
        _rawDisplay = _rawDisplay.substring(0, _rawDisplay.length - 1);
        if (_rawDisplay.isEmpty) {
          _currentNum = '';
        } else {
          final matches = RegExp(r'[+\-]').allMatches(_rawDisplay).toList();
          if (matches.isEmpty) {
            _currentNum = _rawDisplay;
          } else {
            final lastMatch = matches.last;
            final afterOp = _rawDisplay.substring(lastMatch.end);
            _currentNum = afterOp;
          }
        }
      } else if (key == '.') {
        if (_currentNum.contains('.')) return;
        _currentNum += _currentNum.isEmpty ? '0.' : '.';
        _rawDisplay += _currentNum.substring(_currentNum.length - 1);
      } else if (key == '+' || key == '-') {
        if (_rawDisplay.isEmpty) return;
        if (_rawDisplay.endsWith('+') || _rawDisplay.endsWith('-')) {
          _rawDisplay = _rawDisplay.substring(0, _rawDisplay.length - 1) + key;
          return;
        }
        _currentNum = '';
        _rawDisplay += key;
      } else {
        if (_currentNum == '0') {
          _currentNum = key;
        } else {
          final dotIdx = _currentNum.indexOf('.');
          if (dotIdx == -1 && _currentNum.length < 10) {
            _currentNum += key;
          } else if (dotIdx != -1 && _currentNum.length - dotIdx <= 2) {
            _currentNum += key;
          }
        }
        _rawDisplay += key;
      }
      _emitValue();
    });
  }

  void _emitValue() {
    widget.onValueChanged(_rawDisplay.isEmpty ? '0' : _rawDisplay);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final keys = [
      ['1', '2', '3', '删除'],
      ['4', '5', '6', '+'],
      ['7', '8', '9', '-'],
      ['.', '0', '00'],
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          ...keys.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: row.map((key) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildKeyButton(key),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildActionButton(
                      label: '再记一笔',
                      icon: Icons.refresh,
                      color: AppColors.primary.withValues(alpha: 0.1),
                      textColor: AppColors.primary,
                      onTap: widget.onReRecord,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildActionButton(
                      label: '完成',
                      icon: Icons.check,
                      color: const Color(0xFFFFC107),
                      textColor: Colors.white,
                      onTap: widget.onDone,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildKeyButton(String key) {
    final isDelete = key == '删除';
    final isOperator = key == '+' || key == '-';
    final is00 = key == '00';

    Color bgColor = Colors.white;
    Color borderColor = AppColors.divider;
    Color textColor = AppColors.textPrimary;

    if (isDelete) {
      bgColor = AppColors.background;
    } else if (isOperator) {
      bgColor = AppColors.primary.withValues(alpha: 0.1);
      borderColor = AppColors.primary.withValues(alpha: 0.3);
      textColor = AppColors.primary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onKey(key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Center(
            child: isDelete
                ? Icon(Icons.backspace_outlined, size: 22, color: AppColors.textSecondary)
                : Text(
                    key,
                    style: TextStyle(
                      fontSize: is00 ? 20 : 24,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
