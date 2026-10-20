import 'package:flutter/material.dart';
import '../ui_constants.dart';

/// 自定义时间范围选择器
///
/// 根据 [period] 弹出不同的底部弹层：
/// - day:   年/月/日 三柱滚轮
/// - week:  年/月/周 三柱同屏（周随年月动态变化）
/// - month: 年/月 两柱滚轮
/// - year:  年 单柱滚轮
///
/// 所有选择器都禁止选未来的日期；切换 tab 时 reset 也会回到当期默认值。
/// 每根滚轮右侧有一个固定显示的"单位"标签（年/月/日/周），替代高亮条。
///
/// 返回 (start, end) 元组；用户取消时返回 null。
class TimeRangePicker {
  TimeRangePicker._();

  /// 打开选择器
  static Future<(DateTime start, DateTime end)?> show({
    required BuildContext context,
    required String period,
    required DateTime currentStart,
  }) async {
    switch (period) {
      case 'day':
        return _showDay(context, currentStart);
      case 'week':
        return _showWeek(context, currentStart);
      case 'month':
        return _showMonth(context, currentStart);
      case 'year':
        return _showYear(context, currentStart);
      default:
        return _showMonth(context, currentStart);
    }
  }

  // ============================================================
  // 日：年/月/日 三柱，禁止选未来
  // ============================================================
  static Future<(DateTime, DateTime)?> _showDay(BuildContext context, DateTime initial) async {
    final now = DateTime.now();
    // 年范围：当前年 - 10 ~ 当前年
    final minYear = now.year - 10;
    final maxYear = now.year;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);

    // 初始值钳制到合法范围
    int selectedYear = initial.year.clamp(minYear, maxYear);
    int selectedMonth = initial.month;
    int selectedDay = initial.day;

    int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

    /// 当前选中年月下可选的最大月/日（钳掉未来）
    int maxMonthFor(int y) => y == maxYear ? now.month : 12;
    int maxDayFor(int y, int m) =>
        (y == maxYear && m == now.month) ? now.day : daysInMonth(y, m);

