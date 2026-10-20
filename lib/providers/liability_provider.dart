import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database.dart';
import '../services/network_service.dart';

class LiabilityProvider extends ChangeNotifier {
  final AppDatabase _db;
  final NetworkService _network;

  List<LocalLiabilitiesData> _liabilities = [];
  List<LocalLiabilityRepaysData> _repays = [];
  Map<String, dynamic> _summary = {};
  bool _isLoading = false;
  String? _error;

  List<LocalLiabilitiesData> get liabilities => _liabilities;
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 总负债金额
  double get totalLiability => _liabilities.fold(0, (sum, l) => sum + l.totalAmount);

  /// 待还金额（未结清的负债）
  double get pendingRepay => _liabilities
      .where((l) => l.status == 0)
      .fold(0, (sum, l) => sum + (l.totalAmount - l.repaidAmount));

  /// 已还金额
  double get repaidAmount => _liabilities.fold(0, (sum, l) => sum + l.repaidAmount);

  /// 超期金额
  /// 说明：
  /// - 持续性负债（credit_card / other / personal）没有到期日：
  ///   dueDate 是 form 默认值（创建时间 +30天），无意义，因此不参与 dueDate 比较
  /// - credit_card / other 的真实还款日是 repayDate，逾期由 liabilityIsOverdue 判定；
  ///   personal 无还款日，本身不判逾期
  /// - installment / mortgage / car_loan 的 dueDate 由用户录入，可信
  double get overdueAmount {
    final now = DateTime.now();
    return _liabilities
        .where((l) =>
            l.status == 0 &&
            l.type != 'credit_card' &&
            l.type != 'other' &&
            l.type != 'personal' &&
            l.dueDate.isBefore(now))
        .fold(0, (sum, l) => sum + (l.totalAmount - l.repaidAmount));
  }

  /// 本月待还金额
  /// 私人借款不计入（无还款日，无月度账单概念）
  double get thisMonthRepay {
    return _calcMonthRepay(DateTime.now(), isNextMonth: false);
  }

  /// 下月待还金额
  /// 私人借款不计入（无还款日，无月度账单概念）
  double get nextMonthRepay {
    return _calcMonthRepay(DateTime.now(), isNextMonth: true);
  }

  /// 核心计算：指定 monthOffset（0=本月，1=下月）
  ///
  /// 显式排除以下负债类型（这些类型没有月度账单概念，不计入本月/下月待还）：
  /// - personal（私人借款）：无还款日，纯待还剩余本金
  double _calcMonthRepay(DateTime now, {required bool isNextMonth}) {
    int targetYear = now.year;
    int targetMonth = isNextMonth ? now.month + 1 : now.month;
    if (targetMonth > 12) {
      targetMonth = 1;
      targetYear += 1;
    }

    return _liabilities
        .where((l) =>
            l.status == 0 &&
            l.type != 'personal') // 私人借款不计入本月/下月待还
        .fold(0, (sum, l) => sum + _liabilityMonthAmount(l, now, targetYear, targetMonth, isThisMonth: !isNextMonth));
  }

  /// 是否"无到期日的持续性负债"：信用卡 / 月付信贷 / 私人借款
  /// 这三类没有到期日，属于循环欠款，只要没还完就一直还。
  /// 当前仅用于 liabilityHasDueDate —— 决定 UI 是否展示 dueDate。
  /// 是否计入本月 / 下月待还由 _liabilityMonthAmount 按类型分别处理。
  bool _isOngoingLiability(LocalLiabilitiesData l) {
    return l.type == 'credit_card' ||
        l.type == 'other' ||
        l.type == 'personal';
  }

