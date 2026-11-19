import 'dart:convert';
import 'package:flutter/material.dart';
import '../database/database.dart';

/// 记一页使用的分类数据结构（支持大分类和小分类）
class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<SubCategoryItem> sub;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.sub = const [],
  });

  /// 从 LocalCategoriesData 转换
  factory CategoryItem.fromData(LocalCategoriesData data, {List<LocalCategoriesData>? subs}) {
    return CategoryItem(
      id: data.categoryId,
      name: data.name,
      icon: getCategoryIconData(data.icon),
      color: parseColorHex(data.color),
      sub: subs?.map((s) => SubCategoryItem.fromData(s)).toList() ?? [],
    );
  }
}

/// 小分类数据结构
class SubCategoryItem {
  final String id;
  final String name;

  const SubCategoryItem({required this.id, required this.name});

  factory SubCategoryItem.fromData(LocalCategoriesData data) {
    return SubCategoryItem(
      id: data.categoryId,
      name: data.name,
    );
  }
}

/// 图标名称到 IconData 的映射
IconData getCategoryIconData(String iconName) {
  switch (iconName) {
    case 'restaurant': return Icons.restaurant;
    case 'directions_car': return Icons.directions_car;
    case 'shopping_bag': return Icons.shopping_bag;
    case 'movie': return Icons.movie;
    case 'home': return Icons.home;
    case 'local_hospital': return Icons.local_hospital;
    case 'school': return Icons.school;
    case 'work': return Icons.work;
    case 'card_giftcard': return Icons.card_giftcard;
    case 'trending_up': return Icons.trending_up;
    case 'attach_money': return Icons.attach_money;
    case 'more_horiz': return Icons.more_horiz;
    case 'category': return Icons.category;
    case 'phone_android': return Icons.phone_android;
    case 'house': return Icons.house;
    case 'swap_horiz': return Icons.swap_horiz;
    case 'flight': return Icons.flight;
    case 'sports_esports': return Icons.sports_esports;
    case 'payments': return Icons.payments;
    case 'credit_card': return Icons.credit_card;
    case 'pets': return Icons.pets;
    case 'credit_score': return Icons.credit_score;
    case 'person_remove': return Icons.person_remove;
    case 'spa': return Icons.spa;
    case 'oil_barrel': return Icons.oil_barrel;
    case 'smoking_rooms': return Icons.smoking_rooms;
    case 'eco': return Icons.eco;
    case 'chair': return Icons.chair;
    case 'child_care': return Icons.child_care;
    case 'kitchen': return Icons.kitchen;
    case 'face': return Icons.face;
    case 'checkroom': return Icons.checkroom;
    case 'gavel': return Icons.gavel;
    case 'toll': return Icons.toll;
    case 'local_parking': return Icons.local_parking;
    case 'local_gas_station': return Icons.local_gas_station;
    case 'build': return Icons.build;
    case 'local_taxi': return Icons.local_taxi;
    case 'directions_bus': return Icons.directions_bus;
    case 'music_note': return Icons.music_note;
    case 'casino': return Icons.casino;
    case 'theater_comedy': return Icons.theater_comedy;
    case 'fitness_center': return Icons.fitness_center;
    case 'favorite': return Icons.favorite;
    case 'local_pharmacy': return Icons.local_pharmacy;
    case 'toys': return Icons.toys;
    case 'phone': return Icons.phone;
    case 'wifi': return Icons.wifi;
    case 'cleaning_services': return Icons.cleaning_services;
    case 'water_drop': return Icons.water_drop;
    case 'menu_book': return Icons.menu_book;
    case 'quiz': return Icons.quiz;
    case 'confirmation_number': return Icons.confirmation_number;
    case 'hotel': return Icons.hotel;
    case 'monetization_on': return Icons.monetization_on;
    case 'security': return Icons.security;
    case 'show_chart': return Icons.show_chart;
    case 'account_balance': return Icons.account_balance;
    case 'account_balance_wallet': return Icons.account_balance_wallet;
    case 'local_cafe': return Icons.local_cafe;
    case 'request_quote': return Icons.request_quote;
    default: return Icons.category;
  }
}