    // 初始月日钳制
    selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));
    selectedDay = selectedDay.clamp(1, maxDayFor(selectedYear, selectedMonth));

    // 月份可选项（随年份动态变）
    List<int> monthsFor(int y) =>
        List.generate(maxMonthFor(y), (i) => i + 1);

    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final monthOptions = monthsFor(selectedYear);
            final dayOptions = maxDayFor(selectedYear, selectedMonth);
            return _PickerSheet(
              title: '选择日期',
              height: 280,
              child: Row(
                children: [
                  _WheelColumn(
                    itemCount: years.length,
                    initialIndex: years.indexOf(selectedYear).clamp(0, years.length - 1),
                    onChanged: (idx) {
                      selectedYear = years[idx];
                      selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));
                      selectedDay = selectedDay.clamp(1, maxDayFor(selectedYear, selectedMonth));
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => '${years[idx]}',
                    unit: '年',
                  ),
                  _WheelColumn(
                    itemCount: monthOptions.length,
                    initialIndex: (selectedMonth - 1).clamp(0, monthOptions.length - 1),
                    onChanged: (idx) {
                      selectedMonth = monthOptions[idx];
                      selectedDay = selectedDay.clamp(1, maxDayFor(selectedYear, selectedMonth));
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => monthOptions[idx].toString().padLeft(2, '0'),
                    unit: '月',
                  ),
                  _WheelColumn(
                    itemCount: dayOptions,
                    initialIndex: (selectedDay - 1).clamp(0, dayOptions - 1),
                    onChanged: (idx) => selectedDay = idx + 1,
                    itemBuilder: (idx) => (idx + 1).toString().padLeft(2, '0'),
                    unit: '日',
                  ),
                ],
              ),
              onConfirm: () {
                final start = DateTime(selectedYear, selectedMonth, selectedDay);
                final end = DateTime(selectedYear, selectedMonth, selectedDay, 23, 59, 59);
                Navigator.pop(ctx, (start, end));
              },
            );
          },
        );
      },
    );
    return result;
  }

  // ============================================================
  // 周：年/月/周 三柱同屏，周随年月动态变化
  // ============================================================
  static Future<(DateTime, DateTime)?> _showWeek(BuildContext context, DateTime initial) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final minYear = now.year - 10;
    final maxYear = now.year;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);

    // 初始钳制
    int selectedYear = initial.year.clamp(minYear, maxYear);
    int selectedMonth = initial.month;

    int maxMonthFor(int y) => y == maxYear ? now.month : 12;
    selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));

    /// 当前年-月下所有"包含该月任何一天"的周（周一为周首）
    List<DateTime> weekStartsFor(int y, int m) {
      final weeks = _weeksOfMonth(y, m);
      // 如果是当前年-月，过滤掉还没到的周（start > 今天 的不要）
      final available = (y == maxYear && m == now.month)
          ? weeks.where((w) => !w.start.isAfter(today)).toList()
          : weeks;
      return available.map((w) => w.start).toList();
    }

    List<int> monthsFor(int y) =>
        List.generate(maxMonthFor(y), (i) => i + 1);

    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        // week 选中值用 start（周一日期）表示
        DateTime? selectedWeekStart;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final monthOptions = monthsFor(selectedYear);
            final weekStarts = weekStartsFor(selectedYear, selectedMonth);

            // 初始化 selectedWeekStart：找到包含 initial 的那周，否则取最后一可周
            selectedWeekStart ??= _findWeekStartContaining(weekStarts, initial) ?? weekStarts.last;

            // 初始 index：找到当前 selectedWeekStart 在 weekStarts 里的位置
            int weekIndex = weekStarts.indexOf(selectedWeekStart!);
            if (weekIndex < 0) weekIndex = weekStarts.length - 1;

            return _PickerSheet(
              title: '选择周',
              height: 280,
              child: Row(
                children: [
                  _WheelColumn(
                    itemCount: years.length,
                    initialIndex: years.indexOf(selectedYear).clamp(0, years.length - 1),
                    onChanged: (idx) {
                      selectedYear = years[idx];
                      selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));
                      // 月变 → 周重置
                      selectedWeekStart = null;
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => '${years[idx]}',
                    unit: '年',
                  ),
                  _WheelColumn(
                    itemCount: monthOptions.length,
                    initialIndex: (selectedMonth - 1).clamp(0, monthOptions.length - 1),
                    onChanged: (idx) {
                      selectedMonth = monthOptions[idx];
                      // 月变 → 周重置
                      selectedWeekStart = null;
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => monthOptions[idx].toString().padLeft(2, '0'),
                    unit: '月',
                  ),
                  _WheelColumn(
                    itemCount: weekStarts.isEmpty ? 1 : weekStarts.length,
                    initialIndex: weekStarts.isEmpty ? 0 : weekIndex,
                    onChanged: (idx) {
                      if (weekStarts.isEmpty) return;
                      selectedWeekStart = weekStarts[idx];
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) {
                      if (weekStarts.isEmpty) return '无';
                      final monday = weekStarts[idx];
                      final sunday = DateTime(monday.year, monday.month, monday.day + 6);
                      return '${_md(monday)}-${_md(sunday)}';
                    },
                    unit: '周',
                  ),
                ],
              ),
              onConfirm: () {
                if (selectedWeekStart == null || weekStarts.isEmpty) return;
                final start = selectedWeekStart!;
                final end = DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
                Navigator.pop(ctx, (start, end));
              },
            );
          },
        );
      },
    );
    return result;
  }

  // ============================================================
  // 月：年/月 两柱，禁止选未来
  // ============================================================
  static Future<(DateTime, DateTime)?> _showMonth(BuildContext context, DateTime initial) async {
    final now = DateTime.now();
    final minYear = now.year - 10;
    final maxYear = now.year;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);

    int selectedYear = initial.year.clamp(minYear, maxYear);
    int selectedMonth = initial.month;

    int maxMonthFor(int y) => y == maxYear ? now.month : 12;
    selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));

    List<int> monthsFor(int y) =>
        List.generate(maxMonthFor(y), (i) => i + 1);

    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final monthOptions = monthsFor(selectedYear);
            return _PickerSheet(
              title: '选择月份',
              height: 280,
              child: Row(
                children: [
                  _WheelColumn(
                    itemCount: years.length,
                    initialIndex: years.indexOf(selectedYear).clamp(0, years.length - 1),
                    onChanged: (idx) {
                      selectedYear = years[idx];
                      selectedMonth = selectedMonth.clamp(1, maxMonthFor(selectedYear));
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => '${years[idx]}',
                    unit: '年',
                  ),
                  _WheelColumn(
                    itemCount: monthOptions.length,
                    initialIndex: (selectedMonth - 1).clamp(0, monthOptions.length - 1),
                    onChanged: (idx) {
                      selectedMonth = monthOptions[idx];
                      setSheetState(() {});
                    },
                    itemBuilder: (idx) => monthOptions[idx].toString().padLeft(2, '0'),
                    unit: '月',
                  ),
                ],
              ),
              onConfirm: () {
                final start = DateTime(selectedYear, selectedMonth, 1);
                final end = DateTime(selectedYear, selectedMonth + 1, 0, 23, 59, 59);
                Navigator.pop(ctx, (start, end));
              },
            );
          },
        );
      },
    );
    return result;
  }

  // ============================================================
  // 年：单柱，禁止选未来
  // ============================================================
  static Future<(DateTime, DateTime)?> _showYear(BuildContext context, DateTime initial) async {
    final now = DateTime.now();
    final minYear = now.year - 10;
    final maxYear = now.year;
    final years = List.generate(maxYear - minYear + 1, (i) => minYear + i);

    int selectedYear = initial.year.clamp(minYear, maxYear);

    final result = await showModalBottomSheet<(DateTime, DateTime)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return _PickerSheet(
              title: '选择年份',
              height: 280,
              child: _WheelColumn(
                itemCount: years.length,
                initialIndex: years.indexOf(selectedYear).clamp(0, years.length - 1),
                onChanged: (idx) {
                  selectedYear = years[idx];
                  setSheetState(() {});
                },
                itemBuilder: (idx) => '${years[idx]}',
                unit: '年',
              ),
              onConfirm: () {
                final start = DateTime(selectedYear, 1, 1);
                final end = DateTime(selectedYear, 12, 31, 23, 59, 59);
                Navigator.pop(ctx, (start, end));
              },
            );
          },
        );
      },
    );
    return result;
  }
}

