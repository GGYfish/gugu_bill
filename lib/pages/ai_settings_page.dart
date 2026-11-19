import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../providers/app_provider.dart';
import '../services/deepseek_config.dart';
import '../ui_constants.dart';

/// AI 设置：当前仅对接 DeepSeek，模型固定，只配置 API Key
class AiSettingsPage extends StatefulWidget {
  const AiSettingsPage({super.key});

  @override
  State<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends State<AiSettingsPage> {
  final _apiKeyController = TextEditingController();

  bool _enabled = false;
  bool _obscureKey = true;
  bool _loading = true;
  bool _saving = false;
  String _personalityId = AiPersonality.defaultId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final db = context.read<AppProvider>().db;
    final config = await db.getUserConfig();
    if (!mounted) return;
    setState(() {
      _enabled = config?.aiEnabled ?? false;
      _apiKeyController.text = config?.aiApiKey ?? '';
      _personalityId = AiPersonality.byId(config?.aiPersonality).id;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final db = context.read<AppProvider>().db;
      await db.insertOrUpdateUserConfig(
        LocalUserConfigCompanion(
          aiEnabled: Value(_enabled),
          aiBaseUrl: const Value(DeepSeekDefaults.baseUrl),
          aiApiKey: Value(_apiKeyController.text.trim()),
          aiModel: const Value(DeepSeekDefaults.model),
          aiPersonality: Value(_personalityId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败：$e')),
      );
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI 设置'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saving || _loading ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _card(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '启用 AI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '关闭后咕咕鱼 AI 相关功能不可用',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    value: _enabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                ),
                const SizedBox(height: 16),
                _fieldLabel('性格'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AiPersonality.all.map((p) {
                    final selected = p.id == _personalityId;
                    return ChoiceChip(
                      label: Text(p.label),
                      selected: selected,
                      onSelected: (_) => setState(() => _personalityId = p.id),
                      selectedColor: AppColors.primary.withValues(alpha: 0.18),
                      labelStyle: TextStyle(
                        fontSize: 13,
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.divider,
                      ),
                      backgroundColor: AppColors.surface,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 6),
                Text(
                  AiPersonality.byId(_personalityId).hint,
                  style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 16),
                _infoCard(),
                const SizedBox(height: 20),
                _fieldLabel('API Key'),
                const SizedBox(height: 6),
                TextField(
                  controller: _apiKeyController,
                  obscureText: _obscureKey,
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: '请输入 DeepSeek API Key',
                    hintStyle: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                    filled: true,
                    fillColor: AppColors.surface,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                        color: AppColors.textTertiary,
                      ),
                      onPressed: () => setState(() => _obscureKey = !_obscureKey),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Key 仅保存在本机，不会上传。可在 DeepSeek 开放平台申请。',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('保存设置'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'DeepSeek（OpenAI 兼容）',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _kv('Base URL', DeepSeekDefaults.baseUrl),
          const SizedBox(height: 8),
          _kv('Model', DeepSeekDefaults.model),
          const SizedBox(height: 8),
          _kv('接口', '${DeepSeekDefaults.baseUrl}/chat/completions'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            k,
            style: TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ),
        Expanded(
          child: Text(
            v,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }
}
