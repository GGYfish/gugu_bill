import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/statistics_provider.dart';
import '../ui_constants.dart';
import '../utils/money.dart';
import '../widgets/time_range_picker.dart';
import 'setting_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  String _tabType = 'expense'; // 'expense' 或 'income'
  String _catLevel = 'parent'; // 'parent' 大类 或 'sub' 小类
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadStatistics();
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
        title: const Text('数据统计', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: const SizedBox(width: 48), // 占位，与右侧 actions 等宽保持标题居中
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
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.overview.isEmpty) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null && provider.overview.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('加载失败：${provider.error}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadStatistics(),
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // 顶部双 Tab：与负债页同一样式，可左右滑动切换
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
                    Tab(text: '收支总览'),
                    Tab(text: '维度'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(provider),
                    _buildDimensionTab(provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 第一页：收支总览（全部 / 本月 / 上月 / 本年）
  Widget _buildOverviewTab(StatisticsProvider provider) {
    final overview = provider.overview;
    if (overview.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Center(
            child: Text('暂无账单数据', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          ),
        ],
      );
    }
    Map<String, dynamic> bucketOf(String key) {
      final v = overview[key];
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return <String, dynamic>{};
    }

    final all = bucketOf('all');
    final month = bucketOf('month');
    final lastMonth = bucketOf('lastMonth');
    final year = bucketOf('year');

    return RefreshIndicator(
      onRefresh: () => provider.loadStatistics(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewHero(all),
            _buildMonthCompareCards(month, lastMonth),
            _buildOverviewPeriodCard(
              title: (month['label'] as String?) ?? '本月',
              subtitle: '本月收支',
              data: month,
              highlight: true,
            ),
            _buildOverviewPeriodCard(
              title: (lastMonth['label'] as String?) ?? '上月',
              subtitle: '上月回顾',
              data: lastMonth,
            ),
            _buildOverviewPeriodCard(
              title: (year['label'] as String?) ?? '本年',
              subtitle: '年度累计',
              data: year,
            ),
            _buildOverviewTopCard(month, lastMonth),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// 第二页：维度（原统计页全部内容整体搬入）
  Widget _buildDimensionTab(StatisticsProvider provider) {
          return RefreshIndicator(
            onRefresh: () => provider.loadStatistics(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(provider),
                  _buildSummaryCard(provider),
                  _buildExpenseIncomeTabs(provider),
                  _buildAIAnalysis(provider),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
  }

  /// 总览顶部：累计结余大卡
  Widget _buildOverviewHero(Map<String, dynamic> all) {
    final income = asDecimal(all['income']);
    final expense = asDecimal(all['expense']);
    final balance = asDecimal(all['balance']);
    final count = (all['count'] as int?) ?? 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding, 4, AppDimensions.pagePadding, 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '累计结余 · 全部账单',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  const Spacer(),
                  Text(
                    '$count 笔',
                    style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '¥${formatMoney(balance)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildHeroSmall('累计收入', income, AppColors.income)),
                  Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.3)),
                  Expanded(child: _buildHeroSmall('累计支出', expense, Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSmall(String label, dynamic amount, Color amountColor) {
    final isWhite = amountColor == Colors.white;
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 4),
        Text(
          '¥${formatMoney(asDecimal(amount))}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isWhite ? Colors.white : Colors.white,
          ),
        ),
      ],
    );
  }

  /// 本月 vs 上月支出对比
  Widget _buildMonthCompareCards(Map<String, dynamic> month, Map<String, dynamic> lastMonth) {
    final mExpense = asDecimal(month['expense']);
    final lExpense = asDecimal(lastMonth['expense']);
    final mIncome = asDecimal(month['income']);
    final lIncome = asDecimal(lastMonth['income']);
    double ratio = 0;
    if (lExpense > asDecimal(0)) {
      ratio = ((mExpense - lExpense) / lExpense).toDouble();
    } else if (mExpense > asDecimal(0)) {
      ratio = 1;
    }
    final up = ratio > 0.001;
    final flat = ratio.abs() <= 0.001;
    final ratioText = flat ? '持平' : '${up ? '+' : ''}${(ratio * 100).toStringAsFixed(1)}%';
    final monthShort = month['label'] as String? ?? '';
    final lastShort = lastMonth['label'] as String? ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, 0),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('月度环比', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (flat
                          ? AppColors.textTertiary
                          : up
                              ? AppColors.expense
                              : AppColors.income)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      flat
                          ? Icons.remove
                          : up
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                      size: 12,
                      color: flat
                          ? AppColors.textTertiary
                          : up
                              ? AppColors.expense
                              : AppColors.income,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '支出$ratioText',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: flat
                            ? AppColors.textTertiary
                            : up
                                ? AppColors.expense
                                : AppColors.income,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCompareCol(
                  label: monthShort.isEmpty ? '本月支出' : '$monthShort支出',
                  expense: mExpense,
                  income: mIncome,
                  isPrimary: true,
                ),
              ),
              Container(width: 1, height: 44, color: AppColors.divider),
              Expanded(
                child: _buildCompareCol(
                  label: lastShort.isEmpty ? '上月支出' : '$lastShort支出',
                  expense: lExpense,
                  income: lIncome,
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompareCol({
    required String label,
    required dynamic expense,
    required dynamic income,
    required bool isPrimary,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(
          '¥${formatMoney(asDecimal(expense))}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isPrimary ? AppColors.expense : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '收入 ¥${formatMoney(asDecimal(income))}',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// 本月 / 上月 / 本年三张周期卡
  Widget _buildOverviewPeriodCard({
    required String title,
    required String subtitle,
    required Map<String, dynamic> data,
    bool highlight = false,
  }) {
    final income = asDecimal(data['income']);
    final expense = asDecimal(data['expense']);
    final balance = asDecimal(data['balance']);
    final count = (data['count'] as int?) ?? 0;
    final dailyAvg = data['dailyAvg'];
    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, 0),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: highlight
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(width: 8),
              Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
              const Spacer(),
              Text('$count 笔', style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPeriodMini('收入', income, AppColors.income),
              ),
              Container(width: 1, height: 36, color: AppColors.divider),
              Expanded(
                child: _buildPeriodMini('支出', expense, AppColors.expense),
              ),
              Container(width: 1, height: 36, color: AppColors.divider),
              Expanded(
                child: _buildPeriodMini('结余', balance, AppColors.textPrimary),
              ),
            ],
          ),
          if (dailyAvg != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.speed_outlined, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    '日均支出 ¥${formatMoney(asDecimal(dailyAvg))}',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeriodMini(String label, dynamic amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        const SizedBox(height: 4),
        Text(
          '¥${formatMoney(asDecimal(amount))}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 本月支出 TOP3（大类口径）
  Widget _buildOverviewTopCard(Map<String, dynamic> month, Map<String, dynamic> lastMonth) {
    final tops = (month['topExpense'] as List?) ?? [];
    if (tops.isEmpty) return const SizedBox.shrink();
    final colors = _getChartColors();
    final monthLabel = (month['label'] as String?) ?? '本月';
    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 12, AppDimensions.pagePadding, 0),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$monthLabel支出 TOP3', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...tops.asMap().entries.map((entry) {
            final index = entry.key;
            final item = Map<String, dynamic>.from(entry.value as Map);
            final pct = asDouble(item['percentage']);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['categoryName'] ?? '',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        '¥${formatMoney(asDecimal(item['amount']))}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 44,
                        child: Text(
                          '${(pct * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct.clamp(0.0, 1.0),
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(colors[index % colors.length]),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(StatisticsProvider provider) {
    final periods = [
      {'key': 'day', 'label': '日'},
      {'key': 'week', 'label': '周'},
      {'key': 'month', 'label': '月'},
      {'key': 'year', 'label': '年'},
    ];

    return Container(
      margin: const EdgeInsets.all(AppDimensions.pagePadding),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: periods.map((p) {
          final isSelected = provider.period == p['key'];
          return Expanded(
            child: GestureDetector(
              onTap: () => provider.setPeriod(p['key'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  p['label'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryCard(StatisticsProvider provider) {
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('收入', formatter.format(provider.income.toDouble()), Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildSummaryItem('支出', formatter.format(provider.expense.toDouble()), Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildSummaryItem('结余', formatter.format((provider.income - provider.expense).toDouble()), Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  /// 收支详情 tab 容器：支出 / 收入 两个子 tab
  Widget _buildExpenseIncomeTabs(StatisticsProvider provider) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
        0,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 + 时间选择器 + tab 切换
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: _buildTimeSelector(provider),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildExpenseIncomeTabSwitch(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 12, 0),
            child: Row(
              children: [
                Text(
                  '分类维度',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const Spacer(),
                _buildCategoryLevelSwitch(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // tab 内容
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _tabType == 'expense'
                ? _buildExpenseTabContent(provider)
                : _buildIncomeTabContent(provider),
          ),
        ],
      ),
    );
  }

  /// "收支详情" 标题位置的时间选择 chip：根据当前 period 弹出对应的自定义选择器
  Widget _buildTimeSelector(StatisticsProvider provider) {
    final label = _formatRangeLabel(
      provider.period,
      provider.rangeStart,
      provider.rangeEnd,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final result = await TimeRangePicker.show(
            context: context,
            period: provider.period,
            currentStart: provider.rangeStart,
          );
          if (result != null) {
            provider.setCustomRange(result.$1, result.$2);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, size: 18, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  /// 把当前时间范围格式化成 chip 上展示的文本
  String _formatRangeLabel(String period, DateTime start, DateTime end) {
    switch (period) {
      case 'day':
        return DateFormat('yyyy年M月d日').format(start);
      case 'week':
        return '${DateFormat('M月d日').format(start)} - ${DateFormat('M月d日').format(end)}';
      case 'month':
        return DateFormat('yyyy年M月').format(start);
      case 'year':
        return DateFormat('yyyy年').format(start);
      default:
        return '';
    }
  }

  /// 支出 / 收入 二选一的小型切换器（放在卡片标题右侧）
  /// 两个 tab 始终可点；无数据时由 tab content 内部展示空态
  Widget _buildExpenseIncomeTabSwitch() {
    return Container(
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabSwitchItem(
            label: '支出',
            isActive: _tabType == 'expense',
            activeColor: AppColors.expense,
            onTap: () => setState(() => _tabType = 'expense'),
          ),
          _buildTabSwitchItem(
            label: '收入',
            isActive: _tabType == 'income',
            activeColor: AppColors.income,
            onTap: () => setState(() => _tabType = 'income'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitchItem({
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 大类 / 小类 二选一的维度切换器
  Widget _buildCategoryLevelSwitch() {
    return Container(
      height: 30,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabSwitchItem(
            label: '大类',
            isActive: _catLevel == 'parent',
            activeColor: AppColors.primary,
            onTap: () => setState(() => _catLevel = 'parent'),
          ),
          _buildTabSwitchItem(
            label: '小类',
            isActive: _catLevel == 'sub',
            activeColor: AppColors.primary,
            onTap: () => setState(() => _catLevel = 'sub'),
          ),
        ],
      ),
    );
  }

  /// 按当前维度取分类统计（饼图/排行共用）
  List _categoryStatsOf(StatisticsProvider provider, String type) {
    final isIncome = type == 'income';
    final isSub = _catLevel == 'sub';
    if (isIncome) {
      return isSub
          ? provider.incomeSubCategoryStats
          : provider.incomeParentCategoryStats;
    }
    return isSub
        ? provider.expenseSubCategoryStats
        : provider.expenseParentCategoryStats;
  }

  Widget _buildExpenseTabContent(StatisticsProvider provider) {
    final hasCategory = _categoryStatsOf(provider, 'expense').isNotEmpty;
    final hasTrend = provider.expenseDailyTrend.isNotEmpty;
    if (!hasCategory && !hasTrend) {
      return _buildEmptyTabContent('本期暂无支出数据');
    }
    return Column(
      children: [
        if (hasCategory) _buildPieChart(provider, type: 'expense'),
        if (hasTrend) _buildTrendChart(provider, type: 'expense'),
        if (hasCategory) _buildCategoryRanking(provider, type: 'expense'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildIncomeTabContent(StatisticsProvider provider) {
    final hasCategory = _categoryStatsOf(provider, 'income').isNotEmpty;
    final hasTrend = provider.incomeDailyTrend.isNotEmpty;
    if (!hasCategory && !hasTrend) {
      return _buildEmptyTabContent('本期暂无收入数据');
    }
    return Column(
      children: [
        if (hasCategory) _buildPieChart(provider, type: 'income'),
        if (hasTrend) _buildTrendChart(provider, type: 'income'),
        if (hasCategory) _buildCategoryRanking(provider, type: 'income'),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildEmptyTabContent(String message) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        0,
        AppDimensions.pagePadding,
        AppDimensions.pagePadding,
      ),
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: AppColors.textTertiary),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 13, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(StatisticsProvider provider, {required String type}) {
    final categoryStats = _categoryStatsOf(provider, type);
    if (categoryStats.isEmpty) return const SizedBox.shrink();
    final colors = _getChartColors();
    final levelSuffix = _catLevel == 'sub' ? '小类' : '大类';
    final title = type == 'income' ? '收入构成·$levelSuffix' : '支出构成·$levelSuffix';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryStats.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value as Map<String, dynamic>;
                        final percentage = (item['percentage'] ?? 0).toDouble();
                        return PieChartSectionData(
                          color: colors[index % colors.length],
                          value: percentage * 100,
                          title: percentage > 0.05 ? '${(percentage * 100).toStringAsFixed(0)}%' : '',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categoryStats.take(5).map((item) {
                    final index = categoryStats.indexOf(item);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[index % colors.length],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              item['categoryName'] ?? '',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChart(StatisticsProvider provider, {required String type}) {
    final dailyTrend = type == 'income'
        ? provider.incomeDailyTrend
        : provider.expenseDailyTrend;
    final lineColor = type == 'income' ? AppColors.income : AppColors.primary;
    final title = type == 'income' ? '收入趋势' : '支出趋势';

    if (dailyTrend.isEmpty) return const SizedBox.shrink();

    final maxAmount = dailyTrend.map((e) => asDouble(e['amount'])).reduce((a, b) => a > b ? a : b);
    final interval = (maxAmount / 4).clamp(1.0, double.infinity);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(color: AppColors.divider, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: (dailyTrend.length / 5).ceilToDouble().clamp(1, double.infinity),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dailyTrend.length) return const SizedBox.shrink();
                        final date = dailyTrend[idx]['date'] ?? '';
                        final parts = date.split('-');
                        if (parts.length >= 2) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${parts[1]}/${parts[2]}',
                              style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '¥${value.toInt()}',
                          style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                lineBarsData: [
                  LineChartBarData(
                    spots: dailyTrend.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), asDouble(entry.value['amount']));
                    }).toList(),
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: lineColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: dailyTrend.length <= 15,
                      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                        radius: 3,
                        color: lineColor,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          lineColor.withValues(alpha: 0.3),
                          lineColor.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRanking(StatisticsProvider provider, {required String type}) {
    final categoryStats = _categoryStatsOf(provider, type);
    if (categoryStats.isEmpty) return const SizedBox.shrink();
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final colors = _getChartColors();
    final levelSuffix = _catLevel == 'sub' ? '小类' : '大类';
    final title = type == 'income' ? '收入排行·$levelSuffix' : '消费排行·$levelSuffix';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ...categoryStats.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value as Map<String, dynamic>;
            final amount = asDouble(item['amount']);
            final percentage = asDouble(item['percentage']);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index < 3 ? colors[index] : AppColors.divider,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index < 3 ? Colors.white : AppColors.textTertiary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['categoryName'] ?? '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        formatter.format(amount),
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(colors[index % colors.length]),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAIAnalysis(StatisticsProvider provider) {
    if (provider.aiAnalysis.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimensions.pagePadding, 0, AppDimensions.pagePadding, 0),
      padding: const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'AI 分析',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.aiAnalysis,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getChartColors() {
    return [
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFE66D),
      const Color(0xFF95E1D3),
      const Color(0xFFF38181),
      const Color(0xFFAA96DA),
      const Color(0xFF6C5CE7),
      const Color(0xFF74B9FF),
    ];
  }
}