  /// 单笔负债在指定月份的待还金额
  ///
  /// - 私人借款：已在 _calcMonthRepay 入口过滤，这里再 return 0 作为兜底
  /// - 信用卡 / 月付信贷：按月循环账单，没有到期日。repayDate 的年月表示首期账单月，
  ///   早于首期的月份不计入；首期及之后每月自动计入剩余本金
  /// - [isThisMonth]=true：本月待还。规则：首期账单已到 AND 本月没还过
  /// - [isThisMonth]=false：下月待还。规则：未结清即有下期账单
  double _liabilityMonthAmount(LocalLiabilitiesData l, DateTime now, int targetYear, int targetMonth, {required bool isThisMonth}) {
    // 兜底：私人借款理论上已被 _calcMonthRepay 入口过滤，
    // 这里再 return 0 保证任何直接调用者也不会误算
    if (l.type == 'personal') return 0;

    // 信用卡 / 月付信贷：按月循环账单
    // repayDate 锚定"下一个还没到的还款日"，含义有两层：
    //   year-month = 首期账单在哪个月  day = 每月几号出账单
    // 循环特性：首期之后每月自动出账单，剩余本金即为当期账单金额；
    // 还款后 repaidAmount 增加，下期账单自动变成新的剩余本金
    if (l.type == 'credit_card' || l.type == 'other') {
      final pending = l.totalAmount - l.repaidAmount;
      final repayDate = l.repayDate;
      // 老数据缺失 repayDate，无法确定首期，只按循环计入下月
      if (repayDate == null) return isThisMonth ? 0 : pending;

      // 目标月早于首期账单月 → 账单还没开始，不计入
      // （例：9/29 录入、账单日 7 号 → repayDate = 10/7，9 月不计入，到 10 月才激活）
      final bool isBeforeFirstBill = targetYear < repayDate.year ||
          (targetYear == repayDate.year && targetMonth < repayDate.month);
      if (isBeforeFirstBill) return 0;

      // 本月已登记过还款 → 该期账单结清，归 0
      if (isThisMonth && _hasRepayInMonth(l.liabilityId, targetYear, targetMonth)) return 0;
      return pending;
    }

    // 消费分期 / 房贷 / 车贷：按月供计算
    if (l.type == 'installment' || l.type == 'mortgage' || l.type == 'car_loan') {
      DateTime endDate = l.lastPaymentDate ?? l.dueDate;
      // 数据一致性兜底：firstPaymentDate > lastPaymentDate 视为异常数据
      // 常见来源：用户把到期日设在首期扣款日之前
      // （首期扣款日是"下一个还没到的还款日"，见 firstPaymentFromRepayDay）
      // 这种情况下整笔贷款视为一次性负债，全部剩余计入本月待还
      DateTime startDate;
      if (l.firstPaymentDate != null) {
        startDate = l.firstPaymentDate!;
      } else {
        startDate = DateTime(now.year - 30, 1, 1);
      }
      final bool isInvertedPeriod = startDate.isAfter(endDate);
      if (isInvertedPeriod) {
        // 异常数据：本月已还 → 0；否则返回剩余总额
        if (isThisMonth) {
          if (_hasRepayInMonth(l.liabilityId, targetYear, targetMonth)) return 0;
          return l.totalAmount - l.repaidAmount;
        }
        return 0;
      }

      // 目标月扣款日
      final repayDay = _extractRepayDay(l);
      if (repayDay <= 0) return 0;
      final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
      final actualDay = repayDay > daysInTargetMonth ? daysInTargetMonth : repayDay;
      final dueDateInTargetMonth = DateTime(targetYear, targetMonth, actualDay);

      // 扣款日不在贷款期内 → 不计入
      if (dueDateInTargetMonth.isBefore(startDate)) return 0;
      if (dueDateInTargetMonth.isAfter(endDate)) return 0;

      // 本月特有：扣款日已过不归 0（过期也要继续显示本月待还，未还由下面的 isOverdue 判断单独展示）
      // 只在本月已还 → 0
      if (isThisMonth) {
        if (_hasRepayInMonth(l.liabilityId, targetYear, targetMonth)) return 0;
      }

      final months = _monthsBetween(startDate, endDate);
      if (months <= 0) return 0;
      return l.totalAmount / months;
    }

    return 0;
  }

