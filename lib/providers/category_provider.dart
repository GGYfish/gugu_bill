import 'package:flutter/material.dart';
import '../database/database.dart';
import 'record_category_provider.dart' show getCategoryIconData, parseColorHex;

/// 分类信息数据类（仅用于展示：大分类的图标和颜色）
class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  CategoryInfo({required this.name, required this.icon, required this.color});
}

/// 分类 Provider：从 local_categories 表加载分类，支持大小分类层级。
/// 用于首页流水列表等"展示分类图标"场景。
/// 语义：账单的子分类展示大分类的 icon/color。
class CategoryProvider extends ChangeNotifier {
  AppDatabase? _db;

  /// categoryId -> LocalCategoriesData（含大、小分类）
  final Map<String, LocalCategoriesData> _cache = {};

  /// 是否已经触发首次加载
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// 注入数据库并开始监听分类变化
  void bind(AppDatabase db) {
    if (_db == db) return;
    _db = db;
    _db!.watchAllCategories().listen((data) {
      _cache.clear();
      for (final c in data) {
        _cache[c.categoryId] = c;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// 显式刷新（分类被增删改后强制刷新）
  void invalidate() {
    // 由 watch stream 自动驱动，这里不做事，仅保留 API
  }

  /// 兜底：返回默认"其他"分类信息
  CategoryInfo _fallback() {
    return CategoryInfo(
      name: '其他',
      icon: Icons.more_horiz,
      color: const Color(0xFF8E8E93),
    );
  }

  /// 根据账单获取分类的展示信息。
  /// 语义规则：
  /// 1. 若账单的 categoryId 是子分类（parentId != null），返回【大分类】的 icon/color/name
  /// 2. 若账单的 categoryId 本身就是顶级分类，返回其自身
  /// 3. 数据库未命中时，按名称在兜底集合里粗匹配；仍未命中返回"其他"
  CategoryInfo getCategoryIconAndColor(LocalBillsData bill) {
    final id = bill.categoryId;

    if (id != null && _cache.containsKey(id)) {
      final cat = _cache[id]!;
      final parentId = cat.parentId;
      if (parentId != null && _cache.containsKey(parentId)) {
        // 子分类：展示大分类
        final parent = _cache[parentId]!;
        return CategoryInfo(
          name: parent.name,
          icon: getCategoryIconData(parent.icon),
          color: parseColorHex(parent.color),
        );
      }
      // 顶级分类或孤立节点：展示自身
      return CategoryInfo(
        name: cat.name,
        icon: getCategoryIconData(cat.icon),
        color: parseColorHex(cat.color),
      );
    }

    // 数据库未命中：兜底按名称匹配（兼容 categoryId 极小概率为 null 的老账单）
    return _matchByName(bill.categoryName);
  }

  /// 兜底：按分类名称匹配到内置默认分类
  CategoryInfo _matchByName(String? name) {
    if (name == null) return _fallback();
    final lower = name.toLowerCase();

    CategoryInfo pick(String key, IconData icon, Color color) =>
        CategoryInfo(name: key, icon: icon, color: color);

    // 餐饮
    if (lower.contains('餐') || lower.contains('食') || lower.contains('咖啡') ||
        lower.contains('奶茶') || lower.contains('饮料') || lower.contains('烟酒') ||
        lower.contains('零食') || lower.contains('水果')) {
      return pick('餐饮', Icons.restaurant, const Color(0xFFFF9500));
    }
    // 交通
    if (lower.contains('交通') || lower.contains('车') || lower.contains('加油') ||
        lower.contains('停车') || lower.contains('打车') || lower.contains('公交') ||
        lower.contains('地铁') || lower.contains('火车') || lower.contains('飞机')) {
      return pick('交通', Icons.directions_car, const Color(0xFF007AFF));
    }
    // 购物
    if (lower.contains('购物') || lower.contains('买') || lower.contains('家具') ||
        lower.contains('母婴') || lower.contains('家电') || lower.contains('美妆') ||
        lower.contains('服饰') || lower.contains('个护')) {
      return pick('购物', Icons.shopping_bag, const Color(0xFFFF2D55));
    }
    // 娱乐
    if (lower.contains('娱乐') || lower.contains('电影') || lower.contains('游戏') ||
        lower.contains('音乐') || lower.contains('演出') || lower.contains('按摩') ||
        lower.contains('健身') || lower.contains('约会')) {
      return pick('娱乐', Icons.movie, const Color(0xFFAF52DE));
    }
    // 医疗
    if (lower.contains('医') || lower.contains('药')) {
      return pick('医疗', Icons.local_hospital, const Color(0xFFFF3B30));
    }
    // 教育
    if (lower.contains('教育') || lower.contains('学费') || lower.contains('培训') ||
        lower.contains('书')) {
      return pick('教育', Icons.school, const Color(0xFF5856D6));
    }
    // 工资
    if (lower.contains('工资') || lower.contains('薪资') || lower.contains('兼职')) {
      return pick('工资', Icons.account_balance_wallet, const Color(0xFF34C759));
    }
    // 奖金
    if (lower.contains('奖金') || lower.contains('红包')) {
      return pick('奖金', Icons.card_giftcard, const Color(0xFF30B0C7));
    }
    // 转账
    if (lower.contains('转账')) {
      return pick('转账', Icons.swap_horiz, const Color(0xFF5856D6));
    }
    // 通讯
    if (lower.contains('通讯') || lower.contains('话费') || lower.contains('网费') ||
        lower.contains('流量')) {
      return pick('通讯', Icons.phone_android, const Color(0xFF4CD964));
    }
    // 住房
    if (lower.contains('住房') || lower.contains('房租') || lower.contains('物业') ||
        lower.contains('水电')) {
      return pick('住房', Icons.house, const Color(0xFFFF6482));
    }
    // 旅行
    if (lower.contains('旅行') || lower.contains('酒店') || lower.contains('门票')) {
      return pick('旅行', Icons.flight, const Color(0xFF00CEC9));
    }
    // 投资/理财
    if (lower.contains('投资') || lower.contains('理财') || lower.contains('股票') ||
        lower.contains('基金') || lower.contains('保险') || lower.contains('黄金')) {
      return pick('投资', Icons.trending_up, const Color(0xFF00B894));
    }
    // 借出/还债
    if (lower.contains('借出') || lower.contains('还债')) {
      return pick('债务', Icons.credit_score, const Color(0xFFE74C3C));
    }
    // 宠物
    if (lower.contains('宠物') || lower.contains('猫') || lower.contains('狗')) {
      return pick('宠物', Icons.pets, const Color(0xFFFDA7DF));
    }
    // 美容
    if (lower.contains('美容')) {
      return pick('美容', Icons.spa, const Color(0xFFFD79A8));
    }
    // 收款/其他收入
    if (lower.contains('收款') || lower.contains('利息') || lower.contains('分红')) {
      return pick('其他收入', Icons.attach_money, const Color(0xFFFDCB6E));
    }

    return _fallback();
  }

  /// 兼容旧调用：仅按 ID/名称匹配（保留兜底逻辑，不读数据库）
  /// 旧代码可能在调，新代码应改用 getCategoryIconAndColor。
  CategoryInfo getCategoryInfo(String? categoryId, String? categoryName) {
    if (categoryId != null && _cache.containsKey(categoryId)) {
      final cat = _cache[categoryId]!;
      final parentId = cat.parentId;
      if (parentId != null && _cache.containsKey(parentId)) {
        final parent = _cache[parentId]!;
        return CategoryInfo(
          name: parent.name,
          icon: getCategoryIconData(parent.icon),
          color: parseColorHex(parent.color),
        );
      }
      return CategoryInfo(
        name: cat.name,
        icon: getCategoryIconData(cat.icon),
        color: parseColorHex(cat.color),
      );
    }
    return _matchByName(categoryName);
  }
}