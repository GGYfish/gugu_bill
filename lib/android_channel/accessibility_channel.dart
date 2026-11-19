import 'dart:async';
import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/money.dart';

/// 无障碍捕获的支付数据
class AccessibilityPaymentData {
  final String appName;
  final Decimal amount;
  final String detail;
  final int timestamp;
  final String source;
  final String packageName;
  final bool isIncome;

  AccessibilityPaymentData({
    required this.appName,
    required this.amount,
    required this.detail,
    required this.timestamp,
    required this.source,
    required this.packageName,
    required this.isIncome,
  });

  factory AccessibilityPaymentData.fromMap(Map<dynamic, dynamic> map) {
    return AccessibilityPaymentData(
      appName: map['appName']?.toString() ?? '',
      amount: asDecimal(map['amount']),
      detail: map['detail']?.toString() ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      source: map['source']?.toString() ?? 'accessibility',
      packageName: map['packageName']?.toString() ?? '',
      isIncome: map['isIncome'] == true,
    );
  }
}

/// 无障碍服务状态
class AccessibilityServiceState {
  final bool isEnabled;
  final bool isRunning;
  final String serviceName;

  AccessibilityServiceState({
    required this.isEnabled,
    required this.isRunning,
    required this.serviceName,
  });

  factory AccessibilityServiceState.fromMap(Map<dynamic, dynamic> map) {
    return AccessibilityServiceState(
      isEnabled: map['isEnabled'] == true,
      isRunning: map['isRunning'] == true,
      serviceName: map['serviceName']?.toString() ?? '',
    );
  }
}

/// 无障碍通信：MethodChannel（权限）+ EventChannel（支付事件）
class AccessibilityChannel {
  static const _methodChannel = MethodChannel('com.aijizhang/accessibility');
  static const _eventChannel = EventChannel('com.aijizhang/accessibility_event');

  static final AccessibilityChannel _instance = AccessibilityChannel._internal();
  factory AccessibilityChannel() => _instance;
  AccessibilityChannel._internal();

  final _paymentController =
      StreamController<AccessibilityPaymentData>.broadcast();

  Stream<AccessibilityPaymentData> get paymentStream =>
      _paymentController.stream;

  bool _isInitialized = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          _paymentController.add(AccessibilityPaymentData.fromMap(event));
        }
      },
      onError: (error) {
        debugPrint('Accessibility EventChannel error: $error');
      },
    );
  }

  Future<bool> isEnabled() async {
    try {
      final result = await _methodChannel
          .invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('检查无障碍服务状态失败: $e');
      return false;
    }
  }

  Future<AccessibilityServiceState> getServiceState() async {
    try {
      final result = await _methodChannel
          .invokeMethod<Map>('getAccessibilityServiceState');
      if (result != null) {
        return AccessibilityServiceState.fromMap(result);
      }
    } catch (e) {
      debugPrint('获取无障碍服务状态失败: $e');
    }
    return AccessibilityServiceState(
      isEnabled: false,
      isRunning: false,
      serviceName: '',
    );
  }

  Future<bool> openSettings() async {
    try {
      final result =
          await _methodChannel.invokeMethod<bool>('openAccessibilitySettings');
      return result ?? false;
    } catch (e) {
      debugPrint('打开无障碍设置失败: $e');
      return false;
    }
  }

  void dispose() {
    _paymentController.close();
  }
}
