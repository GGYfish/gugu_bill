import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'accessibility_channel.dart';

/// 全局导航键，用于从服务层显示对话框
final GlobalKey<NavigatorState> autoRecordNavigatorKey = GlobalKey<NavigatorState>();

/// 自动记账服务
/// 仅监听无障碍服务，自动创建账单（需用户确认）
/// 注意：通知栏监听功能已移除
class AutoRecordService {
  static AutoRecordService? _instance;
  static AutoRecordService get instance => _instance ??= AutoRecordService._();

  AutoRecordService._();

  final _accessibilityChannel = AccessibilityChannel();

  StreamSubscription? _accessibilitySubscription;

  /// 账单创建成功回调
  void Function(BillParseResult result)? onBillCreated;

  /// 是否正在运行
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  /// 已处理的无障碍支付ID集合，用于去重
  final Set<String> _processedAccessibilityPayments = {};

  /// 启动服务
  Future<void> start() async {
    if (_isRunning) {
      debugPrint('⚠️ 自动记账服务已经在运行中');
      return;
    }

    // 非Android平台不支持
    if (!Platform.isAndroid) {
      debugPrint('⚠️ 自动记账服务仅支持Android平台');
      return;
    }

    debugPrint('========== 启动自动记账服务 ==========');
    debugPrint('   监听模式: 仅无障碍服务（通知栏监听已关闭）');

    // 初始化无障碍服务
    debugPrint('♿ 初始化无障碍服务...');
    _accessibilityChannel.initialize();

    // 订阅无障碍支付事件
    debugPrint('📡 订阅无障碍支付流...');
    _accessibilitySubscription = _accessibilityChannel.paymentStream.listen(
      _onAccessibilityPayment,
      onError: (e) => debugPrint('❌ 无障碍支付流错误: $e'),
    );

    _isRunning = true;
    debugPrint('✅ 自动记账服务已启动完成！');
    debugPrint('   监听模式: 仅无障碍服务');
    debugPrint('=====================================');
  }

  /// 停止服务
  void stop() {
    _accessibilitySubscription?.cancel();
    _accessibilitySubscription = null;
    _isRunning = false;
    _processedAccessibilityPayments.clear();
    
    debugPrint('自动记账服务已停止');
  }
  
  /// 处理无障碍服务捕获的支付
  Future<void> _onAccessibilityPayment(AccessibilityPaymentData data) async {
    debugPrint('收到无障碍支付事件: app=${data.appName}, amount=${data.amount}, detail=${data.detail}');

    if (!_isRunning) {
      debugPrint('支付被忽略：服务未运行');
      return;
    }

    // 去重
    final paymentId = '${data.appName}_${data.amount}_${data.timestamp}';
    if (_processedAccessibilityPayments.contains(paymentId)) {
      debugPrint('支付被忽略：已处理过');
      return;
    }
    _processedAccessibilityPayments.add(paymentId);

    // 限制缓存大小
    if (_processedAccessibilityPayments.length > 100) {
      _processedAccessibilityPayments.clear();
    }

    // 转换为BillParseResult
    final result = BillParseResult(
      type: BillType.expense,
      amount: data.amount,
      source: data.appName,
      remark: data.detail,
    );

    // 显示确认对话框
    await _showAccessibilityConfirmDialog(result, data);
  }
  
  /// 显示无障碍服务支付确认对话框
  Future<void> _showAccessibilityConfirmDialog(BillParseResult result, AccessibilityPaymentData data) async {
    try {
      final context = autoRecordNavigatorKey.currentContext;
      if (context == null) {
        debugPrint('无法获取导航上下文，自动记账对话框无法显示');
        onBillCreated?.call(result);
        return;
      }

      debugPrint('显示无障碍支付确认对话框...');
      await Navigator.of(context).push(
        DialogRoute(
          context: context,
          builder: (ctx) => _AccessibilityConfirmDialog(
            result: result,
            data: data,
            onConfirm: () {
              debugPrint('用户确认记账（无障碍）');
              onBillCreated?.call(result);
              Navigator.of(ctx).pop(true);
            },
            onCancel: () {
              debugPrint('用户取消记账（无障碍）');
              Navigator.of(ctx).pop(false);
            },
          ),
        ),
      );
    } catch (e, stack) {
      debugPrint('显示确认对话框失败: $e\n$stack');
      onBillCreated?.call(result);
    }
  }

  /// 检查无障碍服务是否启用
  Future<bool> isAccessibilityEnabled() async {
    if (!Platform.isAndroid) return false;
    return await _accessibilityChannel.isEnabled();
  }

  /// 检查无障碍服务运行状态
  Future<AccessibilityServiceState> getAccessibilityServiceState() async {
    return await _accessibilityChannel.getServiceState();
  }

  /// 打开无障碍服务设置页面
  Future<void> openAccessibilitySettings() async {
    if (!Platform.isAndroid) return;
    await _accessibilityChannel.openSettings();
  }

  /// 获取所有需要的权限状态
  Future<Map<String, bool>> getAllPermissionsStatus() async {
    final accessibilityEnabled = await isAccessibilityEnabled();
    return {
      'accessibility': accessibilityEnabled,
      'notification': false, // 通知栏监听已关闭
    };
  }

  void dispose() {
    stop();
  }
}

/// 无障碍服务支付确认对话框
class _AccessibilityConfirmDialog extends StatelessWidget {
  final BillParseResult result;
  final AccessibilityPaymentData data;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _AccessibilityConfirmDialog({
    required this.result,
    required this.data,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final typeText = result.type == BillType.expense ? '支出' : '收入';
    final typeColor = result.type == BillType.expense ? Colors.red : Colors.green;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.accessibility_new, color: Colors.blue[700]),
          const SizedBox(width: 8),
          const Text('自动记账'),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '无障碍',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('检测到 ${data.appName} 支付页面'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('类型'),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        typeText,
                        style: TextStyle(color: typeColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('金额'),
                    Text(
                      '¥${result.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: typeColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('来源'),
                    Text(result.source),
                  ],
                ),
                if (result.remark.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('详情'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          result.remark,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('忽略'),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('确认记账'),
        ),
      ],
    );
  }
}

/// 账单类型
enum BillType { expense, income, transfer }

/// 解析结果
class BillParseResult {
  final BillType type;
  final double amount;
  final String source;
  final String remark;

  BillParseResult({
    required this.type,
    required this.amount,
    required this.source,
    required this.remark,
  });

  @override
  String toString() => 'BillParseResult(type: $type, amount: $amount, source: $source, remark: $remark)';
}
