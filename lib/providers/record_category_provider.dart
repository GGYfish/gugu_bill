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
  Map<String, Map<String, int>> _categoryUsage = {};
  // 是否已从数据库加载过排序数据
  bool _orderLoaded = false;

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
    // 分离大分类和小分类
    final parents = data.where((c) => c.parentId == null).toList();
    final subs = data.where((c) => c.parentId != null).toList();

    // 构建子分类Map
    final subsMap = <String, List<LocalCategoriesData>>{};
    for (final sub in subs) {
      if (sub.parentId != null) {
        subsMap.putIfAbsent(sub.parentId!, () => []).add(sub);
      }
    }

    // 分类
    final expenseParents = parents.where((p) => p.type == 'expense').toList();
    final incomeParents = parents.where((p) => p.type == 'income').toList();

    // 其他类型（用于"其他"tab，转账、还款、充值等）
    final otherParentIds = ['transfer', 'repayment', 'recharge', 'withdraw', 'agent_pay'];
    final otherParents = parents.where((p) => otherParentIds.contains(p.categoryId)).toList();

    _expenseCategories = _buildSortedCategories(expenseParents, subsMap, 'expense');
    _incomeCategories = _buildSortedCategories(incomeParents, subsMap, 'income');
    _otherCategories = _buildSortedCategories(otherParents, subsMap, 'other');

    _isLoading = false;
    notifyListeners();
  }

  /// 构建排好序的分类列表
  /// 排序规则：1. 用户自定义顺序 > 2. 使用次数降序 > 3. 数据库 sortOrder
  List<CategoryItem> _buildSortedCategories(
    List<LocalCategoriesData> parents,
    Map<String, List<LocalCategoriesData>> subsMap,
    String type,
  ) {
    final items = parents.map((p) {
      final subList = subsMap[p.categoryId] ?? [];
      return CategoryItem.fromData(p, subs: subList);
    }).toList();

    if (!_orderLoaded) return items;

    final customOrder = _categoryOrder[type] ?? <String>[];
    final usageMap = _categoryUsage[type] ?? {};

    final sorted = List<CategoryItem>.from(items);
    sorted.sort((a, b) {
      final aIdx = customOrder.indexOf(a.id);
      final bIdx = customOrder.indexOf(b.id);
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
      final aUsage = usageMap[a.id] ?? 0;
      final bUsage = usageMap[b.id] ?? 0;
      if (aUsage != bUsage) {
        return bUsage.compareTo(aUsage);
      }

      // 使用次数相同，按数据库 sortOrder 排
      return 0;
    });

    return sorted;
  }

  /// 记录分类使用次数（每次记账成功后调用）
  void recordUsage(String categoryId) {
    // 找出该分类属于哪种类型
    String? type;
    for (final cat in [..._expenseCategories, ..._incomeCategories, ..._otherCategories]) {
      if (cat.id == categoryId) {
        type = _getCategoryType(cat.id);
        break;
      }
    }
    if (type == null) return;

    _categoryUsage.putIfAbsent(type, () => {});
    _categoryUsage[type]![categoryId] = (_categoryUsage[type]![categoryId] ?? 0) + 1;

    // 异步保存到数据库
    _saveOrderToDb();
  }

  /// 根据分类ID判断属于哪种类型
  String _getCategoryType(String categoryId) {
    for (final cat in _expenseCategories) {
      if (cat.id == categoryId) return 'expense';
    }
    for (final cat in _incomeCategories) {
      if (cat.id == categoryId) return 'income';
    }
    for (final cat in _otherCategories) {
      if (cat.id == categoryId) return 'other';
    }
    return 'expense';
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
