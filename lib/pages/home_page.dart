import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/bill_provider.dart';
import '../providers/category_provider.dart';
import '../database/database.dart';
import '../ui_constants.dart';
import 'record_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showAmount = true;
  final ScrollController _scrollController = ScrollController();

  // 多选相关状态
  bool _isMultiSelectMode = false;
  final Set<String> _selectedBillIds = {};

  // 操作菜单状态
  OverlayEntry? _menuOverlay;
  Offset _menuPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 进入首页时确保最新数据
      context.read<BillProvider>().refresh();
    });
  }

  /// 监听滚动：距离底部 200px 时触发加载更多
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      context.read<BillProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _removeMenu();
    _scrollController.dispose();
    super.dispose();
  }

  /// 显示操作菜单
  void _showOperationMenu(LocalBillsData bill, Offset globalPosition) {
    _removeMenu();

    // 计算菜单位置，确保不超出屏幕
    final screenSize = MediaQuery.of(context).size;
    final menuWidth = 140.0;
    final menuHeight = 88.0;

    double left = globalPosition.dx;
    double top = globalPosition.dy;

    // 如果右侧空间不够，往左偏移
    if (left + menuWidth > screenSize.width - 16) {
      left = screenSize.width - menuWidth - 16;
    }

    // 如果下方空间不够，往上偏移
    if (top + menuHeight > screenSize.height - 100) {
      top = globalPosition.dy - menuHeight - 20;
    }

    _menuPosition = Offset(left, top);

    _menuOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // 半透明遮罩，点击关闭菜单
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeMenu,
              onLongPressStart: (_) => _removeMenu(),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          // 操作菜单
          Positioned(
            left: _menuPosition.dx,
            top: _menuPosition.dy,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              child: Container(
                width: menuWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem(
                      icon: Icons.check_circle_outline,
                      iconColor: AppColors.primary,
                      text: '多选',
                      onTap: () {
                        _removeMenu();
                        _enterMultiSelectMode(bill.billId);
                      },
                    ),
                    Container(height: 0.5, color: AppColors.divider),
                    _buildMenuItem(
                      icon: Icons.delete_outline,
                      iconColor: Colors.red,
                      text: '删除',
                      onTap: () {
                        _removeMenu();
                        _deleteSingleBill(bill);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_menuOverlay!);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: iconColor == Colors.red ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeMenu() {
    _menuOverlay?.remove();
    _menuOverlay = null;
  }

  /// 进入多选模式
  void _enterMultiSelectMode(String initialBillId) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedBillIds.add(initialBillId);
    });
  }

  /// 退出多选模式
  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedBillIds.clear();
    });
  }

  /// 切换选中状态
  void _toggleSelection(String billId) {
    setState(() {
      if (_selectedBillIds.contains(billId)) {
        _selectedBillIds.remove(billId);
      } else {
        _selectedBillIds.add(billId);
      }
    });
  }

  /// 全选
  void _selectAll(List<LocalBillsData> bills) {
    setState(() {
      _selectedBillIds.clear();
      for (final bill in bills) {
        _selectedBillIds.add(bill.billId);
      }
    });
  }

  /// 取消全选
  void _deselectAll() {
    setState(() {
      _selectedBillIds.clear();
    });
  }

  /// 删除单条账单
  Future<void> _deleteSingleBill(LocalBillsData bill) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条账单吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await context.read<BillProvider>().deleteBill(bill.billId);
    }
  }

  /// 删除选中的账单
  Future<void> _deleteSelectedBills() async {
    if (_selectedBillIds.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedBillIds.length} 条账单吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final billProvider = context.read<BillProvider>();
      for (final billId in _selectedBillIds) {
        await billProvider.deleteBill(billId);
      }
      _exitMultiSelectMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _isMultiSelectMode ? null : _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // 固定头部：汇总卡片 + 自动记账状态（不参与列表滑动）
            if (!_isMultiSelectMode) _buildSummaryCard(),
            if (!_isMultiSelectMode) _buildAutoRecordStatus(),
            // 账单列表：独立上下滑动
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await context.read<BillProvider>().refresh();
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    if (_isMultiSelectMode) _buildMultiSelectAppBar(),
                    ..._buildBillListSlivers(),
                  ],
                ),
              ),
            ),
            // 底部删除栏
            if (_isMultiSelectMode) _buildDeleteBar(),
          ],
        ),
      ),
    );
  }

  /// 多选模式的AppBar
  Widget _buildMultiSelectAppBar() {
    final isAllSelected = _selectedBillIds.isNotEmpty &&
        context.read<BillProvider>().bills.isNotEmpty &&
        _selectedBillIds.length == context.read<BillProvider>().bills.length;

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      pinned: false,
      leading: IconButton(
        icon: Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: _exitMultiSelectMode,
      ),
      title: Text(
        '已选择 ${_selectedBillIds.length} 项',
        style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () {
            if (isAllSelected) {
              _deselectAll();
            } else {
              final bills = context.read<BillProvider>().bills;
              _selectAll(bills);
            }
          },
          child: Text(
            isAllSelected ? '取消全选' : '全选',
            style: TextStyle(color: AppColors.primary, fontSize: 15),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      title: Text('记账', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
      actions: [
        Consumer<AppProvider>(
          builder: (context, app, _) {
            return Row(
              children: [
                if (!app.isOnline)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                    child: const Text('离线', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                if (app.pendingSyncCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Badge(label: Text('${app.pendingSyncCount}'), child: const Icon(Icons.sync, size: 22)),
                  ),
              ],
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<BillProvider>(
      builder: (context, bill, _) {
        final summary = bill.summary;
        final todayExpense = (summary['todayExpense'] ?? 98.88).toDouble();
        final monthExpense = (summary['monthExpense'] ?? 598.98).toDouble();
        final monthIncome = (summary['monthIncome'] ?? 45.00).toDouble();

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.cardBlue, AppColors.cardBlueLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            boxShadow: [
              BoxShadow(color: AppColors.cardBlue.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：今日支出 + 眼睛图标
                Row(
                  children: [
                    const Text('今日支出（元）', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showAmount = !_showAmount),
                      child: Icon(_showAmount ? Icons.visibility : Icons.visibility_off, color: Colors.white70, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _showAmount ? todayExpense.toStringAsFixed(2) : '***',
                  style: AppTextStyles.moneyLarge,
                ),
                const SizedBox(height: 16),
                // 第二行：本月支出 + 本月收入
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('本月支出（元）', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            _showAmount ? monthExpense.toStringAsFixed(2) : '***',
                            style: AppTextStyles.moneyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 36, color: Colors.white24),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('本月收入（元）', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              _showAmount ? monthIncome.toStringAsFixed(2) : '***',
                              style: AppTextStyles.moneyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAutoRecordStatus() {
    return Consumer<AppProvider>(
      builder: (context, app, _) {
        // 计算权限状态（通知栏监听已移除）
        final hasAccessibility = app.accessibilityPermissionGranted;
        final anyEnabled = app.accessibilityAutoRecordEnabled;
        
        // 计算状态颜色和文字
        Color statusColor;
        String statusText;
        IconData statusIcon;
        
        if (!hasAccessibility) {
          statusColor = Colors.red;
          statusText = '请授权无障碍服务以开启自动记账';
          statusIcon = Icons.warning_amber;
        } else if (!anyEnabled) {
          statusColor = Colors.grey;
          statusText = '自动记账未开启，点击设置开启';
          statusIcon = Icons.auto_awesome_outlined;
        } else {
          statusColor = Colors.purple;
          statusText = '自动记账已开启（无障碍）';
          statusIcon = Icons.auto_awesome;
        }
        
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingPage()),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // 权限状态指示
                      Row(
                        children: [
                          _buildPermissionBadge('无障碍', hasAccessibility),
                        ],
                      ),
                    ],
                  ),
                ),
                // 快捷授权按钮
                if (hasAccessibility && !app.accessibilityAutoRecordEnabled)
                  _buildQuickToggle(
                    icon: Icons.accessibility_new,
                    color: Colors.purple,
                    tooltip: '开启无障碍记账',
                    onPressed: () => app.setAccessibilityAutoRecordEnabled(true),
                  ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickToggle({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, color: color, size: 20),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  /// 构建权限状态徽章
  Widget _buildPermissionBadge(String label, bool granted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: granted ? Colors.green.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.circle_outlined,
            size: 10,
            color: granted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: granted ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 流水列表 + 底部加载更多 footer
  List<Widget> _buildBillListSlivers() {
    return [
      Consumer2<BillProvider, CategoryProvider>(
        builder: (context, billProvider, categoryProvider, _) {
          final bills = billProvider.bills;

          if (bills.isEmpty && !billProvider.isLoading) {
            return SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 48),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('暂无账单记录', style: TextStyle(color: AppColors.textTertiary, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text('点击底部"记一笔"添加账单', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                  ],
                ),
              ),
            );
          }

          // 按日期分组
          final billGroups = _groupBillsByDate(bills);

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                int itemIndex = 0;
                for (final group in billGroups) {
                  if (itemIndex == index) {
                    return _buildGroupHeader(group, categoryProvider);
                  }
                  itemIndex++;

                  for (final bill in group.bills) {
                    if (itemIndex == index) {
                      return _buildBillItem(bill, group.date, categoryProvider);
                    }
                    itemIndex++;
                  }
                }
                return const SizedBox.shrink();
              },
              childCount: _calculateTotalCount(billGroups),
            ),
          );
        },
      ),
      // 底部状态：loading / 已加载全部 / 加载更多
      SliverToBoxAdapter(child: _buildBillListFooter()),
    ];
  }

  /// 底部 footer：loading 圈 / "已加载全部 X 条" / "上拉加载更多"
  Widget _buildBillListFooter() {
    return Consumer<BillProvider>(
      builder: (context, bp, _) {
        // 列表为空时不显示
        if (bp.bills.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: bp.isLoadingMore
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('加载中…', style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  )
                : Text(
                    bp.hasMore
                        ? '上拉加载更多（已加载 ${bp.bills.length}/${bp.totalCount}）'
                        : '已加载全部 ${bp.totalCount} 条',
                    style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                  ),
          ),
        );
      },
    );
  }

  List<_DateBillGroup> _groupBillsByDate(List<LocalBillsData> bills) {
    final Map<String, List<LocalBillsData>> grouped = {};
    for (final bill in bills) {
      final dateKey = DateFormat('yyyy-MM-dd').format(bill.billTime);
      grouped.putIfAbsent(dateKey, () => []).add(bill);
    }

    final groups = <_DateBillGroup>[];
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final key in sortedKeys) {
      final date = DateFormat('yyyy-MM-dd').parse(key);
      groups.add(_DateBillGroup(date: date, bills: grouped[key]!));
    }

    return groups;
  }

  int _calculateTotalCount(List<_DateBillGroup> groups) {
    int count = 0;
    for (final g in groups) {
      count += 1 + g.bills.length;
    }
    return count;
  }

  Widget _buildGroupHeader(_DateBillGroup group, CategoryProvider categoryProvider) {
    final dateFormat = DateFormat('yyyy.MM.dd');
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String dateLabel;
    if (group.date == today) {
      dateLabel = '今天';
    } else if (group.date == yesterday) {
      dateLabel = '昨天';
    } else {
      dateLabel = DateFormat('EEEE').format(group.date)
          .replaceAll('Monday', '星期一').replaceAll('Tuesday', '星期二')
          .replaceAll('Wednesday', '星期三').replaceAll('Thursday', '星期四')
          .replaceAll('Friday', '星期五').replaceAll('Saturday', '星期六')
          .replaceAll('Sunday', '星期日');
    }

    double totalExpense = 0;
    double totalIncome = 0;
    for (final b in group.bills) {
      if (b.type == 'expense') {
        totalExpense += b.amount;
      } else {
        totalIncome += b.amount;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${dateFormat.format(group.date)}  ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: dateLabel,
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            '支${totalExpense.toStringAsFixed(2)}  收${totalIncome.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildBillItem(LocalBillsData bill, DateTime groupDate, CategoryProvider categoryProvider) {
    // 获取分类图标和颜色（应用"子分类展示大分类"语义）
    final categoryInfo = categoryProvider.getCategoryIconAndColor(bill);
    final isSelected = _selectedBillIds.contains(bill.billId);

    return Column(
      children: [
        // 点击和长按处理
        GestureDetector(
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleSelection(bill.billId);
            } else {
              // 跳转到编辑页面
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RecordPage(bill: bill),
                ),
              );
            }
          },
          onLongPressStart: (details) {
            if (!_isMultiSelectMode) {
              _showOperationMenu(bill, details.globalPosition);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
            ),
              child: Row(
                children: [
                  // 多选复选框
                  if (_isMultiSelectMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? AppColors.primary : AppColors.textTertiary,
                        size: 22,
                      ),
                    ),
                  // 圆形分类图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: categoryInfo.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(categoryInfo.icon, color: categoryInfo.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // 分类名称 + 时间
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.categoryName ?? '未分类',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('HH:mm').format(bill.billTime),
                          style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  // 金额（根据类型显示不同颜色）
                  Text(
                    bill.type == 'expense'
                        ? '-${bill.amount.toStringAsFixed(2)}'
                        : '+${bill.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: bill.type == 'expense' ? AppColors.expense : AppColors.income,
                    ),
                  ),
                ],
              ),
            ),
        ),
        // 分割线
        Container(
          margin: EdgeInsets.only(left: _isMultiSelectMode ? 80 : 68),
          height: 0.5,
          color: AppColors.divider,
        ),
      ],
    );
  }

  /// 底部删除栏
  Widget _buildDeleteBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 12,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '已选择 ${_selectedBillIds.length} 条账单',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _selectedBillIds.isEmpty ? null : _deleteSelectedBills,
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('删除'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedBillIds.isEmpty ? Colors.grey[300] : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// 按日期分组的账单数据结构
class _DateBillGroup {
  final DateTime date;
  final List<LocalBillsData> bills;
  _DateBillGroup({required this.date, required this.bills});
}