Color parseColorHex(String colorStr) {
  try {
    return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
  } catch (_) {
    return const Color(0xFF7C4DFF);
  }
}

/// 记一页分类Provider - 从数据库读取分类数据，支持排序持久化
class RecordCategoryProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<CategoryItem> _expenseCategories = [];
  List<CategoryItem> _incomeCategories = [];
  List<CategoryItem> _otherCategories = []; // 其他类型（还款、充值等）
  bool _isLoading = true;

  // 持久化的分类排序顺序：{type: [categoryId1, categoryId2, ...]}
  Map<String, List<String>> _categoryOrder = {};
  // 持久化的分类使用次数：{type: {categoryId: count}}
  // 小分类的使用次数放在 "sub:<父分类id>" 命名空间下，与大分类同结构，
  // 共用 local_user_config.category_usage 一个 JSON 字段，无需改表。
  Map<String, Map<String, int>> _categoryUsage = {};
  // 是否已从数据库加载过排序数据
  bool _orderLoaded = false;
  // 原始分类数据缓存：使用次数变化时据此重新构建排序结果
  List<LocalCategoriesData> _allCategories = [];

  /// 小分类使用次数的存储 key
  static String _subUsageKey(String parentId) => 'sub:$parentId';

  List<CategoryItem> get expenseCategories => _expenseCategories;
  List<CategoryItem> get incomeCategories => _incomeCategories;
  List<CategoryItem> get otherCategories => _otherCategories;
  bool get isLoading => _isLoading;

  RecordCategoryProvider(this._db) {
    _init();
  }

  Future<void> _init() async {
    // 1. 加载持久化的排序顺序和使用次数
    await _loadPersistedOrder();
    // 2. 监听所有分类变化
    _db.watchAllCategories().listen((data) {
      _processCategories(data);
    });
  }

  /// 从数据库加载持久化的分类排序顺序和使用次数
  Future<void> _loadPersistedOrder() async {
    try {
      final config = await _db.getUserConfig();
      if (config != null) {
        // 解析分类排序顺序
        if (config.categoryOrder.isNotEmpty && config.categoryOrder != '{}') {
          _categoryOrder = Map<String, List<String>>.from(
            jsonDecode(config.categoryOrder) as Map,
          );
          // 清理空值
          _categoryOrder.removeWhere((k, v) => v.isEmpty);
        }
        // 解析分类使用次数
        if (config.categoryUsage.isNotEmpty && config.categoryUsage != '{}') {
          _categoryUsage = Map<String, Map<String, int>>.from(
            (jsonDecode(config.categoryUsage) as Map).map(
              (type, usage) => MapEntry(
                type as String,
                Map<String, int>.from(usage as Map),
              ),
            ),
          );
        }
        _orderLoaded = true;
      } else {
        _orderLoaded = true;
      }
    } catch (e) {
      // 解析失败时使用默认顺序
      _orderLoaded = true;
    }
  }

  void _processCategories(List<LocalCategoriesData> data) {
    _allCategories = data;
    _rebuildCategories();
  }

  /// 依据原始数据 + 当前排序/使用次数，重新构建三个 Tab 的分类列表
  void _rebuildCategories() {
    // 分离大分类和小分类
    final parents = _allCategories.where((c) => c.parentId == null).toList();
    final subs = _allCategories.where((c) => c.parentId != null).toList();

    // 构建子分类Map
    final subsMap = <String, List<LocalCategoriesData>>{};
    for (final sub in subs) {
      if (sub.parentId != null) {
        subsMap.putIfAbsent(sub.parentId!, () => []).add(sub);
      }
    }

    // 其他类型固定 ID（历史默认数据里 type 仍是 expense，但属于"其他"Tab）
    const otherParentIds = {
      'transfer',
      'repayment',
      'recharge',
      'withdraw',
      'agent_pay',
    };

    // 三个 Tab 互斥：支出 / 收入 / 其他，各自独立按同一套规则排序
    final expenseParents = parents
        .where((p) => p.type == 'expense' && !otherParentIds.contains(p.categoryId))
        .toList();
    final incomeParents = parents.where((p) => p.type == 'income').toList();
    // 其他：type==other 的自定义分类 + 固定归属其他的历史分类
    final otherParents = parents
        .where((p) => p.type == 'other' || otherParentIds.contains(p.categoryId))
        .toList();

    _expenseCategories = _buildSortedCategories(expenseParents, subsMap, 'expense');
    _incomeCategories = _buildSortedCategories(incomeParents, subsMap, 'income');
    _otherCategories = _buildSortedCategories(otherParents, subsMap, 'other');

    _isLoading = false;
    notifyListeners();
  }

  /// 构建排好序的分类列表
  /// 排序规则：1. 用户自定义顺序 > 2. 使用次数降序 > 3. 数据库 sortOrder
  /// 小分类同样按使用次数降序排列（次数相同保持原有顺序）。
  List<CategoryItem> _buildSortedCategories(
    List<LocalCategoriesData> parents,
    Map<String, List<LocalCategoriesData>> subsMap,
    String type,
  ) {
    final items = parents.map((p) {
      final subList = _sortSubsByUsage(subsMap[p.categoryId] ?? [], p.categoryId);
      return CategoryItem.fromData(p, subs: subList);
    }).toList();

    if (!_orderLoaded) return items;

    final customOrder = _categoryOrder[type] ?? <String>[];
    final usageMap = _categoryUsage[type] ?? {};

    // 带原始下标做装饰排序，保证使用次数相同的情况下顺序稳定
    final decorated = List.generate(items.length, (i) => MapEntry(i, items[i]));
    decorated.sort((a, b) {
      final aIdx = customOrder.indexOf(a.value.id);
      final bIdx = customOrder.indexOf(b.value.id);
      final aHasCustom = aIdx >= 0;
      final bHasCustom = bIdx >= 0;

      if (aHasCustom && bHasCustom) {
        // 都有自定义顺序，按自定义顺序排
        return aIdx.compareTo(bIdx);
      } else if (aHasCustom) {
        // 只有 a 有自定义顺序，a 排前面
        return -1;
      } else if (bHasCustom) {
        // 只有 b 有自定义顺序，b 排前面
        return 1;
      }

      // 都没有自定义顺序，按使用次数降序排
      final aUsage = usageMap[a.value.id] ?? 0;
      final bUsage = usageMap[b.value.id] ?? 0;
      if (aUsage != bUsage) {
        return bUsage.compareTo(aUsage);
      }

      // 使用次数相同，按数据库 sortOrder 排
      final aOrder = _sortOrderOf(a.value.id);
      final bOrder = _sortOrderOf(b.value.id);
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);

      // sortOrder 也相同，保持原有顺序
      return a.key.compareTo(b.key);
    });

    return decorated.map((e) => e.value).toList();
  }

  /// 大分类的 sortOrder（从原始数据中查）
  int _sortOrderOf(String categoryId) {
    for (final c in _allCategories) {
      if (c.categoryId == categoryId) return c.sortOrder;
    }
    return 0;
  }

  /// 小分类按使用次数降序排序；次数相同保持原有顺序
  List<LocalCategoriesData> _sortSubsByUsage(
    List<LocalCategoriesData> subs,
    String parentId,
  ) {
    if (subs.length < 2) return List.of(subs);

    final usageMap = _categoryUsage[_subUsageKey(parentId)] ?? {};
    final decorated = List.generate(subs.length, (i) => MapEntry(i, subs[i]));
    decorated.sort((a, b) {
      final aUsage = usageMap[a.value.categoryId] ?? 0;
      final bUsage = usageMap[b.value.categoryId] ?? 0;
      if (aUsage != bUsage) return bUsage.compareTo(aUsage);
      // 次数相同：先按 sortOrder，再按原始下标
      final aOrder = a.value.sortOrder;
      final bOrder = b.value.sortOrder;
      if (aOrder != bOrder) return aOrder.compareTo(bOrder);
      return a.key.compareTo(b.key);
    });
    return decorated.map((e) => e.value).toList();
  }

  /// 记录分类使用次数（每次记账保存成功后调用）
  /// [subCategoryId] 传入选中的小分类 id，小分类也会按次数排序。
  /// [billType] 优先使用当前记账 Tab（expense/income/other），保证三个 Tab
  /// 各自独立累计次数、按同一规则排序；不传时再按分类归属推断。
  void recordUsage(String categoryId, {String? subCategoryId, String? billType}) {
    final type = _resolveUsageType(categoryId, billType);
    if (type == null) return;

    _categoryUsage.putIfAbsent(type, () => {});
    _categoryUsage[type]![categoryId] = (_categoryUsage[type]![categoryId] ?? 0) + 1;

    // 小分类使用次数：存在 "sub:<父分类id>" 命名空间下
    if (subCategoryId != null && subCategoryId.isNotEmpty) {
      final subKey = _subUsageKey(categoryId);
      _categoryUsage.putIfAbsent(subKey, () => {});
      _categoryUsage[subKey]![subCategoryId] =
          (_categoryUsage[subKey]![subCategoryId] ?? 0) + 1;
    }

    // 立即按新次数重排，UI 无需重启即可看到顺序变化
    _rebuildCategories();

    // 异步保存到数据库
    _saveOrderToDb();
  }

  /// 解析使用次数应记到哪个 Tab 桶
  String? _resolveUsageType(String categoryId, String? billType) {
    if (billType == 'expense' || billType == 'income' || billType == 'other') {
      return billType;
    }
    // 兜底：按当前三个列表归属推断（其他优先，避免与支出重叠的历史 ID 记错桶）
    for (final cat in _otherCategories) {
      if (cat.id == categoryId) return 'other';
    }
    for (final cat in _incomeCategories) {
      if (cat.id == categoryId) return 'income';
    }
    for (final cat in _expenseCategories) {
      if (cat.id == categoryId) return 'expense';
    }
    return null;
  }

  /// 更新分类排序顺序（拖拽排序后调用）
  void updateCategoryOrder(String type, List<String> orderedIds) {
    _categoryOrder[type] = orderedIds;
    _saveOrderToDb();
  }

  /// 将当前排序和使用次数异步保存到数据库
  Future<void> _saveOrderToDb() async {
    try {
      final orderJson = jsonEncode(_categoryOrder);
      final usageJson = jsonEncode(_categoryUsage);
      await _db.updateCategoryOrderAndUsage(orderJson, usageJson);
    } catch (e) {
      // 保存失败静默忽略，下次再试
    }
  }

  /// 根据类型获取分类列表
  List<CategoryItem> getCategoriesByType(String type) {
    switch (type) {
      case 'expense':
        return _expenseCategories;
      case 'income':
        return _incomeCategories;
      case 'other':
        return _otherCategories;
      default:
        return _expenseCategories;
    }
  }

  /// 根据分类ID获取分类信息
  CategoryItem? getCategoryById(String? categoryId) {
    if (categoryId == null) return null;

    for (final cat in [..._expenseCategories, ..._incomeCategories, ..._otherCategories]) {
      if (cat.id == categoryId) return cat;
      for (final sub in cat.sub) {
        if (sub.id == categoryId) {
          return CategoryItem(
            id: cat.id,
            name: cat.name,
            icon: cat.icon,
            color: cat.color,
            sub: [sub],
          );
        }
      }
    }
    return null;
  }

  /// 根据小分类ID获取父分类信息
  CategoryItem? getParentBySubId(String subId) {
    for (final cat in [..._expenseCategories, ..._incomeCategories, ..._otherCategories]) {
      for (final sub in cat.sub) {
        if (sub.id == subId) return cat;
      }
    }
    return null;
  }
}
