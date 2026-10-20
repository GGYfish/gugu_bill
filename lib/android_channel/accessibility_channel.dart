import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 无障碍服务数据模型
class AccessibilityPaymentData {
  final String appName;
  final double amount;
  final String detail;
  final int timestamp;
  final String source;

  AccessibilityPaymentData({
    required this.appName,
    required this.amount,
    required this.detail,
    required this.timestamp,
    required this.source,
  });

  factory AccessibilityPaymentData.fromMap(Map<dynamic, dynamic> map) {
    return AccessibilityPaymentData(
      appName: map['appName']?.toString() ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      detail: map['detail']?.toString() ?? '',
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      source: map['source']?.toString() ?? 'accessibility',
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
      isEnabled: map['isEnabled'] ?? false,
      isRunning: map['isRunning'] ?? false,
      serviceName: map['serviceName']?.toString() ?? '',
    );
  }
}

/// 无障碍服务通信通道
class AccessibilityChannel {
  static const _methodChannel = MethodChannel('com.aijizhang/accessibility');
  static const _eventChannel = EventChannel('com.aijizhang/accessibility_event');

  // 单例
  static final AccessibilityChannel _instance = AccessibilityChannel._internal();
  factory AccessibilityChannel() => _instance;
  AccessibilityChannel._internal();

  // Stream控制器
  final _paymentController = StreamController<AccessibilityPaymentData>.broadcast();
  final _serviceStateController = StreamController<bool>.broadcast();

  /// 支付事件流
  Stream<AccessibilityPaymentData> get paymentStream => _paymentController.stream;

  /// 服务状态流
  Stream<bool> get serviceStateStream => _serviceStateController.stream;

  /// 当前支付数据（用于弹窗确认）
  AccessibilityPaymentData? _lastPaymentData;
  AccessibilityPaymentData? get lastPaymentData => _lastPaymentData;

  bool _isInitialized = false;

  /// 初始化
  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;

    // 监听支付事件
    _eventChannel.receiveBroadcastStream().listen(
      (event) {
        if (event is Map) {
          final data = AccessibilityPaymentData.fromMap(event);
          _lastPaymentData = data;
          _paymentController.add(data);
        }
      },
      onError: (error) {
        debugPrint('Accessibility EventChannel error: $error');
      },
    );

    // 监听方法调用
    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onServiceStateChanged':
          final isRunning = call.arguments['isRunning'] ?? false;
          _serviceStateController.add(isRunning);
          break;
      }
    });
  }

  /// 检查无障碍服务是否启用
  Future<bool> isEnabled() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return result ?? false;
    } catch (e) {
      debugPrint('检查无障碍服务状态失败: $e');
      return false;
    }
  }

  /// 获取服务状态
  Future<AccessibilityServiceState> getServiceState() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>('getAccessibilityServiceState');
      if (result != null) {
        return AccessibilityServiceState.fromMap(result);
      }
    } catch (e) {
      debugPrint('获取服务状态失败: $e');
    }
    return AccessibilityServiceState(
      isEnabled: false,
      isRunning: false,
      serviceName: 'com.example.demo_app/.BillAccessibilityService',
    );
  }

  /// 打开无障碍设置页面
  Future<bool> openSettings() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('openAccessibilitySettings');
      return result ?? false;
    } catch (e) {
      debugPrint('打开无障碍设置失败: $e');
      return false;
    }
  }

  /// 清除最后一条支付数据
  void clearLastPaymentData() {
    _lastPaymentData = null;
  }

  /// 释放资源
  void dispose() {
    _paymentController.close();
    _serviceStateController.close();
  }
}
