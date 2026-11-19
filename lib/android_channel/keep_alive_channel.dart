import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 保活 / 电池优化 / 原生开关同步
class KeepAliveChannel {
  static const _channel = MethodChannel('com.aijizhang/keepalive');

  static final KeepAliveChannel _instance = KeepAliveChannel._internal();
  factory KeepAliveChannel() => _instance;
  KeepAliveChannel._internal();

  /// 同步开关到原生 SharedPreferences（开机广播用）
  Future<void> syncAutoRecordFlags({
    required bool notification,
    required bool accessibility,
  }) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('syncAutoRecordFlags', {
        'notification': notification,
        'accessibility': accessibility,
      });
    } catch (e) {
      debugPrint('同步自动记账开关失败: $e');
    }
  }

  /// 启动前台保活服务
  Future<void> startKeepAlive() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('startKeepAlive');
    } catch (e) {
      debugPrint('启动保活失败: $e');
    }
  }

  /// 停止前台保活服务
  Future<void> stopKeepAlive() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('stopKeepAlive');
    } catch (e) {
      debugPrint('停止保活失败: $e');
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final r =
          await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return r ?? false;
    } catch (e) {
      debugPrint('检查电池优化失败: $e');
      return false;
    }
  }

  /// 弹出系统「忽略电池优化」请求框
  Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return false;
    try {
      final r = await _channel
          .invokeMethod<bool>('requestIgnoreBatteryOptimizations');
      return r ?? false;
    } catch (e) {
      debugPrint('请求忽略电池优化失败: $e');
      return false;
    }
  }

  /// 打开电池优化设置列表页（部分机型更稳）
  Future<bool> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return false;
    try {
      final r =
          await _channel.invokeMethod<bool>('openBatteryOptimizationSettings');
      return r ?? false;
    } catch (e) {
      debugPrint('打开电池优化设置失败: $e');
      return false;
    }
  }
}
