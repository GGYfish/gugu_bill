import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import '../database/database.dart';
import '../android_channel/auto_record_service.dart';
import '../android_channel/accessibility_channel.dart';
import '../android_channel/notification_channel.dart';
import '../android_channel/keep_alive_channel.dart';
import '../utils/money.dart';
import '../widgets/top_toast.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final AppDatabase _db;

  // 自动记账开关
  bool _accessibilityAutoRecordEnabled = false;
  bool _notificationAutoRecordEnabled = false;
  bool _accessibilityPermissionGranted = false;
  bool _notificationPermissionGranted = false;
  bool _accessibilityServiceRunning = false;
  bool _ignoringBatteryOptimizations = false;

  // 无障碍自动记账开关
  bool get accessibilityAutoRecordEnabled => _accessibilityAutoRecordEnabled;
  bool get notificationAutoRecordEnabled => _notificationAutoRecordEnabled;
  
  // 自动记账是否已开启
  bool get anyAutoRecordEnabled =>
      _accessibilityAutoRecordEnabled || _notificationAutoRecordEnabled;
  
  bool get accessibilityPermissionGranted => _accessibilityPermissionGranted;
  bool get notificationPermissionGranted => _notificationPermissionGranted;
  bool get accessibilityServiceRunning => _accessibilityServiceRunning;
  bool get ignoringBatteryOptimizations => _ignoringBatteryOptimizations;

  /// 开关开着，但权限被系统关掉 / 服务没起来（常见于强制停止后）
  bool get needsAccessibilityReenable =>
      _accessibilityAutoRecordEnabled &&
      (!_accessibilityPermissionGranted || !_accessibilityServiceRunning);

  bool get needsNotificationReenable =>
      _notificationAutoRecordEnabled && !_notificationPermissionGranted;

  /// 权限是否已授权
  bool get allPermissionsGranted =>
      _accessibilityPermissionGranted || _notificationPermissionGranted;

  AppProvider(this._db) {
    _init();
  }

  /// 暴露数据库给其他服务（如 BackupService）使用
  AppDatabase get db => _db;

  /// 通知所有监听者数据已变更（用于导入数据后手动触发 UI 刷新，
  /// 虽然 Drift watch 流会自动触发，调用一次更保险）
  void notifyDataChanged() {
    notifyListeners();
  }

  void _init() async {
    // 加载用户配置
    final config = await _db.getUserConfig();
    if (config != null) {
      _accessibilityAutoRecordEnabled = config.accessibilityAutoRecordEnabled;
      _notificationAutoRecordEnabled = config.notificationAutoRecordEnabled;
    }

    // 确保「自动记账」大分类存在（老库升级也能补上）
    try {
      await _db.ensureAutoRecordParentCategories();
    } catch (e) {
      debugPrint('确保自动记账分类失败: $e');
    }

    // 检查权限（仅Android）
    if (Platform.isAndroid) {
      await _checkAllPermissions();
      // 把库里的开关同步给原生，供开机广播恢复
      await _syncKeepAliveState();
    }

    // 如果自动记账已开启，启动服务 + 保活
    if (anyAutoRecordEnabled) {
      _startAutoRecordService();
    }

    notifyListeners();
  }

  /// 检查所有权限状态
  Future<void> _checkAllPermissions() async {
    final a11yState = await AccessibilityChannel().getServiceState();
    _accessibilityPermissionGranted = a11yState.isEnabled;
    _accessibilityServiceRunning = a11yState.isRunning;
    _notificationPermissionGranted =
        await NotificationChannel().isEnabled();
    _ignoringBatteryOptimizations =
        await KeepAliveChannel().isIgnoringBatteryOptimizations();

    debugPrint(
      '权限检查 - 无障碍授权: $_accessibilityPermissionGranted 运行中: $_accessibilityServiceRunning, '
      '通知栏: $_notificationPermissionGranted, 忽略电池优化: $_ignoringBatteryOptimizations',
    );
  }

  /// 打开系统无障碍设置（强制停止后必须用户手动再开一次）
  Future<void> openAccessibilitySettings() async {
    await AccessibilityChannel().openSettings();
  }

  Future<void> openNotificationListenerSettings() async {
    await NotificationChannel().openSettings();
  }

  /// 同步原生开关 + 启停前台保活
  Future<void> _syncKeepAliveState() async {
    if (!Platform.isAndroid) return;
    final keepAlive = KeepAliveChannel();
    await keepAlive.syncAutoRecordFlags(
      notification: _notificationAutoRecordEnabled,
      accessibility: _accessibilityAutoRecordEnabled,
    );
    if (anyAutoRecordEnabled) {
      await keepAlive.startKeepAlive();
    } else {
      await keepAlive.stopKeepAlive();
    }
  }

  /// 启动/更新自动记账服务
  void _startAutoRecordService() {
    debugPrint('========== 启动自动记账服务 ==========');
    final autoRecord = AutoRecordService.instance;

    autoRecord.onBillCreated = (result) async {
      debugPrint('✅ 自动记账回调: $result');
      await _createBillFromParseResult(result);
    };

    debugPrint('♿ 无障碍: $_accessibilityAutoRecordEnabled (权限=$_accessibilityPermissionGranted)');
    debugPrint('🔔 通知栏: $_notificationAutoRecordEnabled (权限=$_notificationPermissionGranted)');

    autoRecord.updateModes(
      accessibility:
          _accessibilityAutoRecordEnabled && _accessibilityPermissionGranted,
      notification:
          _notificationAutoRecordEnabled && _notificationPermissionGranted,
    );
    // 同步保活状态（不 await，避免阻塞开关）
    _syncKeepAliveState();
    debugPrint('✅ 自动记账服务状态 isRunning=${autoRecord.isRunning}');

    // 诊断：系统已授权时，服务进程可能稍晚才 bind，延迟重试避免误报
    if (_accessibilityAutoRecordEnabled && _accessibilityPermissionGranted) {
      _diagnoseAccessibilityService();
    }
  }

  Future<void> _diagnoseAccessibilityService() async {
    for (var i = 1; i <= 5; i++) {
      await Future.delayed(Duration(milliseconds: i == 1 ? 500 : 800));
      final state = await AccessibilityChannel().getServiceState();
      debugPrint(
        '♿ 无障碍诊断#$i enabled=${state.isEnabled} running=${state.isRunning} name=${state.serviceName}',
      );
      if (state.isRunning) {
        debugPrint('♿ 无障碍服务已在运行');
        return;
      }
    }
    // 多次确认仍未起来，再提示用户手动开关一次
    debugPrint(
      '⚠️ 无障碍已授权但服务仍未运行，请到系统设置关闭再开启「咕咕鱼自动记账」',
    );
    await _notifyAutoRecordSuccess(
      '无障碍服务未运行，请到系统设置关闭再开启一次',
      isError: true,
    );
  }

  /// 从解析结果创建账单（静默，成功后轻提示；入库前防重复）
  Future<void> _createBillFromParseResult(BillParseResult result) async {
    try {
      // 与「记一笔」一致：默认挂 cash 账户
      const accountId = 'cash';
      final billType =
          result.type == BillType.expense ? 'expense' : 'income';
      final amountDec = result.amount;
      final amount = amountDec.toDouble();

      // 稳定 sourceHash（不含时间戳），相同来源+金额+备注视为同一笔
      final sourceHash = _generateSourceHash(
        '${result.recordSource}|${result.source}|${formatMoney(amountDec)}|${result.remark ?? ''}',
      );

      final existed = await _db.findBillBySourceHash(sourceHash);
      if (existed != null) {
        debugPrint('自动记账去重(sourceHash): 已存在 billId=${existed.billId}');
        return;
      }

      // 兜底：10 分钟内同渠道、同 App、同金额也不再记（备注偶发变化）
      final recent = await _db.findRecentSimilarAutoBill(
        recordSource: result.recordSource,
        appSourceName: result.source,
        amount: amount,
        within: const Duration(minutes: 10),
      );
      if (recent != null) {
        debugPrint(
          '自动记账去重(近期同额): 已存在 billId=${recent.billId} '
          'amount=${formatMoney(amountDec)} source=${result.recordSource}',
        );
        return;
      }

      // 来源作为「自动记账」大类下的小分类：有则用，无则创建
      final category = await _db.resolveAutoRecordSubCategory(
        sourceName: result.source,
        billType: billType,
      );

      final billId =
          'bill_${DateTime.now().microsecondsSinceEpoch}_${sourceHash.substring(0, 8)}';

      await _db.insertBill(LocalBillsCompanion(
        billId: Value(billId),
        accountId: const Value(accountId),
        type: Value(billType),
        amount: Value(amount),
        categoryId: Value(category.categoryId),
        categoryName: Value(category.categoryName),
        remark: Value(result.remark),
        source: Value(result.recordSource),
        sourceHash: Value(sourceHash),
        billTime: Value(DateTime.now()),
        confirmStatus: const Value(1),
        syncStatus: const Value(0),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));

      debugPrint('自动记账成功: $result -> ${category.categoryName}');
      final typeLabel = billType == 'expense' ? '支出' : '收入';
      final tip =
          '已自动记账：$typeLabel ¥${formatMoney(result.amount)}（${category.categoryName}）';
      await _notifyAutoRecordSuccess(tip);
      notifyListeners();
    } catch (e) {
      debugPrint('自动记账创建账单失败: $e');
      await _notifyAutoRecordSuccess('自动记账失败，请稍后重试', isError: true);
    }
  }

  /// 记账成功：发系统通知；前台时额外 Toast
  Future<void> _notifyAutoRecordSuccess(
    String message, {
    bool isError = false,
  }) async {
    if (Platform.isAndroid) {
      await NotificationChannel().showLocalNotification(
        title: isError ? '自动记账失败' : '自动记账成功',
        body: message,
      );
    }
    final ctx = autoRecordNavigatorKey.currentContext;
    if (ctx == null) return;
    try {
      TopToast.show(ctx, message);
    } catch (e) {
      debugPrint('显示自动记账提示失败: $e');
    }
  }

  /// 生成 sourceHash 用于防重复（项目规则强制 sha256）
  String _generateSourceHash(String source) {
    final bytes = utf8.encode(source);
    return sha256.convert(bytes).toString();
  }

  /// 开启自动记账时顺带请求「发送通知」权限（Android 13+）
  Future<void> _ensurePostNotificationsPermission() async {
    if (!Platform.isAndroid) return;
    try {
      final channel = NotificationChannel();
      final granted = await channel.hasPostNotificationsPermission();
      if (!granted) {
        await channel.requestPostNotificationsPermission();
      }
    } catch (e) {
      debugPrint('请求发送通知权限失败: $e');
    }
  }

  /// 引导忽略电池优化（开启自动记账时）
  Future<void> ensureBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return;
    try {
      final keepAlive = KeepAliveChannel();
      _ignoringBatteryOptimizations =
          await keepAlive.isIgnoringBatteryOptimizations();
      if (!_ignoringBatteryOptimizations) {
        await keepAlive.requestIgnoreBatteryOptimizations();
        await Future.delayed(const Duration(seconds: 1));
        _ignoringBatteryOptimizations =
            await keepAlive.isIgnoringBatteryOptimizations();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('引导忽略电池优化失败: $e');
    }
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    await KeepAliveChannel().openBatteryOptimizationSettings();
    await Future.delayed(const Duration(seconds: 2));
    _ignoringBatteryOptimizations =
        await KeepAliveChannel().isIgnoringBatteryOptimizations();
    notifyListeners();
  }

  /// 设置无障碍自动记账开关
  /// 返回值：true=设置成功，false=需要授权
  Future<bool> setAccessibilityAutoRecordEnabled(bool enabled) async {
    if (enabled) {
      if (!_accessibilityPermissionGranted) {
        debugPrint('无法开启无障碍自动记账：没有无障碍权限');
        return false;
      }
      await _ensurePostNotificationsPermission();
      await ensureBatteryOptimizationIgnored();
      _accessibilityAutoRecordEnabled = true;
      await _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        accessibilityAutoRecordEnabled: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      _accessibilityAutoRecordEnabled = false;
      await _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        accessibilityAutoRecordEnabled: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
    }
    _startAutoRecordService();
    notifyListeners();
    return true;
  }

  /// 设置通知栏自动记账开关
  Future<bool> setNotificationAutoRecordEnabled(bool enabled) async {
    if (enabled) {
      if (!_notificationPermissionGranted) {
        debugPrint('无法开启通知栏自动记账：没有通知使用权');
        return false;
      }
      await _ensurePostNotificationsPermission();
      await ensureBatteryOptimizationIgnored();
      _notificationAutoRecordEnabled = true;
      await _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        notificationAutoRecordEnabled: const Value(true),
        updatedAt: Value(DateTime.now()),
      ));
    } else {
      _notificationAutoRecordEnabled = false;
      await _db.insertOrUpdateUserConfig(LocalUserConfigCompanion(
        notificationAutoRecordEnabled: const Value(false),
        updatedAt: Value(DateTime.now()),
      ));
    }
    _startAutoRecordService();
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

      if (_accessibilityAutoRecordEnabled) {
        _startAutoRecordService();
      }

      notifyListeners();
      return _accessibilityPermissionGranted;
    }
    return false;
  }

  /// 请求通知使用权（供UI调用）
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      bool granted = await NotificationChannel().isEnabled();
      debugPrint('通知使用权当前状态: $granted');

      if (granted) {
        _notificationPermissionGranted = true;
        notifyListeners();
        return true;
      }

      await NotificationChannel().openSettings();
      await Future.delayed(const Duration(seconds: 3));

      for (int i = 0; i < 3; i++) {
        granted = await NotificationChannel().isEnabled();
        debugPrint('通知使用权第${i + 1}次检查: $granted');
        if (granted) break;
        if (i < 2) await Future.delayed(const Duration(seconds: 1));
      }

      _notificationPermissionGranted = granted;
      debugPrint('通知使用权最终状态: $_notificationPermissionGranted');

      if (_notificationAutoRecordEnabled) {
        _startAutoRecordService();
      }

      notifyListeners();
      return _notificationPermissionGranted;
    }
    return false;
  }

  /// 检查所有权限状态并更新UI
  Future<void> refreshPermissions() async {
    await _checkAllPermissions();
    if (anyAutoRecordEnabled) {
      _startAutoRecordService();
    }
    notifyListeners();
  }

  /// 获取详细权限状态
  Future<Map<String, bool>> getDetailedPermissionsStatus() async {
    return {
      'accessibility': await AccessibilityChannel().isEnabled(),
      'notification': await NotificationChannel().isEnabled(),
    };
  }

  @override
  void dispose() {
    AutoRecordService.instance.dispose();
    super.dispose();
  }
}
