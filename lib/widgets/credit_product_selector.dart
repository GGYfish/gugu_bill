import 'package:flutter/material.dart';
import '../ui_constants.dart';

/// 常见分期产品列表
class CreditProductData {
  static const List<CreditProductItem> allProducts = [
    // 电商平台分期
    CreditProductItem(name: '花呗', code: 'HUABEI', category: '电商平台', icon: '💙', color: '#1890FF'),
    CreditProductItem(name: '借呗', code: 'JIEBEI', category: '电商平台', icon: '💚', color: '#52C41A'),
    CreditProductItem(name: '京东白条', code: 'BAITIAO', category: '电商平台', icon: '🔴', color: '#FF4D4F'),
    CreditProductItem(name: '京东金条', code: 'JINTIAO', category: '电商平台', icon: '🔴', color: '#F5222D'),
    CreditProductItem(name: '唯品会唯品花', code: 'VIPFLOWER', category: '电商平台', icon: '💜', color: '#722ED1'),
    CreditProductItem(name: '抖音月付', code: 'DOUYIN', category: '电商平台', icon: '🎵', color: '#000000'),
    CreditProductItem(name: '快手月付', code: 'KUAISHOU', category: '电商平台', icon: '🎬', color: '#FF6A00'),
    CreditProductItem(name: '拼多多先用后付', code: 'PINDUODUO', category: '电商平台', icon: '🟥', color: '#E53935'),
    CreditProductItem(name: '美团月付', code: 'MEITUAN', category: '电商平台', icon: '🟠', color: '#FFD100'),
    CreditProductItem(name: '美团生活费', code: 'MEITUAN_LIFE', category: '电商平台', icon: '🟠', color: '#FF9C00'),
    CreditProductItem(name: '支付宝备用金', code: 'BEIYONGJIN', category: '电商平台', icon: '💛', color: '#FAAD14'),
    CreditProductItem(name: '微信分付', code: 'WECHAT_FENFU', category: '电商平台', icon: '🟢', color: '#07C160'),
    CreditProductItem(name: '小鹅花钱', code: 'XIAOE', category: '电商平台', icon: '🦆', color: '#1890FF'),
    CreditProductItem(name: '携程拿去花', code: 'XIECHENG', category: '电商平台', icon: '✈️', color: '#0255EE'),
    CreditProductItem(name: '去哪儿信用付', code: 'QUNAR', category: '电商平台', icon: '✈️', color: '#1890FF'),
    
    // 消费金融
    CreditProductItem(name: '招联金融', code: 'ZHAOLIAN', category: '消费金融', icon: '🏦', color: '#D32F2F'),
    CreditProductItem(name: '马上消费金融', code: 'MACSHENG', category: '消费金融', icon: '🏦', color: '#1976D2'),
    CreditProductItem(name: '中原消费金融', code: 'ZHONGYUAN', category: '消费金融', icon: '🏦', color: '#388E3C'),
    CreditProductItem(name: '海尔消费金融', code: 'HAIER', category: '消费金融', icon: '🏦', color: '#D32F2F'),
    CreditProductItem(name: '苏宁消费金融', code: 'SUNING', category: '消费金融', icon: '🏦', color: '#F57C00'),
    CreditProductItem(name: '百度有钱花', code: 'BAIDU', category: '消费金融', icon: '🔵', color: '#2932E1'),
    CreditProductItem(name: '360借条', code: '360', category: '消费金融', icon: '🔵', color: '#00C853'),
    CreditProductItem(name: '滴滴金融', code: 'DIDI', category: '消费金融', icon: '🚗', color: '#333333'),
    CreditProductItem(name: '滴滴滴水贷', code: 'DIDI_LOAN', category: '消费金融', icon: '🚗', color: '#1A73E8'),
    CreditProductItem(name: '洋钱罐', code: 'YANGQIANGUAN', category: '消费金融', icon: '💰', color: '#722ED1'),
    CreditProductItem(name: '豆豆钱', code: 'DOUDOU', category: '消费金融', icon: '🫘', color: '#F57C00'),
    CreditProductItem(name: '国美易卡', code: 'GUOMEI', category: '消费金融', icon: '🔴', color: '#E53935'),
    CreditProductItem(name: '任性贷', code: 'RENXING', category: '消费金融', icon: '💳', color: '#9C27B0'),
    CreditProductItem(name: '平安小橙花', code: 'PINGAN', category: '消费金融', icon: '🟠', color: '#FF6600'),
    
    // 银行信用卡分期
    CreditProductItem(name: '信用卡分期', code: 'CREDIT_CARD', category: '银行信用卡', icon: '💳', color: '#1565C0'),
    CreditProductItem(name: '信用卡最低还款', code: 'CREDIT_MIN', category: '银行信用卡', icon: '💳', color: '#1976D2'),
    CreditProductItem(name: '信用卡现金分期', code: 'CREDIT_CASH', category: '银行信用卡', icon: '💳', color: '#0D47A1'),
    
    // 其他
    CreditProductItem(name: '其他分期产品', code: 'OTHER', category: '其他', icon: '📦', color: '#757575'),
  ];

