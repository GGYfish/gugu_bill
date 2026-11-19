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
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => _SubCategoryNameDialog(
      title: '添加小分类',
      subtitle: '为「$parentName」新增',
      confirmLabel: '确认添加',
      parentIcon: parentIcon,
      parentColor: parentColor,
    ),
  );

  if (name == null || name.isEmpty) return;
  if (!context.mounted) return;

  // 先关弹窗再写库，避免 notifyListeners 重建列表时弹窗还在树里导致 InheritedWidget 断言
  await context.read<CategoryManagementProvider>().addSubCategory(
        parentId: parentId,
        name: name,
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已添加小分类：$name')),
  );
}

/// 编辑小分类名称对话框
Future<void> showEditSubCategoryDialog(
  BuildContext context, {
  required String categoryId,
  required String initialName,
  required String parentName,
  required IconData parentIcon,
  required Color parentColor,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (ctx) => _SubCategoryNameDialog(
      title: '编辑小分类',
      subtitle: '所属「$parentName」',
      confirmLabel: '保存修改',
      initialName: initialName,
      parentIcon: parentIcon,
      parentColor: parentColor,
    ),
  );

  if (name == null || name.isEmpty) return;
  if (!context.mounted) return;

  await context.read<CategoryManagementProvider>().updateCategory(
        categoryId,
        name: name,
      );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('已更新小分类：$name')),
  );
}

/// 小分类名称输入弹窗（Stateful，正确管理 TextEditingController 生命周期）
class _SubCategoryNameDialog extends StatefulWidget {
  final String title;
  final String subtitle;
  final String confirmLabel;
  final String? initialName;
  final IconData parentIcon;
  final Color parentColor;

  const _SubCategoryNameDialog({
    required this.title,
    required this.subtitle,
    required this.confirmLabel,
    required this.parentIcon,
    required this.parentColor,
    this.initialName,
  });

  @override
  State<_SubCategoryNameDialog> createState() => _SubCategoryNameDialogState();
}

class _SubCategoryNameDialogState extends State<_SubCategoryNameDialog> {
  late final TextEditingController _nameCtrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _confirm() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // 只把名称带回，写库在弹窗外执行
    Navigator.of(context).pop(_nameCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              color: widget.parentColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.parentIcon,
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
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
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
        key: _formKey,
        child: TextFormField(
          controller: _nameCtrl,
          autofocus: widget.initialName != null,
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
          onFieldSubmitted: (_) => _confirm(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('取消', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
