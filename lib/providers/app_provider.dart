import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../services/network_service.dart';
import '../android_channel/auto_record_service.dart';
import '../android_channel/accessibility_channel.dart';

class AppProvider extends ChangeNotifier {
  final AppDatabase _db;
  final NetworkService _network;

  bool _isOnline = true;
  bool _mockMode = true;
  // 自动记账开关（仅无障碍服务）
  bool _accessibilityAutoRecordEnabled = false;
  int _pendingSyncCount = 0;
  bool _accessibilityPermissionGranted = false;
  // 保存网络监听订阅，防止内存泄漏
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get isOnline => _isOnline;
  bool get mockMode => _mockMode;
  
  // 无障碍自动记账开关
  bool get accessibilityAutoRecordEnabled => _accessibilityAutoRecordEnabled;
  
  // 自动记账是否已开启
  bool get anyAutoRecordEnabled => _accessibilityAutoRecordEnabled;
  
  int get pendingSyncCount => _pendingSyncCount;
  bool get accessibilityPermissionGranted => _accessibilityPermissionGranted;
  
  // 通知栏监听功能已移除，保留属性用于UI显示（始终为false）
  bool get notificationAutoRecordEnabled => false;
  bool get notificationPermissionGranted => false;

  /// 权限是否已授权
  bool get allPermissionsGranted => _accessibilityPermissionGranted;

  AppProvider(this._db, this._network) {
    _init();
    // 持续监听同步队列变化，自动更新 UI 显示的待同步数
    _watchPendingSync();
  }

  /// 暴露数据库给其他服务（如 BackupService）使用
  AppDatabase get db => _db;

  /// 通知所有监听者数据已变更（用于导入数据后手动触发 UI 刷新，
  /// 虽然 Drift watch 流会自动触发，调用一次更保险）
  void notifyDataChanged() {
    notifyListeners();
  }

  /// 监听同步队列，实时更新待同步数量
  void _watchPendingSync() {
    final query = _db.select(_db.offlineSyncQueue)
      ..where((t) => t.status.equals(0) | t.status.equals(3));
    query.watch().listen((items) {
      if (_pendingSyncCount != items.length) {
        _pendingSyncCount = items.length;
        notifyListeners();
      }
    });
  }

