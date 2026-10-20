import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../providers/liability_provider.dart';
import '../widgets/common_widgets.dart';
import '../database/database.dart';
import '../ui_constants.dart';
import 'add_liability_page.dart';
import 'setting_page.dart';
import 'liability/liability_theme.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedFilter = 1; // 1未结清, 2已结清

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LiabilityProvider>().loadSummary();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const SizedBox(width: 48), // 占位，保持标题居中
        title: Text(
          '负债',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab 切换
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: '负债概览'),
                Tab(text: '还款记录'),
              ],
            ),
          ),
          // Tab 内容
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLiabilityList(),
                _buildRepayHistory(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: DebtColors.dangerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: DebtColors.danger.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddLiabilityPage()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildLiabilityList() {
    return Consumer<LiabilityProvider>(
      builder: (context, provider, _) {
        return RefreshIndicator(
          onRefresh: () => provider.loadSummary(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildSummaryCard(provider)),
              SliverToBoxAdapter(child: _buildFilterChips()),
              if (provider.liabilities.isEmpty)
                const SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: '暂无负债记录',
                    subtitle: '点击右下角添加负债',
                  ),
                )
              else ...[
                // 按类型分组展示
                ..._buildGroupedLiabilities(provider),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 按类型分组展示负债
  List<Widget> _buildGroupedLiabilities(LiabilityProvider provider) {
    final filtered = _getFilteredLiabilities(provider.liabilities);
    final grouped = _groupByType(filtered);

    final widgets = <Widget>[];

    for (final type in liabilityTypeConfigs) {
      if (grouped.containsKey(type.value) && grouped[type.value]!.isNotEmpty) {
        // 类型标题
        widgets.add(SliverToBoxAdapter(child: _buildTypeSectionHeader(type, grouped[type.value]!)));
        // 该类型的负债列表
        for (final liability in grouped[type.value]!) {
          widgets.add(SliverToBoxAdapter(child: _buildLiabilityItem(liability, provider)));
        }
      }
    }

    return widgets;
  }

  /// 按类型分组
  Map<String, List<LocalLiabilitiesData>> _groupByType(List<LocalLiabilitiesData> list) {
    final grouped = <String, List<LocalLiabilitiesData>>{};
    for (final liability in list) {
      grouped.putIfAbsent(liability.type, () => []).add(liability);
    }
    return grouped;
  }

  /// 类型分组标题
  Widget _buildTypeSectionHeader(LiabilityTypeConfig type, List<LocalLiabilitiesData> items) {
    final totalPending = items.fold<double>(0, (sum, l) => sum + (l.totalAmount - l.repaidAmount));

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          // 渐变背景的图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: type.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: type.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(type.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: type.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${items.length}笔',
                        style: TextStyle(
                          fontSize: 11,
                          color: type.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '待还 ¥${totalPending.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: totalPending > 0 ? DebtColors.danger : DebtColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 是否信贷机构类型（消费分期 / 月付信贷）
bool _isCreditInstitution(String type) {
  return type == 'installment' || type == 'other';
}

/// 机构前缀文案
String _institutionLabel(String type) {
  switch (type) {
    case 'credit_card':
      return '银行';
    case 'mortgage':
    case 'car_loan':
      return '银行机构';
    case 'installment':
    case 'other':
      return '信贷机构';
    default:
      return '机构';
  }
}

List<LocalLiabilitiesData> _getFilteredLiabilities(List<LocalLiabilitiesData> list) {
    switch (_selectedFilter) {
      case 1:
        return list.where((l) => l.status == 0).toList();
      case 2:
        return list.where((l) => l.status == 1).toList();
      default:
        return list;
    }
  }

  Widget _buildSummaryCard(LiabilityProvider provider) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final summary = provider.summary;
    final totalLiability = (summary['totalLiability'] ?? provider.totalLiability).toDouble();
    final pendingRepay = (summary['pendingRepay'] ?? provider.pendingRepay).toDouble();
    final repaidAmount = (summary['repaid'] ?? provider.repaidAmount).toDouble();
    final overdueAmount = (summary['overdueAmount'] ?? 0).toDouble();
    final thisMonthRepay = (summary['thisMonthRepay'] ?? 0).toDouble();
    final nextMonthRepay = (summary['nextMonthRepay'] ?? 0).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.expense,
            AppColors.expense.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.expense.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect 让内部圆角干净，并裁掉 Padding 内可能的溢出
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 三列汇总
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem('总负债', formatter.format(totalLiability)),
                  _buildDivider(),
                  _buildSummaryItem('待还', formatter.format(pendingRepay)),
                  _buildDivider(),
                  _buildSummaryItem('已还', formatter.format(repaidAmount)),
                ],
              ),
              if (overdueAmount > 0) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '超期欠款',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatter.format(overdueAmount),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              // 本月待还 + 下月待还
              Row(
                children: [
                  Expanded(
                    child: _buildMonthlyRepayCard(
                      label: '本月待还',
                      amount: thisMonthRepay,
                      formatter: formatter,
                      icon: Icons.calendar_month,
                      gradientColors: DebtColors.warningGradient,
                      shadowColor: DebtColors.warningGradient.last,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMonthlyRepayCard(
                      label: '下月待还',
                      amount: nextMonthRepay,
                      formatter: formatter,
                      icon: Icons.event,
                      gradientColors: DebtColors.infoGradient,
                      shadowColor: DebtColors.infoGradient.first,
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

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 列表项内的信息 chip（还款日 / 本月待还 / 本月已还清）
  Widget _buildListChip({
    required IconData icon,
    required String text,
    required Color color,
    required double bgAlpha,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: bgAlpha),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 本月/下月待还卡片
  Widget _buildMonthlyRepayCard({
    required String label,
    required double amount,
    required NumberFormat formatter,
    required IconData icon,
    required List<Color> gradientColors,
    required Color shadowColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatter.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'label': '未结清', 'value': 1},
      {'label': '已结清', 'value': 2},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['value'];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: f['value'] == 1 ? 0 : 6,
                right: f['value'] == 2 ? 0 : 6,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilter = f['value'] as int),
                    borderRadius: BorderRadius.circular(18),
                    child: Center(
                      child: Text(
                        f['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLiabilityItem(LocalLiabilitiesData liability, LiabilityProvider provider) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final progress = liability.totalAmount > 0 ? liability.repaidAmount / liability.totalAmount : 0.0;
    // 逾期状态由 provider 计算（覆盖月付类和一次性两类）
    final isOverdue = provider.liabilityIsOverdue(liability);
    final overdueDays = provider.liabilityOverdueDays(liability);
    final overdueAmount = provider.liabilityOverdueAmount(liability);

    // 获取类型配置
    final typeConfig = getTypeConfig(liability.type);

    // 计算列表项的"还款日"和"待还金额"
    final repayDay = provider.liabilityRepayDay(liability);
    final monthlyAmount = provider.liabilityMonthlyAmount(liability);
    // 月付类负债：待还金额展示月供（与 本月/下月待还 卡片保持口径一致）
    // 一次性负债：展示剩余本金 totalAmount - repaidAmount
    final isMonthlyType = liability.type == 'mortgage' ||
        liability.type == 'car_loan' ||
        liability.type == 'installment';
    // 持续性负债（信用卡/月付信贷/私人借款）没有到期日，不展示 dueDate
    final hasMeaningfulDueDate = provider.liabilityHasDueDate(liability);
    final thisMonth = provider.liabilityThisMonthRepay(liability);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? DebtColors.danger.withValues(alpha: 0.3)
              : AppColors.divider.withValues(alpha: 0.5),
          width: isOverdue ? 1.5 : 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLiabilityDetail(liability),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 第一行：类型标签 + 负债名称 + 同步状态
                Row(
                  children: [
                    // 类型标签
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: typeConfig.gradient,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(typeConfig.icon, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            typeConfig.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 负债名称
                    Expanded(
                      child: Text(
                        liability.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (liability.syncStatus == 0)
                      SyncStatusBadge(syncStatus: 0),
                  ],
                ),
                const SizedBox(height: 12),
                // 第二行：金额信息
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 机构名称（如果有）
                          if (liability.institution != null && liability.institution!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _isCreditInstitution(liability.type)
                                        ? Icons.store
                                        : Icons.account_balance,
                                    size: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_institutionLabel(liability.type)}：${liability.institution!}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                '待还金额',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatter.format(
                                  isMonthlyType ? monthlyAmount : (liability.totalAmount - liability.repaidAmount),
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isOverdue ? AppColors.expense : AppColors.expense.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 状态指示
                    if (liability.status == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: DebtColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: DebtColors.success, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '已结清',
                              style: TextStyle(
                                fontSize: 12,
                                color: DebtColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                // 还款日 + 本月待还（仅未结清时展示）
                if (liability.status == 0 && (repayDay != null || thisMonth > 0)) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // 还款日 chip
                      if (repayDay != null)
                        _buildListChip(
                          icon: Icons.event_repeat,
                          text: '每月$repayDay日',
                          color: AppColors.primary,
                          bgAlpha: 0.08,
                        ),
                      if (repayDay != null && thisMonth > 0) const SizedBox(width: 8),
                      // 本月待还 chip
                      if (thisMonth > 0)
                        _buildListChip(
                          icon: Icons.payments_outlined,
                          text: '本月待还 ${formatter.format(thisMonth)}',
                          color: DebtColors.warning,
                          bgAlpha: 0.1,
                        )
                      else if (provider.liabilityHasRepayThisMonth(liability))
                        _buildListChip(
                          icon: Icons.check_circle_outline,
                          text: '本月已还清',
                          color: DebtColors.success,
                          bgAlpha: 0.1,
                        ),
                    ],
                  ),
                ],
                // 逾期提醒横幅
                if (isOverdue) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: DebtColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: DebtColors.danger.withValues(alpha: 0.35),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: DebtColors.danger,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '已逾期 $overdueDays 天 · 待还 ${formatter.format(overdueAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: DebtColors.danger,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          size: 14,
                          color: DebtColors.danger,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                // 进度条
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.divider,
                    valueColor: AlwaysStoppedAnimation(
                      liability.status == 1 ? DebtColors.success : typeConfig.color,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 10),
                // 底部信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '已还 ${formatter.format(liability.repaidAmount)} / ${formatter.format(liability.totalAmount)}',
                      style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                    ),
                    if (isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: DebtColors.dangerGradient,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning_rounded, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              '已逾期',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (hasMeaningfulDueDate)
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: 12, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '到期 ${DateFormat('yyyy-MM-dd').format(liability.dueDate)}',
                            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepayHistory() {
    return Consumer<LiabilityProvider>(
      builder: (context, provider, _) {
        final liabilities = provider.liabilities;
        if (liabilities.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            title: '暂无还款记录',
            subtitle: '登记还款后会显示在这里',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
          itemCount: liabilities.length,
          itemBuilder: (context, index) {
            final liability = liabilities[index];
            return _buildLiabilityRepaySection(liability);
          },
        );
      },
    );
  }

  Widget _buildLiabilityRepaySection(LocalLiabilitiesData liability) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final typeConfig = getTypeConfig(liability.type);
    final monthlyAmount = context.read<LiabilityProvider>().liabilityMonthlyAmount(liability);
    final isMonthlyType = liability.type == 'mortgage' ||
        liability.type == 'car_loan' ||
        liability.type == 'installment';
    final pendingText = isMonthlyType ? monthlyAmount : liability.totalAmount - liability.repaidAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: typeConfig.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            typeConfig.icon,
            color: typeConfig.color,
            size: 22,
          ),
        ),
        title: Text(
          liability.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '待还：${formatter.format(pendingText)}',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
        children: [
          // 登记还款按钮
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: typeConfig.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddRepayDialog(context, liability),
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline, color: typeConfig.color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '登记还款',
                      style: TextStyle(
                        color: typeConfig.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 还款记录列表
          StreamBuilder<List<LocalLiabilityRepaysData>>(
            stream: context.read<LiabilityProvider>().watchRepays(liability.liabilityId),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 40, color: AppColors.textTertiary.withValues(alpha: 0.6)),
                      const SizedBox(height: 8),
                      Text(
                        '暂无还款记录',
                        style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }
              final repays = snapshot.data!;
              return Column(
                children: repays.map((r) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: DebtColors.success.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check, color: DebtColors.success, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '还款 ${formatter.format(r.amount)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (r.remark != null && r.remark!.isNotEmpty)
                                Text(
                                  r.remark!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('MM-dd HH:mm').format(r.repayTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showLiabilityDetail(LocalLiabilitiesData liability) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final provider = context.read<LiabilityProvider>();
    final typeConfig = getTypeConfig(liability.type);
    final monthlyAmount = provider.liabilityMonthlyAmount(liability);
    final isMonthlyType = liability.type == 'mortgage' ||
        liability.type == 'car_loan' ||
        liability.type == 'installment';
    final pendingAmount = isMonthlyType ? monthlyAmount : (liability.totalAmount - liability.repaidAmount);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: typeConfig.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            typeConfig.icon,
                            color: typeConfig.color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                liability.name,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: typeConfig.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  typeConfig.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: typeConfig.color,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 金额信息
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('总金额', formatter.format(liability.totalAmount), AppColors.textPrimary),
                          const SizedBox(height: 12),
                          _buildDetailRow('已还金额', formatter.format(liability.repaidAmount), DebtColors.success),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            '待还金额',
                            formatter.format(pendingAmount),
                            DebtColors.danger,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 其他信息
                    if (liability.institution != null && liability.institution!.isNotEmpty)
                      _buildDetailInfoRow(
                      _isCreditInstitution(liability.type) ? Icons.store : Icons.account_balance,
                      _institutionLabel(liability.type),
                      liability.institution!,
                    ),
                    if (liability.loanDate != null && liability.loanDate!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailInfoRow(Icons.calendar_month, '还款日', liability.loanDate!),
                    ],
                    if (provider.liabilityHasDueDate(liability)) ...[
                      const SizedBox(height: 12),
                      _buildDetailInfoRow(Icons.calendar_today, '到期日', DateFormat('yyyy-MM-dd').format(liability.dueDate)),
                    ],
                    if (liability.remark != null && liability.remark!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildDetailInfoRow(Icons.note, '备注', liability.remark!),
                    ],
                    const SizedBox(height: 24),
                    // 按钮
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: typeConfig.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  _showAddRepayDialog(context, liability);
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.payment, color: typeConfig.color, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '还款',
                                        style: TextStyle(
                                          color: typeConfig.color,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: AppColors.current.isDark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  // 先保存需要的数据
                                  final liabilityId = liability.liabilityId;
                                  final provider = context.read<LiabilityProvider>();
                                  Navigator.pop(context);
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('确认删除'),
                                      content: const Text('确定要删除这条负债记录吗？'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('取消'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(ctx, true),
                                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
                                          child: const Text('删除'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await provider.deleteLiability(liabilityId);
                                  }
                                },
                                borderRadius: BorderRadius.circular(25),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.delete_outline, color: AppColors.expense, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        '删除',
                                        style: TextStyle(
                                          color: AppColors.expense,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  void _showAddRepayDialog(BuildContext context, LocalLiabilitiesData liability) {
    final typeConfig = getTypeConfig(liability.type);
    final monthlyAmount = context.read<LiabilityProvider>().liabilityMonthlyAmount(liability);
    final isMonthlyType = liability.type == 'mortgage' ||
        liability.type == 'car_loan' ||
        liability.type == 'installment';
    final pendingAmount = isMonthlyType ? monthlyAmount : (liability.totalAmount - liability.repaidAmount);

    // 消费分期 / 房贷 / 车贷：默认填充月供金额（可手动修改）
    final amountController = TextEditingController(
      text: isMonthlyType && monthlyAmount > 0
          ? monthlyAmount.toStringAsFixed(2)
          : '',
    );
    final remarkController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖动条
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 标题
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: typeConfig.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.payment, color: typeConfig.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '登记还款',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            liability.name,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 待还金额提示
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '待还金额',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      Text(
                        '¥${pendingAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DebtColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 金额输入
                Text(
                  '还款金额',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 24, fontWeight: FontWeight.bold),
                      prefixText: '¥ ',
                      prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 备注输入
                Text(
                  '备注（选填）',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: remarkController,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: '添加备注...',
                      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 确认按钮
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [typeConfig.color, typeConfig.color.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(27),
                    boxShadow: [
                      BoxShadow(
                        color: typeConfig.color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        final amount = double.tryParse(amountController.text);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('请输入正确的还款金额')),
                          );
                          return;
                        }

                        // 生成sourceHash用于防重复记账（保留以便后续审计）
                        // ignore: unused_local_variable
                        final sourceHash = sha256.convert(utf8.encode(
                          'liability_repay_${liability.liabilityId}_${DateTime.now().millisecondsSinceEpoch}_$amount'
                        )).toString();

                        // 保存还款记录（内部已包含：插入 local_liability_repays + 更新 repaidAmount）
                        // 注意：不要再调 BillProvider.addBill(... liabilityId: ...)，否则
                        // bill_provider 内部还会再插入一条还款记录并 += 已还，造成重复记账。
                        await context.read<LiabilityProvider>().addRepay(
                          liabilityId: liability.liabilityId,
                          amount: amount,
                          accountId: 'default',
                          remark: remarkController.text.isEmpty ? null : remarkController.text,
                        );

                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('还款成功：¥${amount.toStringAsFixed(2)}'),
                              backgroundColor: DebtColors.success,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(27),
                      child: const Center(
                        child: Text(
                          '确认还款',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
