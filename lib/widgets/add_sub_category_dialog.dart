import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/resource_provider.dart';
import '../ui_constants.dart';

/// 弹出"添加小分类"对话框：只需要输入名字。
/// 子分类的 icon / color / type 自动从父分类继承（provider 内部实现）。
///
/// - [parentId]：父分类 ID（用于写入数据库）
/// - [parentName]：父分类名称（用于展示标题）
/// - [parentIcon]：父分类图标（用于展示标题）
/// - [parentColor]：父分类颜色（用于展示标题）
Future<void> showAddSubCategoryDialog(
  BuildContext context, {
  required String parentId,
  required String parentName,
  required IconData parentIcon,
  required Color parentColor,
}) async {
  final nameCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  void doConfirm(BuildContext ctx) {
    if (!(formKey.currentState?.validate() ?? false)) return;
    Provider.of<CategoryManagementProvider>(ctx, listen: false)
        .addSubCategory(
      parentId: parentId,
      name: nameCtrl.text.trim(),
    );
    Navigator.of(ctx).pop(true);
  }

  final added = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: parentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              parentIcon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '添加小分类',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '为「$parentName」新增',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: nameCtrl,
          autofocus: false,
          maxLength: 8,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: '小分类名称',
            hintText: '例如：早餐 / 饮料 / 话费',
            filled: true,
            fillColor: AppColors.background,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return '请输入小分类名称';
            return null;
          },
          onFieldSubmitted: (_) => doConfirm(ctx),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () => doConfirm(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('确认添加'),
        ),
      ],
    ),
  );

  if (added == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已添加小分类：${nameCtrl.text.trim()}')),
    );
  }
  nameCtrl.dispose();
}