// ============================================================
// 内部组件
// ============================================================

/// 通用底部弹层外壳：标题 + 内容 + 取消/确定
class _PickerSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onConfirm;
  final double height;

  const _PickerSheet({
    required this.title,
    required this.child,
    required this.onConfirm,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
            SizedBox(height: height, child: child),
            const SizedBox(height: 12),
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
                      child: Text(
                        '取消',
                        style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
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
                        onPressed: onConfirm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
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
}

/// 单柱滚轮（ListWheelScrollView + 右侧固定的"单位"标签）
class _WheelColumn extends StatefulWidget {
  final int itemCount;
  final int initialIndex;
  final ValueChanged<int> onChanged;
  final String Function(int index) itemBuilder;

  /// 右侧固定的单位标签：年 / 月 / 日 / 周
  final String unit;

  /// 滚轮单行高度
  static const double itemExtent = 40;

  const _WheelColumn({
    required this.itemCount,
    required this.initialIndex,
    required this.onChanged,
    required this.itemBuilder,
    required this.unit,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.initialIndex.clamp(0, widget.itemCount - 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          // 滚轮本身：右侧留出 52px 给单位标签，避免数字和单位重叠
          Padding(
            padding: const EdgeInsets.only(right: 52),
            child: ListWheelScrollView.useDelegate(
              controller: _controller,
              itemExtent: _WheelColumn.itemExtent,
              perspective: 0.003,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: widget.onChanged,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: widget.itemCount,
                builder: (ctx, idx) => Center(
                  child: Text(
                    widget.itemBuilder(idx),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 右侧固定单位标签：垂直居中，主色填充小药丸，替代原来的矩形高亮条
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.unit,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 周相关辅助函数
// ============================================================

class _WeekRange {
  final DateTime start; // 周一 00:00:00
  final DateTime end;   // 周日 23:59:59
  const _WeekRange(this.start, this.end);
}

/// 获取一个月份里所有出现过的周（以周一为周首，周日为周末）
/// 比如 2026-09 的周会从 8-31（周一）开始
List<_WeekRange> _weeksOfMonth(int year, int month) {
  final first = DateTime(year, month, 1);
  final last = DateTime(year, month + 1, 0);
  // 找本月 1 号所在周的周一
  final firstWeekday = first.weekday; // 1..7 (Mon..Sun)
  final firstMonday = first.subtract(Duration(days: firstWeekday - 1));

  final List<_WeekRange> result = [];
  DateTime cursor = firstMonday;
  while (!cursor.isAfter(last)) {
    final end = DateTime(cursor.year, cursor.month, cursor.day + 6, 23, 59, 59);
    result.add(_WeekRange(cursor, end));
    cursor = cursor.add(const Duration(days: 7));
  }
  return result;
}

/// 从周起始列表中找出包含 [date] 的那个周一
DateTime? _findWeekStartContaining(List<DateTime> weekStarts, DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  for (final start in weekStarts) {
    final endDay = DateTime(start.year, start.month, start.day + 6);
    if (!d.isBefore(start) && !d.isAfter(endDay)) {
      return start;
    }
  }
  return null;
}

String _md(DateTime d) => '${d.month}.${d.day}';
