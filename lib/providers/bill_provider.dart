import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../services/network_service.dart';

/// 首页账单列表 Provider
/// - 列表数据按 50 条/页懒加载（[loadInitial] / [loadMore] / [refresh]）
/// - 顶部汇总（今日支出 / 本月收支）通过 SQL 聚合独立维护，不依赖分页结果
/// - 待同步 / 待确认数量由独立 stream 维护
class BillProvider extends ChangeNotifier {
  /// 每页条数（首页流水列表）
  static const int pageSize = 50;

  final AppDatabase _db;
  final NetworkService _network;

  // ---- 分页状态 ----
  List<LocalBillsData> _bills = [];
  bool _isLoading = false; // 首屏加载
  bool _isLoadingMore = false; // 上拉加载更多
  bool _hasMore = true; // 是否还有更多
  String? _error;

  // ---- 独立维护的计数器（来自 stream）----
  int _totalCount = 0;
  int _pendingSyncCount = 0;
  int _unconfirmedCount = 0;

  // ---- 顶部汇总 ----
  Map<String, double> _summary = {
    'todayExpense': 0.0,
    'monthExpense': 0.0,
    'monthIncome': 0.0,
  };

  StreamSubscription? _countSub;
  StreamSubscription? _pendingSub;
  StreamSubscription? _unconfirmedSub;
  StreamSubscription? _summarySub;

  // ---- getters ----
  List<LocalBillsData> get bills => _bills;
  Map<String, dynamic> get summary => _summary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  int get totalCount => _totalCount;
  int get pendingSyncCount => _pendingSyncCount;
  int get unconfirmedCount => _unconfirmedCount;

  BillProvider(this._db, this._network) {
    _init();
  }

  void _init() {
    // 总数变化时同步 hasMore 状态
    _countSub = _db.watchBillsTotalCount().listen((c) {
      _totalCount = c;
      _hasMore = _bills.length < _totalCount;
      notifyListeners();
    });
    // 待同步数量
    _pendingSub = _db.watchPendingSyncCount().listen((c) {
      _pendingSyncCount = c;
      notifyListeners();
    });
    // 待确认数量
    _unconfirmedSub = _db.watchUnconfirmedCount().listen((c) {
      _unconfirmedCount = c;
      notifyListeners();
    });
    // 顶部汇总（数据库变化时自动重算）
    _summarySub = _db.watchBillsSummary().listen((s) {
      _summary = s;
      notifyListeners();
    });

    // 首屏加载
    loadInitial();
  }

  @override
  void dispose() {
    _countSub?.cancel();
    _pendingSub?.cancel();
    _unconfirmedSub?.cancel();
    _summarySub?.cancel();
    super.dispose();
  }

  /// 加载首页（重置分页，加载前 [pageSize] 条）
  Future<void> loadInitial() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bills = await _db.getBillsPage(limit: pageSize, offset: 0);
      _hasMore = _bills.length < _totalCount;
    } catch (e) {
      _error = e.toString();
      debugPrint('加载账单失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载下一页（到底部时由首页滚动监听触发）
  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final more = await _db.getBillsPage(limit: pageSize, offset: _bills.length);
      _bills = [..._bills, ...more];
      _hasMore = _bills.length < _totalCount;
    } catch (e) {
      _error = e.toString();
      debugPrint('加载更多失败: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// 下拉刷新 / 新增账单后刷新
  Future<void> refresh() async {
    await loadInitial();
  }

  // ---- 写操作（增删改）----
  // 写操作完成后调用 loadInitial() 让列表头部展示新账单。
  // 顶部汇总会由 watchBillsSummary stream 自动重算，无需手动调。

  /// 添加账单（支持关联负债ID）
  /// 如果传入了 liabilityId，会同时创建对应的还款记录
  Future<bool> addBill({
    required String type,
    required double amount,
    required String accountId,
    String? categoryId,
    String? categoryName,
    String? remark,
    DateTime? billTime,
    String source = 'manual',
    String? liabilityId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final uuid = const Uuid();
      final billId = uuid.v4();
      final now = DateTime.now();

      final bill = LocalBillsCompanion(
        billId: Value(billId),
        type: Value(type),
        amount: Value(amount),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        categoryName: Value(categoryName),
        remark: Value(remark),
        billTime: Value(billTime ?? now),
        source: Value(source),
        liabilityId: Value(liabilityId),
        confirmStatus: const Value(1),
        syncStatus: Value(_network.isOnline ? 1 : 0),
      );

      // 插入账单
      await _db.insertBill(bill);
      // 注意：负债还款的 repay 记录和 repaidAmount 更新统一由
      // LiabilityProvider.addRepay 处理，禁止在此重复写入（避免双重记账）。

      // 添加离线同步队列（如果断网）
      if (!_network.isOnline) {
        await _db.addSyncQueue(OfflineSyncQueueCompanion(
          syncTableName: const Value('local_bills'),
          recordId: Value(billId),
          operation: const Value('insert'),
          data: Value('{}'),
        ));
      }

      // 刷新首页列表让新账单展示在头部
      await loadInitial();
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('保存账单失败: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmBill(String billId) async {
    await _db.updateBill(billId, LocalBillsCompanion(
      confirmStatus: const Value(1),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> updateBill({
    required String billId,
    required String type,
    required double amount,
    required String accountId,
    String? categoryId,
    String? categoryName,
    String? remark,
    DateTime? billTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _db.updateBill(billId, LocalBillsCompanion(
        type: Value(type),
        amount: Value(amount),
        accountId: Value(accountId),
        categoryId: Value(categoryId),
        categoryName: Value(categoryName),
        remark: Value(remark),
        billTime: Value(billTime ?? DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
      // 刷新首页（billTime 可能改变导致顺序变化）
      await loadInitial();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBill(String billId) async {
    await _db.deleteBill(billId);
    // 刷新首页让已删账单从列表消失
    await loadInitial();
  }
}
