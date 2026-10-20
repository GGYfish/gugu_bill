import 'package:flutter/foundation.dart';
import '../database/database.dart';

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

  double get income => (_data['income'] ?? 0).toDouble();
  double get expense => (_data['expense'] ?? 0).toDouble();
  List get categoryStats => _data['categoryStats'] ?? [];
  List get dailyTrend => _data['dailyTrend'] ?? [];
  // 按类型拆分的分类/趋势（收入 / 支出 分开统计）
  List get expenseCategoryStats => _data['expenseCategoryStats'] ?? [];
  List get expenseDailyTrend => _data['expenseDailyTrend'] ?? [];
  List get incomeCategoryStats => _data['incomeCategoryStats'] ?? [];
  List get incomeDailyTrend => _data['incomeDailyTrend'] ?? [];
  String get aiAnalysis => _data['aiAnalysis'] ?? '';

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
      double totalIncome = 0;
      double totalExpense = 0;
      Map<String, Map<String, dynamic>> expenseCategoryMap = {};
      Map<String, Map<String, dynamic>> incomeCategoryMap = {};
      Map<String, double> expenseDailyMap = {};
      Map<String, double> incomeDailyMap = {};

      String _dateKey(DateTime t) =>
          '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';

      for (final bill in filteredBills) {
        final catId = bill.categoryId ?? 'other';
        final catName = bill.categoryName ?? '其他';
        final dateKey = _dateKey(bill.billTime);

        if (bill.type == 'income') {
          totalIncome += bill.amount;

          // 收入按分类统计
          if (incomeCategoryMap.containsKey(catId)) {
            incomeCategoryMap[catId]!['amount'] =
                (incomeCategoryMap[catId]!['amount'] as double) + bill.amount;
            incomeCategoryMap[catId]!['count'] =
                (incomeCategoryMap[catId]!['count'] as int) + 1;
          } else {
            incomeCategoryMap[catId] = {
              'categoryId': catId,
              'categoryName': catName,
              'amount': bill.amount,
              'count': 1,
            };
          }

          // 收入每日趋势
          incomeDailyMap[dateKey] = (incomeDailyMap[dateKey] ?? 0) + bill.amount;
        } else if (bill.type == 'expense') {
          totalExpense += bill.amount;

          // 支出按分类统计
          if (expenseCategoryMap.containsKey(catId)) {
            expenseCategoryMap[catId]!['amount'] =
                (expenseCategoryMap[catId]!['amount'] as double) + bill.amount;
            expenseCategoryMap[catId]!['count'] =
                (expenseCategoryMap[catId]!['count'] as int) + 1;
          } else {
            expenseCategoryMap[catId] = {
              'categoryId': catId,
              'categoryName': catName,
              'amount': bill.amount,
              'count': 1,
            };
          }

          // 支出每日趋势
          expenseDailyMap[dateKey] = (expenseDailyMap[dateKey] ?? 0) + bill.amount;
        }
      }

      // 转换为分类统计列表并排序
      final expenseCategoryStats = expenseCategoryMap.values.toList()
        ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));
      final incomeCategoryStats = incomeCategoryMap.values.toList()
        ..sort((a, b) => (b['amount'] as double).compareTo(a['amount'] as double));

      // 计算百分比
      for (var cat in expenseCategoryStats) {
        cat['percentage'] = totalExpense > 0 ? (cat['amount'] as double) / totalExpense : 0.0;
      }
      for (var cat in incomeCategoryStats) {
        cat['percentage'] = totalIncome > 0 ? (cat['amount'] as double) / totalIncome : 0.0;
      }

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
        categoryStats: expenseCategoryStats,
        period: _period,
        billCount: filteredBills.length,
      );

      _data = {
        'income': totalIncome,
        'expense': totalExpense,
        // 兼容旧字段（默认支出，保留以防其他模块使用）
        'categoryStats': expenseCategoryStats,
        'dailyTrend': expenseDailyTrend,
        // 按类型拆分的字段
        'expenseCategoryStats': expenseCategoryStats,
        'expenseDailyTrend': expenseDailyTrend,
        'incomeCategoryStats': incomeCategoryStats,
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

  /// 生成AI分析文案
  String _generateAIAnalysis({
    required double totalIncome,
    required double totalExpense,
    required List categoryStats,
    required String period,
    required int billCount,
  }) {
    final balance = totalIncome - totalExpense;
    final periodName = _getRangeLabel();

    StringBuffer sb = StringBuffer();

    // 收支概览
    sb.write('本期（$periodName）共记录 $billCount 笔账单。');
    if (totalIncome > 0) {
      sb.write(' 收入 ${totalIncome.toStringAsFixed(2)} 元');
    }
    if (totalExpense > 0) {
      sb.write('，支出 ${totalExpense.toStringAsFixed(2)} 元');
    }
    if (balance != 0) {
      sb.write('，${balance >= 0 ? '结余' : '超支'} ${balance.abs().toStringAsFixed(2)} 元。');
    } else {
      sb.write('。');
    }

    // 支出分析
    if (categoryStats.isNotEmpty) {
      final topCategory = categoryStats.first;
      final topPercent = (topCategory['percentage'] as double) * 100;

      sb.write(' 支出主要集中在${topCategory['categoryName']}，占比 ${topPercent.toStringAsFixed(1)}%。');

      if (categoryStats.length >= 2) {
        final secondCategory = categoryStats[1];
        final secondPercent = (secondCategory['percentage'] as double) * 100;
        sb.write(' 其次是${secondCategory['categoryName']}（${secondPercent.toStringAsFixed(1)}%）。');
      }
    }

    // 建议
    if (balance < 0) {
      sb.write(' 建议适当控制开支，避免超支。');
    } else if (balance > 0 && balance / totalIncome > 0.3) {
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
