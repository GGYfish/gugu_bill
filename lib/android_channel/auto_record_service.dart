import 'dart:async';
import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'accessibility_channel.dart';
import 'notification_channel.dart';

/// 全局导航键，用于从服务层显示提示
final GlobalKey<NavigatorState> autoRecordNavigatorKey =
    GlobalKey<NavigatorState>();

/// 自动记账服务：无障碍 + 通知栏；入账防重复在 AppProvider / 原生短时去重
class AutoRecordService {
  static AutoRecordService? _instance;
  static AutoRecordService get instance => _instance ??= AutoRecordService._();

  AutoRecordService._();

  final _accessibilityChannel = AccessibilityChannel();
  final _notificationChannel = NotificationChannel();

  StreamSubscription? _accessibilitySubscription;
  StreamSubscription? _notificationSubscription;

  Future<void> Function(BillParseResult result)? onBillCreated;

  bool listenAccessibility = false;
  bool listenNotification = false;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> start({
    bool accessibility = false,
    bool notification = false,
  }) async {
    if (!Platform.isAndroid) {
      debugPrint('⚠️ 自动记账服务仅支持Android平台');
      return;
    }

    listenAccessibility = accessibility;
    listenNotification = notification;

    if (!listenAccessibility && !listenNotification) {
      stop();
      return;
    }

    if (_isRunning) {
      debugPrint(
        '自动记账服务已在运行 a=$listenAccessibility n=$listenNotification',
      );
      return;
    }

    debugPrint('========== 启动自动记账服务 ==========');
    debugPrint('   无障碍: $listenAccessibility  通知栏: $listenNotification');

    if (listenAccessibility) {
      _accessibilityChannel.initialize();
      _accessibilitySubscription = _accessibilityChannel.paymentStream.listen(
        _onAccessibilityPayment,
        onError: (e) => debugPrint('❌ 无障碍支付流错误: $e'),
      );
    }

    if (listenNotification) {
      _notificationChannel.initialize();
      _notificationSubscription = _notificationChannel.paymentStream.listen(
        _onNotificationPayment,
        onError: (e) => debugPrint('❌ 通知支付流错误: $e'),
      );
    }

    _isRunning = true;
    debugPrint('✅ 自动记账服务已启动');
  }

  Future<void> updateModes({
    required bool accessibility,
    required bool notification,
  }) async {
    if (!accessibility && !notification) {
      stop();
      return;
    }

    final needRestart = !_isRunning ||
        accessibility != listenAccessibility ||
        notification != listenNotification;
    if (needRestart) {
      stop();
      await start(accessibility: accessibility, notification: notification);
    }
  }

  void stop() {
    _accessibilitySubscription?.cancel();
    _accessibilitySubscription = null;
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _isRunning = false;
    listenAccessibility = false;
    listenNotification = false;
    debugPrint('自动记账服务已停止');
  }

  Future<void> _onAccessibilityPayment(AccessibilityPaymentData data) async {
    if (!_isRunning || !listenAccessibility) return;
    debugPrint(
      '收到无障碍支付: app=${data.appName}, amount=${data.amount}, income=${data.isIncome}',
    );
    await _commit(
      BillParseResult(
        type: data.isIncome ? BillType.income : BillType.expense,
        amount: data.amount,
        source: _normalizeSource(data.appName),
        remark: data.detail,
        recordSource: 'accessibility',
      ),
    );
  }

  Future<void> _onNotificationPayment(NotificationPaymentData data) async {
    if (!_isRunning || !listenNotification) return;
    debugPrint(
      '收到通知支付: app=${data.appName}, amount=${data.amount}, income=${data.isIncome}',
    );
    await _commit(
      BillParseResult(
        type: data.isIncome ? BillType.income : BillType.expense,
        amount: data.amount,
        source: _normalizeSource(data.appName),
        remark: data.detail,
        recordSource: 'notification',
      ),
    );
  }

  String _normalizeSource(String name) {
    if (name.contains('微信')) return '微信';
    if (name.contains('支付宝')) return '支付宝';
    if (name.contains('云闪付')) return '云闪付';
    if (name.contains('京东')) return '京东';
    if (name.contains('拼多多')) return '拼多多';
    if (name.contains('美团')) return '美团';
    if (name.contains('饿了么')) return '饿了么';
    if (name.contains('淘宝')) return '淘宝';
    if (name.contains('滴滴')) return '滴滴出行';
    return name;
  }

  Future<void> _commit(BillParseResult result) async {
    try {
      final cb = onBillCreated;
      if (cb == null) {
        debugPrint('自动记账回调未设置');
        return;
      }
      await cb(result);
    } catch (e, stack) {
      debugPrint('自动记账提交失败: $e\n$stack');
    }
  }

  Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) return false;
    return await _accessibilityChannel.isEnabled();
  }

  Future<bool> isNotificationEnabled() async {
    if (!Platform.isAndroid) return false;
    return await _notificationChannel.isEnabled();
  }

  Future<AccessibilityServiceState> getAccessibilityServiceState() async {
    return await _accessibilityChannel.getServiceState();
  }

  Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    await _accessibilityChannel.openSettings();
  }

  Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;
    await _notificationChannel.openSettings();
  }

  Future<Map<String, bool>> getAllPermissionsStatus() async {
    return {
      'accessibility': await isAccessibilityEnabled(),
      'notification': await isNotificationEnabled(),
    };
  }

  void dispose() {
    stop();
  }
}

enum BillType { expense, income, transfer }

class BillParseResult {
  final BillType type;
  final Decimal amount;
  final String source;
  final String remark;
  final String recordSource;

  BillParseResult({
    required this.type,
    required this.amount,
    required this.source,
    required this.remark,
    this.recordSource = 'accessibility',
  });

  @override
  String toString() =>
      'BillParseResult(type: $type, amount: $amount, source: $source, remark: $remark, recordSource: $recordSource)';
}
