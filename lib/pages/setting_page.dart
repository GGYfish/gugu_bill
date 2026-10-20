import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/backup_service.dart';
import '../ui_constants.dart';
import 'resource_management_page.dart';
import 'theme_center_page.dart';

/// 设置页面
class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Consumer<AppProvider>(
        builder: (context, app, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== 自动记账 =====
              _SectionTitle(title: '自动记账'),
              const SizedBox(height: 8),
              // 通知栏自动记账（已禁用）
              _AutoRecordSwitch(
                app: app,
                title: '通知栏自动记账',
                subtitle: '功能已移除',
                icon: Icons.notifications_active,
                iconColor: Colors.grey,
                enabled: false,
                hasPermission: false,
                onToggle: (_) {},
                onRequestPermission: () {},
              ),
              const SizedBox(height: 12),
              // 无障碍自动记账
              _AutoRecordSwitch(
                app: app,
                title: '无障碍自动记账',
                subtitle: app.accessibilityPermissionGranted
                    ? '读取屏幕内容获取支付信息（更全面）'
                    : '需要无障碍服务权限',
                icon: Icons.accessibility_new,
                iconColor: AppColors.primary,
                enabled: app.accessibilityAutoRecordEnabled,
                hasPermission: app.accessibilityPermissionGranted,
                onToggle: (v) => _onAccessibilityToggle(context, app, v),
                onRequestPermission: () => app.requestAccessibilityPermission(),
              ),

              const SizedBox(height: 24),

              // ===== 资源管理 =====
              _SectionTitle(title: '资源管理'),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.category,
                iconColor: AppColors.primary,
                title: '分类管理',
                subtitle: '支出/收入分类设置',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResourceManagementPage(type: 'category'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.account_balance,
                iconColor: AppColors.primary,
                title: '银行机构',
                subtitle: '管理常用银行',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResourceManagementPage(type: 'bank'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.payments,
                iconColor: AppColors.primary,
                title: '信贷机构',
                subtitle: '管理借贷机构',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ResourceManagementPage(type: 'credit'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.palette,
                iconColor: AppColors.primary,
                title: '主题中心',
                subtitle: '切换和自定义界面主题',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ThemeCenterPage()),
                ),
              ),

              const SizedBox(height: 24),

              // ===== 数据管理 =====
              _SectionTitle(title: '数据管理'),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.file_upload_outlined,
                iconColor: AppColors.primary,
                title: '导出数据',
                subtitle: '备份账单 / 负债 / 账户 / 分类到 JSON 文件',
                onTap: () => _onExport(context, app),
              ),
              const SizedBox(height: 8),
              _ManagementTile(
                icon: Icons.file_download_outlined,
                iconColor: AppColors.primary,
                title: '导入数据',
                subtitle: '从 JSON 备份文件恢复（将覆盖当前数据）',
                onTap: () => _onImport(context, app),
              ),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onAccessibilityToggle(
    BuildContext context,
    AppProvider app,
    bool v,
  ) async {
    if (v) {
      if (!app.accessibilityPermissionGranted) {
        final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('需要无障碍服务权限'),
            content: const Text(
              '无障碍自动记账需要您开启无障碍服务。\n\n'
              '请在设置中开启「无障碍服务」并授权本应用。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('暂不开启'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('去开启'),
              ),
            ],
          ),
        );
        if (result == true) {
          await app.requestAccessibilityPermission();
        }
        return;
      }
      await app.setAccessibilityAutoRecordEnabled(true);
    } else {
      await app.setAccessibilityAutoRecordEnabled(false);
    }
  }

  // ============================================================
  // 导出数据
  // ============================================================
  Future<void> _onExport(BuildContext context, AppProvider app) async {
    // 弹出确认
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导出数据'),
        content: const Text(
          '将全部账单、负债、账户、分类、机构导出为 JSON 备份文件。\n\n'
          '导出的文件可用于迁移到其他设备或长期保存。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('开始导出'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    // 显示加载框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = BackupService(app.db);
      final file = await service.exportToFile();
      if (!context.mounted) return;
      Navigator.pop(context); // 关掉加载框

      final fileName = file.path.split(Platform.pathSeparator).last;
      _showSnack(context, '已保存到 Download 文件夹：$fileName');
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // 关掉加载框
      _showSnack(context, '导出失败：$e', isError: true);
    }
  }

  // ============================================================
  // 导入数据
  // ============================================================
  Future<void> _onImport(BuildContext context, AppProvider app) async {
    // 第一次确认：警告会覆盖当前数据
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入数据'),
        content: const Text(
          '从 JSON 备份文件恢复数据。\n\n'
          '⚠️ 导入会清空当前的账单、负债、账户、分类、机构，并替换为备份文件中的内容。\n\n'
          '建议先导出一份当前数据作为兜底。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('继续选择文件'),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    // 弹出系统文件选择器，仅允许 JSON
    FilePickerResult? picked;
    try {
      picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: false,
      );
    } catch (e) {
      _showSnack(context, '打开文件选择器失败：$e', isError: true);
      return;
    }
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null) {
      _showSnack(context, '选择的文件无效', isError: true);
      return;
    }

    if (!context.mounted) return;
    // 第二次确认：显示要导入的文件名
    final filename = picked.files.single.name;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认导入'),
        content: Text('即将导入备份文件：\n\n$filename\n\n该操作不可撤销，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('确认导入'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;

    // 显示加载框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = BackupService(app.db);
      final stats = await service.importFromFile(File(path));
      if (!context.mounted) return;
      Navigator.pop(context); // 关掉加载框
      // 通知 AppProvider 刷新（虽然 watch 流会自动触发，这里保险）
      app.notifyDataChanged();
      _showSnack(
        context,
        '导入完成，共恢复 ${stats.total} 条数据\n'
        '账单 ${stats.bills} · 负债 ${stats.liabilities} · 还款 ${stats.liabilityRepays}\n'
        '账户 ${stats.accounts} · 分类 ${stats.categories} · 银行 ${stats.banks} · 信贷 ${stats.creditInstitutions}',
      );
    } on FormatException catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnack(context, '导入失败：${e.message}', isError: true);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      _showSnack(context, '导入失败：$e', isError: true);
    }
  }

  void _showSnack(BuildContext context, String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? AppColors.expense : null,
        duration: Duration(seconds: isError ? 4 : 3),
      ),
    );
  }
}

// ============================================================
// 公共组件
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// 自动记账开关卡片
class _AutoRecordSwitch extends StatelessWidget {
  final AppProvider app;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final bool hasPermission;
  final ValueChanged<bool> onToggle;
  final VoidCallback onRequestPermission;

  const _AutoRecordSwitch({
    required this.app,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.enabled,
    required this.hasPermission,
    required this.onToggle,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: enabled
            ? iconColor.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled
              ? iconColor.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled ? iconColor : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!hasPermission && enabled == false)
            TextButton(
              onPressed: onRequestPermission,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
              ),
              child: const Text('授权', style: TextStyle(fontSize: 13)),
            ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeTrackColor: iconColor.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }
}

/// 管理入口卡片
class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
