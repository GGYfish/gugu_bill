import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import '../database/database.dart';
import '../utils/money.dart';

/// 统计Provider - 使用本地数据库数据
class StatisticsProvider extends ChangeNotifier {
  final AppDatabase _db;

  Map<String, dynamic> _data = {};
  String _period = 'month';
  bool _isLoading = false;
  String? _error;

  // 自定义时间范围（用于"收支详情"上的时间选择器）
  // 切换 period 时会重置成"当前周期的默认值"
  // 用户通过选择器选了新时间后会覆盖这两个值
  DateTime _rangeStart = DateTime.now();
  DateTime _rangeEnd = DateTime.now();

  Map<String, dynamic> get data => _data;
  String get period => _period;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get rangeStart => _rangeStart;
  DateTime get rangeEnd => _rangeEnd;

  Decimal get income => asDecimal(_data['income']);
  Decimal get expense => asDecimal(_data['expense']);
  List get categoryStats => _data['categoryStats'] ?? [];
  List get dailyTrend => _data['dailyTrend'] ?? [];
  // 按类型拆分的分类/趋势（收入 / 支出 分开统计）
  // 大类维度（按父分类聚合）
  List get expenseParentCategoryStats => _data['expenseParentCategoryStats'] ?? [];
  List get incomeParentCategoryStats => _data['incomeParentCategoryStats'] ?? [];
  // 小类维度（按账单实际存放的明细分类聚合）
  List get expenseSubCategoryStats => _data['expenseSubCategoryStats'] ?? [];
  List get incomeSubCategoryStats => _data['incomeSubCategoryStats'] ?? [];
  // 兼容旧字段：默认返回大类口径
  List get expenseCategoryStats => expenseParentCategoryStats;
  List get incomeCategoryStats => incomeParentCategoryStats;
  List get expenseDailyTrend => _data['expenseDailyTrend'] ?? [];
  List get incomeDailyTrend => _data['incomeDailyTrend'] ?? [];
  String get aiAnalysis => _data['aiAnalysis'] ?? '';
  /// 收支总览：全部累计 / 本月 / 上月 / 本年（不受维度页 period 影响）
  Map<String, dynamic> get overview => _data['overview'] ?? {};

  StatisticsProvider(this._db) {
    _resetRangeToDefault();
    loadStatistics();
    // 监听账单变化
    _db.watchAllBills().listen((_) {
      loadStatistics();
    });
  }

  /// 把时间范围重置成"当前周期的默认值"（今日/本周/本月/今年）
  void _resetRangeToDefault() {
    final now = DateTime.now();
    switch (_period) {
      case 'day':
        _rangeStart = DateTime(now.year, now.month, now.day);
        _rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'week':
        final weekday = now.weekday; // 1..7 (Mon..Sun)
        _rangeStart = DateTime(now.year, now.month, now.day - weekday + 1);
        _rangeEnd = DateTime(now.year, now.month, now.day + (7 - weekday), 23, 59, 59);
        break;
      case 'month':
        _rangeStart = DateTime(now.year, now.month, 1);
        _rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'year':
        _rangeStart = DateTime(now.year, 1, 1);
        _rangeEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      default:
        _rangeStart = DateTime(now.year, now.month, 1);
        _rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    }
  }

  /// 计算时间范围（直接返回自定义值）
  (DateTime start, DateTime end) _getDateRange() => (_rangeStart, _rangeEnd);