  /// 提取月付类负债的"每月几号"
  int _extractRepayDay(LocalLiabilitiesData l) {
    // 房贷/车贷：firstPaymentDate.day 即还款日（由表单计算并写入）
    if (l.type == 'mortgage' || l.type == 'car_loan') {
      return l.firstPaymentDate?.day ?? l.dueDate.day;
    }
    // 消费分期：dueDate 是末期日，.day 即每月还款日
    if (l.type == 'installment') {
      return l.dueDate.day;
    }
    // 信用卡/月付信贷：repayDate.day（dueDate 已废弃）
    return l.repayDate!.day;
  }

  /// 该负债在指定 (year, month) 是否已登记过还款
  bool _hasRepayInMonth(String liabilityId, int year, int month) {
    for (final r in _repays) {
      if (r.liabilityId != liabilityId) continue;
      if (r.repayTime.year == year && r.repayTime.month == month) {
        return true;
      }
    }
    return false;
  }

  /// 公开：本月是否已登记过还款（用于"本月已还清"chip 判定）
  bool liabilityHasRepayThisMonth(LocalLiabilitiesData l) {
    final now = DateTime.now();
    return _hasRepayInMonth(l.liabilityId, now.year, now.month);
  }

  /// 公开：单笔负债本月待还金额（列表项展示用）
  double liabilityThisMonthRepay(LocalLiabilitiesData l) {
    if (l.status != 0) return 0;
    final now = DateTime.now();
    return _liabilityMonthAmount(l, now, now.year, now.month, isThisMonth: true);
  }

  /// 公开：单笔负债的"每月还款金额"（不受日期过滤影响，纯展示用）
  /// - 月付类（installment / mortgage / car_loan）：totalAmount / 期数
  /// - 其他类型：返回 0（一次性负债的"待还金额"语义是剩余本金，不在这里展示）
  double liabilityMonthlyAmount(LocalLiabilitiesData l) {
    if (l.type != 'installment' &&
        l.type != 'mortgage' &&
        l.type != 'car_loan') {
      return 0;
    }
    final DateTime? start = l.firstPaymentDate;
    final end = l.lastPaymentDate ?? l.dueDate;
    if (start == null) return 0;
    final months = _monthsBetween(start, end);
    if (months <= 0) return 0;
    return l.totalAmount / months;
  }

  /// 公开：单笔负债的"每月几号还款"，非月付类返回 null
  int? liabilityRepayDay(LocalLiabilitiesData l) {
    if (l.type == 'installment' ||
        l.type == 'mortgage' ||
        l.type == 'car_loan' ||
        l.type == 'credit_card' ||
        l.type == 'other') {
      final day = _extractRepayDay(l);
      return day > 0 ? day : null;
    }
    return null;
  }

  /// 公开：该负债是否有"到期日"概念
  /// 持续性负债（信用卡 / 月付信贷 / 私人借款）没有到期日，UI 不应展示 dueDate
  bool liabilityHasDueDate(LocalLiabilitiesData l) => !_isOngoingLiability(l);

  /// 公开：单笔负债是否逾期
  /// - 月供类（分期/房贷/车贷）：本月扣款日 < 今天 AND 本月未登记还款
  /// - 持续性负债（信用卡/月付信贷）：按每月还款日判，同上
  /// - 私人借款：无还款日、无到期日，不参与逾期判定
  bool liabilityIsOverdue(LocalLiabilitiesData l) {
    if (l.status != 0) return false;
    // 私人借款：没有还款日也没有到期日，无法定义"逾期"，恒不判逾期
    if (l.type == 'personal') return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isMonthly = l.type == 'installment' ||
        l.type == 'mortgage' ||
        l.type == 'car_loan' ||
        l.type == 'credit_card' ||
        l.type == 'other';

    if (isMonthly) {
      final repayDay = _extractRepayDay(l);
      if (repayDay <= 0) return false;
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final actualDay = repayDay > daysInMonth ? daysInMonth : repayDay;
      final dueDateInThisMonth = DateTime(now.year, now.month, actualDay);
      if (dueDateInThisMonth.isBefore(today)) {
        // 首期扣款日还没到（新增时还款日已过 → 已顺延到下个月），不视为逾期
        final startDate = _liabilityStartDate(l);
        if (startDate != null && startDate.isAfter(today)) return false;
        return !_hasRepayInMonth(l.liabilityId, now.year, now.month);
      }
      return false;
    }

    return false;
  }

