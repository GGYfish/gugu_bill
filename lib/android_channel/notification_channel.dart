import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/money.dart';

/// 通知栏支付数据
class NotificationPaymentData {
  final String appName;
  final Decimal amount;
  final String detail;
  final int timestamp;
  final String source;
  final String packageName;
  final bool isIncome;

  NotificationPaymentData({
    required this.appName,
    required this.amount,
    required this.detail,
    required this.timestamp,
    required this.source,
    required this.packageName,
    required this.isIncome,
  });

  factory NotificationPaymentData.fromMap(Map<dynamic, dynamic> map) {
    return NotificationPaymentData(
      appName: map['appName']?.toString() ?? '',
      amount: asDecimal(map['amount']),
      detail: map['detail']?.toString() ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      source: map['source']?.toString() ?? 'notification',
      packageName: map['packageName']?.toString() ?? '',
      isIncome: map['isIncome'] == true,
    );
  }
}

/// 通知栏监听通信通道
class NotificationChannel {
  static const _methodChannel = MethodChannel('com.aijizhang/notification');
  static const _eventChannel = EventChannel('com.aijizhang/notification_event');

  static final NotificationChannel _instance = NotificationChannel._internal();
  factory NotificationChannel() => _instance;
  NotificationChannel._internal();

  final _paymentController =
      StreamController<NotificationPaymentData>.broadcast();

  Stream<NotificationPaymentData> get paymentStream =>
      _paymentController.stream;

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          _paymentController.add(NotificationPaymentData.fromMap(event));
        }
      },
      onError: (error) {
        debugPrint('Notification EventChannel error: $error');
      },
    );
  }

  /// 是否已授权通知使用权（通知监听服务）
  Future<bool> isEnabled() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('isNotificationListenerEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('检查通知监听权限失败: $e');
      return false;
    }
  }

  /// 打开系统「通知使用权」设置页
  Future<bool> openSettings() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('openNotificationListenerSettings');
      return result ?? false;
    } catch (e) {
      debugPrint('打开通知监听设置失败: $e');
      return false;
    }
  }

  /// 是否已有「发送通知」权限（Android 13+）
  Future<bool> hasPostNotificationsPermission() async {
    try {
      final result = await _methodChannel
          .invokeMethod<bool>('hasPostNotificationsPermission');
      return result ?? true;
    } catch (e) {
      debugPrint('检查发送通知权限失败: $e');
      return true;
    }
  }

  /// 请求「发送通知」权限（Android 13+）
  Future<bool> requestPostNotificationsPermission() async {
    try {
      final result = await _methodChannel
          .invokeMethod<bool>('requestPostNotificationsPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('请求发送通知权限失败: $e');
      return false;
    }
  }

  /// 发送本地通知（记账成功等）
  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _methodChannel.invokeMethod('showLocalNotification', {
        'title': title,
        'body': body,
      });
    } catch (e) {
      debugPrint('发送本地通知失败: $e');
    }
  }

  void dispose() {
    _paymentController.close();
  }
}
