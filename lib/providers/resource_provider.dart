import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';

/// 分类管理Provider - 数据库CRUD操作，支持大分类和小分类层级
class CategoryManagementProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<LocalCategoriesData> _categories = [];
  List<LocalCategoriesData> _expenseCategories = [];
  List<LocalCategoriesData> _incomeCategories = [];
  // 顶级大分类
  List<LocalCategoriesData> _parentCategories = [];
  List<LocalCategoriesData> _expenseParentCategories = [];
  List<LocalCategoriesData> _incomeParentCategories = [];
  // 缓存子分类 Map<parentId, List<LocalCategoriesData>>
  Map<String, List<LocalCategoriesData>> _subCategoriesMap = {};
  bool _isLoading = false;

  List<LocalCategoriesData> get categories => _categories;
  List<LocalCategoriesData> get expenseCategories => _expenseCategories;
  List<LocalCategoriesData> get incomeCategories => _incomeCategories;
  List<LocalCategoriesData> get parentCategories => _parentCategories;
  List<LocalCategoriesData> get expenseParentCategories => _expenseParentCategories;
  List<LocalCategoriesData> get incomeParentCategories => _incomeParentCategories;
  bool get isLoading => _isLoading;

  CategoryManagementProvider(AppDatabase db) : _db = db {
    _init();
  }

  void _init() {
    _db.watchAllCategories().listen((data) async {
      _categories = data;
      _expenseCategories = data.where((c) => c.type == 'expense').toList();
      _incomeCategories = data.where((c) => c.type == 'income').toList();
      
      // 分离大分类和小分类
      _parentCategories = data.where((c) => c.parentId == null).toList();
      _expenseParentCategories = _parentCategories.where((c) => c.type == 'expense').toList();
      _incomeParentCategories = _parentCategories.where((c) => c.type == 'income').toList();
      
      // 构建子分类Map
      _subCategoriesMap = {};
      for (final parent in _parentCategories) {
        final subs = data.where((c) => c.parentId == parent.categoryId).toList();
        _subCategoriesMap[parent.categoryId] = subs;
      }
      
      notifyListeners();
    });
  }

  /// 获取某大分类下的子分类
  List<LocalCategoriesData> getSubCategories(String parentId) {
    return _subCategoriesMap[parentId] ?? [];
  }

  /// 根据分类ID获取分类信息
  LocalCategoriesData? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((c) => c.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  /// 添加大分类
  Future<void> addParentCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
    int sortOrder = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      await _db.insertCategory(LocalCategoriesCompanion(
        categoryId: Value(uuid.v4()),
        name: Value(name),
        type: Value(type),
        icon: Value(icon),
        color: Value(color),
        parentId: const Value(null),
        sortOrder: Value(sortOrder),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加小分类
  /// icon/color 不传时自动从父分类继承
  Future<void> addSubCategory({
    required String parentId,
    required String name,
    String? icon,
    String? color,
    int sortOrder = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      // 获取父分类来确定type，并继承 icon/color
      final parent = getCategoryById(parentId);
      final type = parent?.type ?? 'expense';
      final inheritedIcon = icon ?? parent?.icon ?? 'category';
      final inheritedColor = color ?? parent?.color ?? '#1976D2';

      await _db.insertCategory(LocalCategoriesCompanion(
        categoryId: Value(uuid.v4()),
        name: Value(name),
        type: Value(type),
        icon: Value(inheritedIcon),
        color: Value(inheritedColor),
        parentId: Value(parentId),
        sortOrder: Value(sortOrder),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 兼容旧方法，自动判断添加大分类还是小分类
  Future<void> addCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
    int sortOrder = 0,
    String? parentId,
  }) async {
    if (parentId != null) {
      await addSubCategory(
        parentId: parentId,
        name: name,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
      );
    } else {
      await addParentCategory(
        name: name,
        type: type,
        icon: icon,
        color: color,
        sortOrder: sortOrder,
      );
    }
  }

  Future<void> updateCategory(String categoryId, {
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isEnabled,
    String? parentId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateCategory(categoryId, LocalCategoriesCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        icon: icon != null ? Value(icon) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        isEnabled: isEnabled != null ? Value(isEnabled) : const Value.absent(),
        parentId: parentId != null ? Value(parentId) : const Value.absent(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 删除分类及其所有子分类
      await _db.deleteCategoryWithSubs(categoryId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除单个子分类
  Future<void> deleteSubCategory(String categoryId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteCategory(categoryId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// 银行机构管理Provider
class BankManagementProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<LocalBanksData> _banks = [];
  bool _isLoading = false;

  List<LocalBanksData> get banks => _banks;
  bool get isLoading => _isLoading;

  BankManagementProvider(AppDatabase db) : _db = db {
    _init();
  }

  void _init() {
    _db.watchAllBanks().listen((data) {
      _banks = data;
      notifyListeners();
    });
  }

  Future<void> addBank({
    required String name,
    required String code,
    String icon = 'account_balance',
    String color = '#1976D2',
    int sortOrder = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      await _db.insertBank(LocalBanksCompanion(
        bankId: Value(uuid.v4()),
        name: Value(name),
        code: Value(code),
        icon: Value(icon),
        color: Value(color),
        sortOrder: Value(sortOrder),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBank(String bankId, {
    String? name,
    String? code,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isEnabled,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateBank(bankId, LocalBanksCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        code: code != null ? Value(code) : const Value.absent(),
        icon: icon != null ? Value(icon) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        isEnabled: isEnabled != null ? Value(isEnabled) : const Value.absent(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBank(String bankId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteBank(bankId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

/// 信贷机构管理Provider
class CreditInstitutionManagementProvider extends ChangeNotifier {
  final AppDatabase _db;

  List<LocalCreditInstitutionsData> _institutions = [];
  bool _isLoading = false;

  List<LocalCreditInstitutionsData> get institutions => _institutions;
  bool get isLoading => _isLoading;

  CreditInstitutionManagementProvider(AppDatabase db) : _db = db {
    _init();
  }

  void _init() {
    _db.watchAllCreditInstitutions().listen((data) {
      _institutions = data;
      notifyListeners();
    });
  }

  Future<void> addInstitution({
    required String name,
    required String type,
    String icon = 'payments',
    String color = '#FF5722',
    int sortOrder = 0,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final uuid = const Uuid();
      await _db.insertCreditInstitution(LocalCreditInstitutionsCompanion(
        institutionId: Value(uuid.v4()),
        name: Value(name),
        type: Value(type),
        icon: Value(icon),
        color: Value(color),
        sortOrder: Value(sortOrder),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInstitution(String institutionId, {
    String? name,
    String? type,
    String? icon,
    String? color,
    int? sortOrder,
    bool? isEnabled,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.updateCreditInstitution(institutionId, LocalCreditInstitutionsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        type: type != null ? Value(type) : const Value.absent(),
        icon: icon != null ? Value(icon) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
        sortOrder: sortOrder != null ? Value(sortOrder) : const Value.absent(),
        isEnabled: isEnabled != null ? Value(isEnabled) : const Value.absent(),
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteInstitution(String institutionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _db.deleteCreditInstitution(institutionId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
