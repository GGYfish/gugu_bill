import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors_data.dart';
import '../theme/theme_manager.dart';
import '../ui_constants.dart';

/// 主题中心页面
class ThemeCenterPage extends StatefulWidget {
  const ThemeCenterPage({super.key});

  @override
  State<ThemeCenterPage> createState() => _ThemeCenterPageState();
}

class _ThemeCenterPageState extends State<ThemeCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题中心'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Consumer<ThemeManager>(
        builder: (context, manager, _) {
          final currentId = manager.current.id;
          final customThemes = manager.customThemes;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 顶部预览
              _buildPreviewCard(manager.current),
              const SizedBox(height: 20),

              // 内置主题
              const _SectionHeader(title: '内置主题', emoji: '🎨'),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: AppPresets.all.length,
                itemBuilder: (_, i) {
                  final t = AppPresets.all[i];
                  return _ThemeCard(
                    theme: t,
                    selected: t.id == currentId,
                    isPreset: true,
                    onTap: () => manager.applyTheme(t),
                  );
                },
              ),

              const SizedBox(height: 24),
              // 自定义主题
              Row(
                children: [
                  const _SectionHeader(title: '我的主题', emoji: '✨'),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _createCustomTheme(context, manager),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新建主题'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (customThemes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.palette_outlined,
                            size: 48, color: AppColors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          '还没有自定义主题\n点击右上角"新建主题"开始创作',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: customThemes.length,
                  itemBuilder: (_, i) {
                    final t = customThemes[i];
                    return _ThemeCard(
                      theme: t,
                      selected: t.id == currentId,
                      isPreset: false,
                      onTap: () => manager.applyTheme(t),
                      onEdit: () => _editCustomTheme(context, manager, t),
                      onDelete: () => _confirmDelete(context, manager, t),
                    );
                  },
                ),

              const SizedBox(height: 32),
              // 提示
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBlueLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '主题设置会自动保存，下次启动时自动应用。',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  /// 当前主题预览卡片
  Widget _buildPreviewCard(AppColorsData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [data.cardBlue, data.cardBlueGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: data.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(data.emoji ?? '🎨', style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('当前主题',
                        style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 颜色色板预览
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _colorDot(data.primary, '主色'),
              _colorDot(data.primaryLight, '浅主色'),
              _colorDot(data.income, '收入'),
              _colorDot(data.expense, '支出'),
              _colorDot(data.textPrimary, '文字'),
              _colorDot(data.background, '背景'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _colorDot(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }

  /// 创建自定义主题
  Future<void> _createCustomTheme(BuildContext context, ThemeManager manager) async {
    final base = manager.current;
    final draft = manager.clone(base, newName: '我的主题');
    final result = await Navigator.push<AppColorsData>(
      context,
      MaterialPageRoute(builder: (_) => ThemeEditorPage(initial: draft)),
    );
    if (result != null) {
      await manager.addCustomTheme(result);
      await manager.applyTheme(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('主题「${result.name}」已创建并应用'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  /// 编辑自定义主题
  Future<void> _editCustomTheme(BuildContext context, ThemeManager manager, AppColorsData theme) async {
    final result = await Navigator.push<AppColorsData>(
      context,
      MaterialPageRoute(builder: (_) => ThemeEditorPage(initial: theme)),
    );
    if (result != null) {
      await manager.addCustomTheme(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已保存「${result.name}」'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  /// 确认删除
  Future<void> _confirmDelete(BuildContext context, ThemeManager manager, AppColorsData theme) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除主题'),
        content: Text('确定要删除自定义主题「${theme.name}」吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await manager.removeCustomTheme(theme.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已删除「${theme.name}」')),
        );
      }
    }
  }
}

/// 主题卡片
class _ThemeCard extends StatelessWidget {
  final AppColorsData theme;
  final bool selected;
  final bool isPreset;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ThemeCard({
    required this.theme,
    required this.selected,
    required this.isPreset,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? theme.primary : AppColors.divider,
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: theme.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 顶部渐变预览
            Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.cardBlue, theme.cardBlueGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      theme.emoji ?? '🎨',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, size: 14, color: theme.primary),
                      ),
                    ),
                ],
              ),
            ),
            // 标题与色板
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _miniDot(theme.primary),
                        _miniDot(theme.primaryLight),
                        _miniDot(theme.income),
                        _miniDot(theme.expense),
                        const Spacer(),
                        if (!isPreset) ...[
                          InkWell(
                            onTap: onEdit,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.edit_outlined, size: 14, color: AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: onDelete,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Icon(Icons.delete_outline, size: 14, color: Colors.red),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniDot(Color c) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: 3),
        decoration: BoxDecoration(
          color: c,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
      );
}

/// 分区标题
class _SectionHeader extends StatelessWidget {
  final String title;
  final String emoji;
  const _SectionHeader({required this.title, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// 主题编辑器
class ThemeEditorPage extends StatefulWidget {
  final AppColorsData initial;
  const ThemeEditorPage({super.key, required this.initial});

  @override
  State<ThemeEditorPage> createState() => _ThemeEditorPageState();
}

class _ThemeEditorPageState extends State<ThemeEditorPage> {
  late TextEditingController _nameCtrl;
  late AppColorsData _draft;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initial.name);
    _draft = widget.initial;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题编辑器'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 实时预览
          _buildLivePreview(),
          const SizedBox(height: 20),

          // 主题名
          _buildLabel('主题名称', required: true),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              hintText: '给主题起个名字',
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider),
              ),
            ),
            onChanged: (v) => setState(() {
              _draft = _draft.copyWith(name: v);
            }),
          ),
          const SizedBox(height: 20),

          // 颜色编辑
          _buildLabel('颜色配置', required: true),
          const SizedBox(height: 8),
          _buildColorItem('主色', _draft.primary, (c) {
            setState(() => _draft = _draft.copyWith(primary: c, cardBlue: c));
          }),
          _buildColorItem('浅主色', _draft.primaryLight, (c) {
            setState(() => _draft = _draft.copyWith(primaryLight: c, cardBlueLight: c));
          }),
          _buildColorItem('深主色', _draft.primaryDark, (c) {
            setState(() => _draft = _draft.copyWith(primaryDark: c));
          }),
          _buildColorItem('卡片渐变结束色', _draft.cardBlueGradientEnd, (c) {
            setState(() => _draft = _draft.copyWith(cardBlueGradientEnd: c));
          }),
          _buildColorItem('背景色', _draft.background, (c) {
            setState(() => _draft = _draft.copyWith(background: c));
          }),
          _buildColorItem('表面色', _draft.surface, (c) {
            setState(() => _draft = _draft.copyWith(surface: c));
          }),
          _buildColorItem('收入色', _draft.income, (c) {
            setState(() => _draft = _draft.copyWith(income: c));
          }),
          _buildColorItem('支出色', _draft.expense, (c) {
            setState(() => _draft = _draft.copyWith(expense: c));
          }),
          _buildColorItem('主文字色', _draft.textPrimary, (c) {
            setState(() => _draft = _draft.copyWith(textPrimary: c));
          }),
          _buildColorItem('次文字色', _draft.textSecondary, (c) {
            setState(() => _draft = _draft.copyWith(textSecondary: c));
          }),
          _buildColorItem('辅文字色', _draft.textTertiary, (c) {
            setState(() => _draft = _draft.copyWith(textTertiary: c));
          }),
          _buildColorItem('分割线', _draft.divider, (c) {
            setState(() => _draft = _draft.copyWith(divider: c));
          }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
        if (required) ...[
          const SizedBox(width: 4),
          Text('*', style: TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  Widget _buildColorItem(String label, Color value, ValueChanged<Color> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          GestureDetector(
            onTap: () => _pickColor(label, value, onChanged),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: value,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '#${value.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickColor(String label, Color current, ValueChanged<Color> onChanged) async {
    Color picked = current;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text('选择$label',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  ColorPicker(
                    pickerColor: current,
                    onColorChanged: (c) {
                      picked = c;
                      setSheetState(() {});
                      onChanged(c);
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    labelTypes: const [],
                    paletteType: PaletteType.hsvWithSaturation,
                    pickerAreaHeightPercent: 0.7,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: picked,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('确定', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildLivePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_draft.cardBlue, _draft.cardBlueGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white),
              const SizedBox(width: 8),
              const Text('实时预览',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              const Spacer(),
              Text(
                _draft.name.isEmpty ? '未命名主题' : _draft.name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _previewStat('收入', '+¥5,200', _draft.income),
              const SizedBox(width: 12),
              _previewStat('支出', '-¥3,800', _draft.expense),
            ],
          ),
        ],
      ),
    );
  }

  Widget _previewStat(String label, String value, Color dotColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入主题名称'), backgroundColor: Colors.red),
      );
      return;
    }
    final result = _draft.copyWith(name: _nameCtrl.text.trim());
    Navigator.pop(context, result);
  }
}
