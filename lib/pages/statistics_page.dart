import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../providers/statistics_provider.dart';
import '../ui_constants.dart';
import '../widgets/time_range_picker.dart';
import 'setting_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String _tabType = 'expense'; // 'expense' 或 'income'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadStatistics();
    });
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
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.error != null) {
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
        },
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
              _buildSummaryItem('收入', formatter.format(provider.income), Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildSummaryItem('支出', formatter.format(provider.expense), Colors.white.withValues(alpha: 0.9)),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildSummaryItem('结余', formatter.format(provider.income - provider.expense), Colors.white),
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
                _buildTimeSelector(provider),
                const Spacer(),
                _buildExpenseIncomeTabSwitch(),
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

  Widget _buildExpenseTabContent(StatisticsProvider provider) {
    final hasCategory = provider.expenseCategoryStats.isNotEmpty;
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
    final hasCategory = provider.incomeCategoryStats.isNotEmpty;
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
    final categoryStats = type == 'income'
        ? provider.incomeCategoryStats
        : provider.expenseCategoryStats;
    if (categoryStats.isEmpty) return const SizedBox.shrink();
    final colors = _getChartColors();
    final title = type == 'income' ? '收入构成' : '支出构成';

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

    final maxAmount = dailyTrend.map((e) => (e['amount'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
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
                      return FlSpot(entry.key.toDouble(), (entry.value['amount'] ?? 0).toDouble());
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
    final categoryStats = type == 'income'
        ? provider.incomeCategoryStats
        : provider.expenseCategoryStats;
    if (categoryStats.isEmpty) return const SizedBox.shrink();
    final formatter = NumberFormat.currency(symbol: '¥', decimalDigits: 2);
    final colors = _getChartColors();
    final title = type == 'income' ? '收入排行' : '消费排行';

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
            final amount = (item['amount'] ?? 0).toDouble();
            final percentage = (item['percentage'] ?? 0).toDouble();

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