  Future<void> loadStatistics({String? period}) async {
    if (period != null && period != _period) {
      _period = period;
      _resetRangeToDefault(); // 切 tab 时回到默认范围
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final (start, end) = _getDateRange();

      // 从数据库获取账单
      final bills = await _db.getAllBills();

      // 过滤时间范围内的账单（已确认的）
      final filteredBills = bills.where((b) =>
        b.billTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
        b.billTime.isBefore(end.add(const Duration(seconds: 1))) &&
        b.confirmStatus == 1
      ).toList();

      // 计算收入和支出
      Decimal totalIncome = Decimal.zero;
      Decimal totalExpense = Decimal.zero;
      final expenseParentMap = <String, Map<String, dynamic>>{};
      final incomeParentMap = <String, Map<String, dynamic>>{};
      final expenseSubMap = <String, Map<String, dynamic>>{};
      final incomeSubMap = <String, Map<String, dynamic>>{};
      Map<String, Decimal> expenseDailyMap = {};
      Map<String, Decimal> incomeDailyMap = {};

      String dateKey(DateTime t) =>
          '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

      // 分类映射：小分类 -> 大分类（账单里存的是明细分类 id，大类需要按 parentId 上卷）
      final allCategories = await _db.getAllCategories();
      final catById = <String, LocalCategoriesData>{
        for (final c in allCategories) c.categoryId: c,
      };

      void addTo(Map<String, Map<String, dynamic>> target, String key,
          String name, Decimal amt) {
        final hit = target[key];
        if (hit != null) {
          hit['amount'] = (hit['amount'] as Decimal) + amt;
          hit['count'] = (hit['count'] as int) + 1;
        } else {
          target[key] = {
            'categoryId': key,
            'categoryName': name,
            'amount': amt,
            'count': 1,
          };
        }
      }

      for (final bill in filteredBills) {
        final subId = bill.categoryId ?? 'other';
        final subName = bill.categoryName ?? '其他';
        // 上卷到大类：有父分类则用父分类 id/name，否则自身即大类
        // 查不到映射（老数据/已删除分类）时，大类回退为明细本身
        final cat = catById[subId];
        final String parentId;
        final String parentName;
        if (cat?.parentId != null) {
          final parent = catById[cat!.parentId];
          parentId = parent?.categoryId ?? cat.parentId!;
          parentName = parent?.name ?? subName;
        } else {
          parentId = cat?.categoryId ?? subId;
          parentName = cat?.name ?? subName;
        }
        final dateStr = dateKey(bill.billTime);

        if (bill.type == 'income') {
          final amt = decimalOf(bill.amount);
          totalIncome += amt;
          addTo(incomeSubMap, subId, subName, amt);
          addTo(incomeParentMap, parentId, parentName, amt);

          // 收入每日趋势
          incomeDailyMap[dateStr] = (incomeDailyMap[dateStr] ?? Decimal.zero) + amt;
        } else if (bill.type == 'expense') {
          final amt = decimalOf(bill.amount);
          totalExpense += amt;
          addTo(expenseSubMap, subId, subName, amt);
          addTo(expenseParentMap, parentId, parentName, amt);

          // 支出每日趋势
          expenseDailyMap[dateStr] = (expenseDailyMap[dateStr] ?? Decimal.zero) + amt;
        }
      }

      List<Map<String, dynamic>> sortStats(Map<String, Map<String, dynamic>> m) {
        final list = m.values.toList()
          ..sort((a, b) => (b['amount'] as Decimal).compareTo(a['amount'] as Decimal));
        return list;
      }

      void fillPercentage(List<Map<String, dynamic>> list, Decimal total) {
        for (var cat in list) {
          cat['percentage'] = total > Decimal.zero
              ? round2(((cat['amount'] as Decimal) / total)
                      .toDecimal(scaleOnInfinitePrecision: 4))
              : Decimal.zero;
        }
      }

      // 大类 + 小类各一份排序与占比
      final expenseParentStats = sortStats(expenseParentMap);
      final expenseSubStats = sortStats(expenseSubMap);
      final incomeParentStats = sortStats(incomeParentMap);
      final incomeSubStats = sortStats(incomeSubMap);
      fillPercentage(expenseParentStats, totalExpense);
      fillPercentage(expenseSubStats, totalExpense);
      fillPercentage(incomeParentStats, totalIncome);
      fillPercentage(incomeSubStats, totalIncome);

      // 转换为趋势列表
      final expenseDailyTrend = expenseDailyMap.entries.map((e) => {
        'date': e.key,
        'amount': e.value,
      }).toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
      final incomeDailyTrend = incomeDailyMap.entries.map((e) => {
        'date': e.key,
        'amount': e.value,
      }).toList()
        ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

      // 生成AI分析文案
      String aiAnalysis = _generateAIAnalysis(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        categoryStats: expenseParentStats,
        period: _period,
        billCount: filteredBills.length,
      );

      _data = {
        'income': totalIncome,
        'expense': totalExpense,
        // 总览：全部累计 / 本月 / 上月 / 本年（维度页 period 不影响总览）
        'overview': _buildOverview(bills, catById),
        // 兼容旧字段（默认大类支出口径，保留以防其他模块使用）
        'categoryStats': expenseParentStats,
        'dailyTrend': expenseDailyTrend,
        // 大类维度
        'expenseParentCategoryStats': expenseParentStats,
        'incomeParentCategoryStats': incomeParentStats,
        // 小类维度
        'expenseSubCategoryStats': expenseSubStats,
        'incomeSubCategoryStats': incomeSubStats,
        // 兼容旧字段
        'expenseCategoryStats': expenseParentStats,
        'incomeCategoryStats': incomeParentStats,
        'expenseDailyTrend': expenseDailyTrend,
        'incomeDailyTrend': incomeDailyTrend,
        'aiAnalysis': aiAnalysis,
      };
    } catch (e) {
      _error = e.toString();
      debugPrint('统计加载失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 切换日/周/月/年 tab
  void setPeriod(String period) {
    loadStatistics(period: period);
  }

  /// 用户在"收支详情"上方的时间选择器里挑了一个新范围
  void setCustomRange(DateTime start, DateTime end) {
    _rangeStart = start;
    _rangeEnd = end;
    loadStatistics();
  }

  /// 总览聚合：全部累计 / 本月 / 上月 / 本年
  /// 只统计已确认账单；转账不计入收支（只累加 income / expense 类型）。
  Map<String, dynamic> _buildOverview(
    List<LocalBillsData> bills,
    Map<String, LocalCategoriesData> catById,
  ) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonthStart = DateTime(now.year, now.month + 1, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);
    final lastMonthEnd = monthStart;
    final yearStart = DateTime(now.year, 1, 1);
    final nextYearStart = DateTime(now.year + 1, 1, 1);
    final lastMonthDays = DateTime(now.year, now.month, 0).day;
    final yearDays = now.difference(yearStart).inDays + 1;

    bool inRange(DateTime t, DateTime s, DateTime e) =>
        !t.isBefore(s) && t.isBefore(e);

    String parentNameOf(String? subId, String? subName) {
      final cat = subId == null ? null : catById[subId];
      if (cat?.parentId != null) {
        return catById[cat!.parentId]?.name ?? subName ?? '其他';
      }
      return cat?.name ?? subName ?? '其他';
    }

    String parentIdOf(String? subId) {
      final cat = subId == null ? null : catById[subId];
      if (cat?.parentId != null) {
        return catById[cat!.parentId]?.categoryId ?? cat.parentId!;
      }
      return cat?.categoryId ?? subId ?? 'other';
    }

    Map<String, dynamic> bucket(List<LocalBillsData> list, {int? days}) {
      Decimal income = Decimal.zero;
      Decimal expense = Decimal.zero;
      int count = 0;
      final parentMap = <String, Map<String, dynamic>>{};
      for (final b in list) {
        if (b.confirmStatus != 1) continue;
        final amt = decimalOf(b.amount);
        if (b.type == 'income') {
          income += amt;
          count++;
        } else if (b.type == 'expense') {
          expense += amt;
          count++;
          final pid = parentIdOf(b.categoryId);
          final pname = parentNameOf(b.categoryId, b.categoryName);
          final hit = parentMap[pid];
          if (hit != null) {
            hit['amount'] = (hit['amount'] as Decimal) + amt;
          } else {
            parentMap[pid] = {
              'categoryId': pid,
              'categoryName': pname,
              'amount': amt,
            };
          }
        }
      }
      final tops = parentMap.values.toList()
        ..sort((a, b) =>
            (b['amount'] as Decimal).compareTo(a['amount'] as Decimal));
      final top3 = tops.take(3).toList();
      for (final t in top3) {
        t['percentage'] = expense > Decimal.zero
            ? round2(((t['amount'] as Decimal) / expense)
                    .toDecimal(scaleOnInfinitePrecision: 4))
            : Decimal.zero;
      }
      return {
        'income': income,
        'expense': expense,
        'balance': income - expense,
        'count': count,
        'topExpense': top3,
        if (days != null && days > 0)
          'dailyAvg': expense > Decimal.zero
              ? round2((expense / Decimal.fromInt(days))
                  .toDecimal(scaleOnInfinitePrecision: 4))
              : Decimal.zero,
      };
    }

    final confirmed =
        bills.where((b) => b.confirmStatus == 1).toList();
    final monthBills = confirmed
        .where((b) => inRange(b.billTime, monthStart, nextMonthStart))
        .toList();
    final lastMonthBills = confirmed
        .where((b) => inRange(b.billTime, lastMonthStart, lastMonthEnd))
        .toList();
    final yearBills = confirmed
        .where((b) => inRange(b.billTime, yearStart, nextYearStart))
        .toList();

    String monthLabel(DateTime d) => '${d.month}月';
    return {
      'all': bucket(confirmed),
      'month': {
        ...bucket(monthBills, days: now.day),
        'label': '${now.year}年${now.month}月',
      },
      'lastMonth': {
        ...bucket(lastMonthBills, days: lastMonthDays),
        'label':
            '${lastMonthStart.year}年${lastMonthStart.month}月',
      },
      'year': {
        ...bucket(yearBills, days: yearDays),
        'label': '${now.year}年',
      },
      'monthShort': monthLabel(now),
      'lastMonthShort': monthLabel(lastMonthStart),
    };
  }

  /// 生成AI分析文案
  String _generateAIAnalysis({
    required Decimal totalIncome,
    required Decimal totalExpense,
    required List categoryStats,
    required String period,
    required int billCount,
  }) {
    final balance = totalIncome - totalExpense;
    final periodName = _getRangeLabel();

    StringBuffer sb = StringBuffer();

    // 收支概览
    sb.write('本期（$periodName）共记录 $billCount 笔账单。');
    if (totalIncome > Decimal.zero) {
      sb.write(' 收入 ${formatMoney(totalIncome)} 元');
    }
    if (totalExpense > Decimal.zero) {
      sb.write('，支出 ${formatMoney(totalExpense)} 元');
    }
    if (balance != Decimal.zero) {
      sb.write('，${balance >= Decimal.zero ? '结余' : '超支'} ${formatMoney(balance.abs())} 元。');
    } else {
      sb.write('。');
    }

    // 支出分析
    if (categoryStats.isNotEmpty) {
      final topCategory = categoryStats.first;
      final topPercent = asDecimal(topCategory['percentage']) * Decimal.fromInt(100);

      sb.write(' 支出主要集中在${topCategory['categoryName']}，占比 ${topPercent.toStringAsFixed(1)}%。');

      if (categoryStats.length >= 2) {
        final secondCategory = categoryStats[1];
        final secondPercent = asDecimal(secondCategory['percentage']) * Decimal.fromInt(100);
        sb.write(' 其次是${secondCategory['categoryName']}（${secondPercent.toStringAsFixed(1)}%）。');
      }
    }

    // 建议
    if (balance < Decimal.zero) {
      sb.write(' 建议适当控制开支，避免超支。');
    } else if (balance > Decimal.zero &&
        totalIncome > Decimal.zero &&
        (balance / totalIncome).toDecimal(scaleOnInfinitePrecision: 4) > decimalOf(0.3)) {
      sb.write(' 继续保持良好的储蓄习惯！');
    }

    return sb.toString();
  }

  /// 根据当前 period + 自定义范围生成一个可读的标签
  String _getRangeLabel() {
    switch (_period) {
      case 'day':
        return '${_rangeStart.year}年${_rangeStart.month}月${_rangeStart.day}日';
      case 'week':
        return '${_rangeStart.month}月${_rangeStart.day}日-${_rangeEnd.month}月${_rangeEnd.day}日';
      case 'month':
        return '${_rangeStart.year}年${_rangeStart.month}月';
      case 'year':
        return '${_rangeStart.year}年';
      default:
        return '本期';
    }
  }
}
