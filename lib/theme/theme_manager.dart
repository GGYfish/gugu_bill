import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors_data.dart';

/// 主题管理器：负责加载/保存/切换主题
class ThemeManager extends ChangeNotifier {
  static final ThemeManager instance = ThemeManager._internal();

  factory ThemeManager() => instance;

  ThemeManager._internal();

  /// 持久化 key
  static const String _kPrefsKey = 'app_theme_manager_v1';

  /// 当前主题
  AppColorsData _current = AppPresets.defaultBlue;

  /// 用户自定义主题（可增删）
  final List<AppColorsData> _customThemes = [];

  bool _initialized = false;

  AppColorsData get current => _current;
  List<AppColorsData> get customThemes => List.unmodifiable(_customThemes);

  /// 内置 + 自定义（用于主题中心展示）
  List<AppColorsData> get allThemes => [...AppPresets.all, ..._customThemes];

  /// 异步初始化
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPrefsKey);
      if (raw == null) return;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      // 当前主题
      final currentId = json['currentId'] as String?;
      // 自定义主题
      final customs = (json['customs'] as List<dynamic>? ?? [])
          .map((e) => AppColorsData.fromJson(e as Map<String, dynamic>))
          .toList();
      _customThemes.clear();
      _customThemes.addAll(customs);
      if (currentId != null) {
        final hit = allThemes.firstWhere(
          (t) => t.id == currentId,
          orElse: () => AppPresets.defaultBlue,
        );
        _current = hit;
      }
    } catch (e) {
      debugPrint('ThemeManager.init error: $e');
    }
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = {
        'currentId': _current.id,
        'customs': _customThemes.map((t) => t.toJson()).toList(),
      };
      await prefs.setString(_kPrefsKey, jsonEncode(json));
    } catch (e) {
      debugPrint('ThemeManager._save error: $e');
    }
  }

  /// 应用主题（立即生效 + 持久化）
  Future<void> applyTheme(AppColorsData theme) async {
    _current = theme;
    notifyListeners();
    await _save();
  }

  /// 添加自定义主题
  Future<void> addCustomTheme(AppColorsData theme) async {
    // 用 id 去重：同名同基础色视为更新
    final idx = _customThemes.indexWhere((t) => t.id == theme.id);
    if (idx >= 0) {
      _customThemes[idx] = theme;
    } else {
      _customThemes.add(theme);
    }
    notifyListeners();
    await _save();
  }

  /// 删除自定义主题
  Future<void> removeCustomTheme(String id) async {
    if (_current.id == id) {
      _current = AppPresets.defaultBlue;
    }
    _customThemes.removeWhere((t) => t.id == id);
    notifyListeners();
    await _save();
  }

  /// 根据 ID 查找主题
  AppColorsData? findById(String id) {
    for (final t in allThemes) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// 根据现有主题派生一个新主题（用于"基于此新建"）
  AppColorsData clone(AppColorsData source, {String? newName}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return source.copyWith(
      id: 'custom_$timestamp',
      name: newName ?? '$source.name 副本',
      emoji: '🎨',
    );
  }

  /// 生成 ThemeData
  ThemeData buildThemeData() {
    final base = _current;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: base.primary,
      brightness: base.isDark ? Brightness.dark : Brightness.light,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: base.background,
      canvasColor: base.background,
      cardColor: base.surface,
      dividerColor: base.divider,
      extensions: [AppColorsExtension.fromData(base)],
    );
  }
}