  /// 负债的起始日（首期扣款日）
  /// - 月供类（消费分期/房贷/车贷）：firstPaymentDate
  /// - 信用卡/月付信贷：repayDate 已在录入时锚定为"下一个还没到的还款日"
  /// 返回 null 表示无起始日约束
  DateTime? _liabilityStartDate(LocalLiabilitiesData l) {
    if (l.type == 'installment' || l.type == 'mortgage' || l.type == 'car_loan') {
      return l.firstPaymentDate;
    }
    if (l.type == 'credit_card' || l.type == 'other') {
      return l.repayDate;
    }
    return null;
  }

  /// 公开：逾期天数（从应还日 → 今天）
  /// 只有月付类（含持续性负债里的信用卡 / 月付信贷）可能逾期，
  /// 私人借款恒为 0（无还款日）
  int liabilityOverdueDays(LocalLiabilitiesData l) {
    if (!liabilityIsOverdue(l)) return 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final repayDay = _extractRepayDay(l);
    if (repayDay <= 0) return 0;
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final actualDay = repayDay > daysInMonth ? daysInMonth : repayDay;
    final baseDate = DateTime(now.year, now.month, actualDay);
    return today.difference(baseDate).inDays;
  }

  /// 公开：逾期应还金额
  /// - 消费分期 / 房贷 / 车贷：单期月供
  /// - 信用卡 / 月付信贷：剩余本金（持续性负债，没有"期数"概念）
  /// - 私人借款：恒为 0（无还款日，不判逾期）
  double liabilityOverdueAmount(LocalLiabilitiesData l) {
    if (!liabilityIsOverdue(l)) return 0;
    final isMonthlyTerm = l.type == 'mortgage' ||
        l.type == 'car_loan' ||
        l.type == 'installment';
    // totalAmount = 月供 × 期数，逾期一期 = 月供
    if (isMonthlyTerm &&
        l.firstPaymentDate != null &&
        l.lastPaymentDate != null) {
      final months = _monthsBetween(l.firstPaymentDate!, l.lastPaymentDate!);
      if (months > 0) return l.totalAmount / months;
    }
    return l.totalAmount - l.repaidAmount;
  }