  /// 按分类获取产品
  static Map<String, List<CreditProductItem>> get productsByCategory {
    final Map<String, List<CreditProductItem>> result = {};
    for (final product in allProducts) {
      result.putIfAbsent(product.category, () => []).add(product);
    }
    return result;
  }
}

/// 信贷产品项
class CreditProductItem {
  final String name;
  final String code;
  final String category;
  final String icon;
  final String color;

  const CreditProductItem({
    required this.name,
    required this.code,
    required this.category,
    required this.icon,
    required this.color,
  });
}

/// 信贷产品选择器
class CreditProductSelector {
  /// 显示信贷产品选择器
  static Future<CreditProductItem?> show(BuildContext context, {CreditProductItem? currentProduct}) {
    return showModalBottomSheet<CreditProductItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreditProductSelectorSheet(currentProduct: currentProduct),
    );
  }
}

class _CreditProductSelectorSheet extends StatefulWidget {
  final CreditProductItem? currentProduct;

  const _CreditProductSelectorSheet({this.currentProduct});

  @override
  State<_CreditProductSelectorSheet> createState() => _CreditProductSelectorSheetState();
}

class _CreditProductSelectorSheetState extends State<_CreditProductSelectorSheet> {
  final _searchController = TextEditingController();
  List<CreditProductItem> _filteredProducts = CreditProductData.allProducts;
  String _searchKeyword = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String keyword) {
    setState(() {
      _searchKeyword = keyword;
      if (keyword.isEmpty) {
        _filteredProducts = CreditProductData.allProducts;
      } else {
        _filteredProducts = CreditProductData.allProducts
            .where((p) => p.name.contains(keyword) || p.code.toLowerCase().contains(keyword.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部拖拽条
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '选择信贷产品',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          // 搜索框
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: '搜索分期产品...',
                hintStyle: TextStyle(color: AppColors.textTertiary),
                prefixIcon: Icon(Icons.search, color: AppColors.textTertiary),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 产品列表
          Expanded(
            child: _searchKeyword.isEmpty
                ? _buildCategorizedList()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  /// 按分类显示产品列表
  Widget _buildCategorizedList() {
    final productsByCategory = CreditProductData.productsByCategory;
    final categories = productsByCategory.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final products = productsByCategory[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...products.map((product) => _buildProductItem(product)),
          ],
        );
      },
    );
  }

  /// 显示搜索结果
  Widget _buildSearchResults() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
          '未找到匹配的产品',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _buildProductItem(_filteredProducts[index]);
      },
    );
  }

  /// 单个产品项
  Widget _buildProductItem(CreditProductItem product) {
    final isSelected = widget.currentProduct?.code == product.code;

    return InkWell(
      onTap: () => Navigator.pop(context, product),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Color(int.parse(product.color.replaceFirst('#', '0xFF'))).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  product.icon,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