  void _init() async {
    // 监听网络状态
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
      notifyListeners();
      if (_isOnline) {
        _processSyncQueue();
      }
    });

    // 获取初始网络状态
    final result = await Connectivity().checkConnectivity();
    _isOnline = !result.contains(ConnectivityResult.none);

    // 加载用户配置
    final config = await _db.getUserConfig();
    if (config != null) {
      _mockMode = config.mockMode;
      _accessibilityAutoRecordEnabled = config.accessibilityAutoRecordEnabled;
      // 通知栏自动记账配置不再使用
    }

    // 检查权限（仅Android）
    if (Platform.isAndroid) {
      await _checkAllPermissions();
    }

    // 如果自动记账已开启，启动服务
    if (_accessibilityAutoRecordEnabled) {
      _startAutoRecordService();
    }

    // 更新待同步数量
    _updatePendingSyncCount();

    notifyListeners();
  }

  /// 检查所有权限状态
  Future<void> _checkAllPermissions() async {
    // 检查无障碍服务权限
    _accessibilityPermissionGranted =
        await AccessibilityChannel().isEnabled();
    
    debugPrint('权限检查 - 无障碍: $_accessibilityPermissionGranted (通知栏监听已移除)');
  }

  Future<void> _updatePendingSyncCount() async {
    final items = await _db.getPendingSyncItems();
    _pendingSyncCount = items.length;
    notifyListeners();
  }

  /// 处理同步队列（项目规则：单条失败保留队列下次重试）
  Future<void> _processSyncQueue() async {
    final items = await _db.getPendingSyncItems();
    for (final item in items) {
      await _db.updateSyncStatus(item.id, 1); // 同步中
      try {
        // Mock 模式：直接视为成功；真实模式下应调用 _network.request
        if (_mockMode) {
          await _db.updateSyncStatus(item.id, 2, syncedAt: DateTime.now());
        } else {
          // TODO: 真实后端同步逻辑
          // 失败时标记 status=3（待重试），由下次同步再次尝试
          await _db.updateSyncStatus(item.id, 2, syncedAt: DateTime.now());
        }
      } catch (e) {
        debugPrint('同步失败（保留队列稍后重试）: $e');
        await _db.updateSyncStatus(item.id, 3); // 失败：保留队列
      }
    }
  }

  /// 启动自动记账服务
  void _startAutoRecordService() {
    debugPrint('========== 开始启动自动记账服务 ==========');
    debugPrint('   监听模式: 仅无障碍服务 (通知栏监听已关闭)');
    final autoRecord = AutoRecordService.instance;

    // 设置创建成功回调
    autoRecord.onBillCreated = (result) async {
      debugPrint('✅ 收到账单确认回调: $result');
      await _createBillFromParseResult(result);
    };

    // 启动前检查各项状态
    debugPrint('📱 平台: ${Platform.isAndroid ? "Android" : "其他"}');
    debugPrint('♿ 无障碍记账开关: $_accessibilityAutoRecordEnabled');
    debugPrint('♿ 无障碍权限: $_accessibilityPermissionGranted');

    autoRecord.start();
    debugPrint('✅ 自动记账服务启动完成, isRunning: ${autoRecord.isRunning}');
    debugPrint('=========================================');
  }

  /// 从解析结果创建账单
  Future<void> _createBillFromParseResult(BillParseResult result) async {
    try {
      // 获取默认账户 - 使用正确的数据库方法
      final accounts = await (_db.select(_db.localAccounts)..limit(1)).get();
      if (accounts.isEmpty) {
        debugPrint('自动记账失败：没有可用账户');
        return;
      }

      // 根据账单类型选择账户
      final accountId = accounts.first.accountId;

      // 生成sourceHash用于防重复
      final sourceHash = _generateSourceHash(
        '${result.source}_${result.amount}_${result.remark}',
      );

      // 插入账单 - 使用数据库表定义的正确字段
      await _db.insertBill(LocalBillsCompanion(
        billId: Value('bill_${DateTime.now().millisecondsSinceEpoch}'),
        accountId: Value(accountId),
        type: Value(result.type == BillType.expense ? 'expense' : 'income'),
        amount: Value(result.amount),
        categoryId: const Value('auto_category'),
        categoryName: Value(result.source),
        remark: Value(result.remark),
        source: const Value('accessibility'),
        sourceHash: Value(sourceHash),
        billTime: Value(DateTime.now()),
        confirmStatus: const Value(1),
        syncStatus: const Value(0),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));

      debugPrint('自动记账成功: $result');
    } catch (e) {
      debugPrint('自动记账创建账单失败: $e');
    }
  }

  /// 生成 sourceHash 用于防重复（项目规则强制 sha256）
  String _generateSourceHash(String source) {
    final bytes = utf8.encode(source);
    return sha256.convert(bytes).toString();
  }

  void setMockMode(bool enabled) {
    _mockMode = enabled;
    _network.setMockMode(enabled);
    _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
      mockMode: Value(enabled),
      updatedAt: Value(DateTime.now()),
    ));
    notifyListeners();
  }

  /// 设置无障碍自动记账开关
  /// 返回值：true=设置成功，false=需要授权
  Future<bool> setAccessibilityAutoRecordEnabled(bool enabled) async {
    if (enabled) {
      // 开启时检查权限
      if (!_accessibilityPermissionGranted) {
        debugPrint('无法开启无障碍自动记账：没有无障碍权限');
        return false;
      }
      _accessibilityAutoRecordEnabled = true;
      _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        accessibilityAutoRecordEnabled: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
      _startAutoRecordService();
    } else {
      _accessibilityAutoRecordEnabled = false;
      _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        accessibilityAutoRecordEnabled: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
      // 停止服务
      AutoRecordService.instance.stop();
    }
    notifyListeners();
    return true;
  }

  /// 请求无障碍服务权限（供UI调用）
  Future<bool> requestAccessibilityPermission() async {
    if (Platform.isAndroid) {
      bool granted = await AccessibilityChannel().isEnabled();
      debugPrint('无障碍权限当前状态: $granted');
      
      if (granted) {
        _accessibilityPermissionGranted = true;
        notifyListeners();
        return true;
      }
      
      await AccessibilityChannel().openSettings();
      await Future.delayed(const Duration(seconds: 3));
      
      for (int i = 0; i < 3; i++) {
        granted = await AccessibilityChannel().isEnabled();
        debugPrint('无障碍权限第${i + 1}次检查: $granted');
        if (granted) break;
        if (i < 2) await Future.delayed(const Duration(seconds: 1));
      }
      
      _accessibilityPermissionGranted = granted;
      debugPrint('无障碍权限最终状态: $_accessibilityPermissionGranted');

      // 如果自动记账开关已开启，则启动服务
      if (_accessibilityAutoRecordEnabled) {
        _startAutoRecordService();
      }

      notifyListeners();
      return _accessibilityPermissionGranted;
    }
    return false;
  }

  /// 检查所有权限状态并更新UI
  Future<void> refreshPermissions() async {
    await _checkAllPermissions();
    notifyListeners();
  }

  /// 获取详细权限状态
  Future<Map<String, bool>> getDetailedPermissionsStatus() async {
    return {
      'accessibility': await AccessibilityChannel().isEnabled(),
      'notification': false, // 通知栏监听已移除
    };
  }

  @override
  void dispose() {
    // 取消网络状态监听订阅
    _connectivitySubscription?.cancel();
    AutoRecordService.instance.dispose();
    super.dispose();
  }
}