  int _monthsBetween(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month) + 1;
  }

  LiabilityProvider(this._db, this._network) {
    _init();
  }

  void _init() {
    _db.watchAllLiabilities().listen((liabilities) {
      _liabilities = liabilities;
      _updateSummary();
      notifyListeners();
    });
    // 监听还款流水，确保 本月/下月待还 在登记还款后立即重算
    _db.watchAllRepays().listen((repays) {
      _repays = repays;
      _updateSummary();
      notifyListeners();
    });
  }

  /// 手动刷新数据
  Future<void> refreshData() async {
    final liabilities = await _db.getAllLiabilities();
    _liabilities = liabilities;
    // 同步刷新还款流水
    final repays = await (_db.select(_db.localLiabilityRepays)
          ..orderBy([(t) => OrderingTerm.desc(t.repayTime)]))
        .get();
    _repays = repays;
    _updateSummary();
    notifyListeners();
  }

  /// 更新本地汇总数据
  void _updateSummary() {
    _summary = {
      'totalLiability': totalLiability,
      'pendingRepay': pendingRepay,
      'repaid': repaidAmount,
      'overdueAmount': overdueAmount,
      'thisMonthRepay': thisMonthRepay,
      'nextMonthRepay': nextMonthRepay,
    };
  }

  Future<void> loadSummary() async {
    // 直接使用本地计算的数据，不需要从网络获取
    _updateSummary();
    notifyListeners();
  }

  Future<void> addLiability({
    required String name,
    required String type,
    required String accountId,
    required double totalAmount,
    DateTime? dueDate,
    String? remark,
    String? institution,
    String? loanDate,
    DateTime? firstPaymentDate,
    DateTime? lastPaymentDate,
    DateTime? repayDate, // 信用卡/月付信贷的每月还款日（dueDate 已废弃）
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uuid = const Uuid();
      final liabilityId = uuid.v4();

      final liability = LocalLiabilitiesCompanion(
        liabilityId: Value(liabilityId),
        name: Value(name),
        type: Value(type),
        accountId: Value(accountId),
        totalAmount: Value(totalAmount),
        dueDate: Value(dueDate ?? DateTime.now().add(const Duration(days: 30))),
        remark: Value(remark),
        institution: Value(institution),
        loanDate: Value(loanDate),
        firstPaymentDate: Value(firstPaymentDate),
        lastPaymentDate: Value(lastPaymentDate),
        repayDate: Value(repayDate),
        syncStatus: Value(_network.isOnline ? 1 : 0),
        status: const Value(0),
      );

      await _db.insertLiability(liability);

      if (!_network.isOnline) {
        await _db.addSyncQueue(OfflineSyncQueueCompanion(
          syncTableName: const Value('local_liabilities'),
          recordId: Value(liabilityId),
          operation: const Value('insert'),
          data: Value('{}'),
        ));
      }
      // 数据库监听器会自动更新数据并触发 notifyListeners()
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRepay({
    required String liabilityId,
    required double amount,
    required String accountId,
    DateTime? repayTime,
    String? remark,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      final repayId = uuid.v4();
      final billId = uuid.v4();
      final actualRepayTime = repayTime ?? DateTime.now();

      // 插入还款记录
      await _db.insertRepay(LocalLiabilityRepaysCompanion(
        repayId: Value(repayId),
        liabilityId: Value(liabilityId),
        amount: Value(amount),
        accountId: Value(accountId),
        repayTime: Value(actualRepayTime),
        remark: Value(remark),
        syncStatus: Value(_network.isOnline ? 1 : 0),
      ));

      // 同时写入账单（负债还款 → 支出账单）
      // sourceHash 用于防重复记账：负债还款用 repayId 关联
      final sourceHash = sha256.convert(utf8.encode('liability_repay_$repayId')).toString();
      await _db.insertBill(LocalBillsCompanion(
        billId: Value(billId),
        sourceHash: Value(sourceHash),
        type: const Value('expense'),
        amount: Value(amount),
        accountId: Value(accountId),
        categoryId: const Value('repay_liability'),
        categoryName: const Value('负债还款'),
        billTime: Value(actualRepayTime),
        source: const Value('liability_repay'),
        liabilityId: Value(liabilityId),
        remark: Value(remark ?? '还款'),
        syncStatus: Value(_network.isOnline ? 1 : 0),
        confirmStatus: const Value(1),
      ));

      // 更新负债已还金额
      final liability = _liabilities.firstWhere(
        (l) => l.liabilityId == liabilityId,
        orElse: () => _liabilities.first, // 不应该发生，但提供安全回退
      );
      final newRepaidAmount = liability.repaidAmount + amount;
      final newStatus = newRepaidAmount >= liability.totalAmount ? 1 : 0;

      await _db.updateLiability(liabilityId, LocalLiabilitiesCompanion(
        repaidAmount: Value(newRepaidAmount),
        status: Value(newStatus),
        updatedAt: Value(DateTime.now()),
      ));
      // 数据库监听器会自动更新数据并触发 notifyListeners()
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLiability(String liabilityId) async {
    try {
      // 先删除关联的还款记录
      await _db.deleteRepaysByLiability(liabilityId);
      // 再删除负债记录
      await _db.deleteLiability(liabilityId);
      // 手动刷新数据确保UI更新
      await refreshData();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Stream<List<LocalLiabilityRepaysData>> watchRepays(String liabilityId) {
    return _db.watchRepaysByLiability(liabilityId);
  }
}
