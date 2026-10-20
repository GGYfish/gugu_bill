import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;
  bool _mockMode = true;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  bool get mockMode => _mockMode;

  void init({bool mockMode = true}) {
    _mockMode = mockMode;
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.example.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // 监听网络状态
    Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = !results.contains(ConnectivityResult.none);
    });
  }

  void setMockMode(bool enabled) {
    _mockMode = enabled;
  }

  // Mock数据
  static final Map<String, dynamic> _mockBills = {
    'code': 0,
    'data': {
      'income': 15000.0,
      'expense': 8500.0,
      'todayExpense': 98.88,
      'monthExpense': 598.98,
      'monthIncome': 45.00,
      'bills': [
        {
          'billId': 'b001',
          'type': 'expense',
          'amount': 32.5,
          'categoryName': '餐饮',
          'accountName': '微信',
          'remark': '午餐',
          'billTime': DateTime.now().toIso8601String(),
        },
        {
          'billId': 'b002',
          'type': 'income',
          'amount': 5000.0,
          'categoryName': '工资',
          'accountName': '银行卡',
          'remark': '本月工资',
          'billTime': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ],
      'unconfirmedBills': 2,
    },
  };

  static final Map<String, dynamic> _mockStatistics = {
    'code': 0,
    'data': {
      'income': 15000.0,
      'expense': 8500.0,
      'budget': 10000.0,
      'budgetUsed': 0.85,
      'categoryStats': [
        {'categoryName': '餐饮', 'amount': 2000.0, 'percentage': 0.24},
        {'categoryName': '交通', 'amount': 500.0, 'percentage': 0.06},
        {'categoryName': '购物', 'amount': 3000.0, 'percentage': 0.35},
        {'categoryName': '娱乐', 'amount': 1000.0, 'percentage': 0.12},
        {'categoryName': '其他', 'amount': 2000.0, 'percentage': 0.23},
      ],
      'dailyTrend': [
        {'date': '2026-08-01', 'amount': 150.0},
        {'date': '2026-08-02', 'amount': 200.0},
        {'date': '2026-08-03', 'amount': 80.0},
      ],
      'aiAnalysis': '本月消费主要集中在购物和餐饮，建议适当控制非必要支出。',
    },
  };

  static final Map<String, dynamic> _mockLiabilities = {
    'code': 0,
    'data': {
      'totalLiability': 50000.0,
      'pendingRepay': 35000.0,
      'repaid': 15000.0,
      'thisMonthRepay': 5000.0,
      'overdueAmount': 2000.0,
      'liabilities': [
        {
          'liabilityId': 'l001',
          'name': '招商信用卡',
          'type': 'credit_card',
          'totalAmount': 30000.0,
          'repaidAmount': 10000.0,
          'dueDate': '2026-09-15',
          'status': 0,
        },
        {
          'liabilityId': 'l002',
          'name': '花呗',
          'type': 'credit_card',
          'totalAmount': 20000.0,
          'repaidAmount': 5000.0,
          'dueDate': '2026-09-10',
          'status': 0,
        },
      ],
    },
  };

  static final List<Map<String, dynamic>> _mockCategories = [
    {'id': 'food', 'name': '餐饮', 'icon': 'restaurant', 'color': '#FF9800'},
    {'id': 'transport', 'name': '交通', 'icon': 'directions_car', 'color': '#2196F3'},
    {'id': 'shopping', 'name': '购物', 'icon': 'shopping_bag', 'color': '#E91E63'},
    {'id': 'entertainment', 'name': '娱乐', 'icon': 'sports_esports', 'color': '#9C27B0'},
    {'id': 'medical', 'name': '医疗', 'icon': 'local_hospital', 'color': '#F44336'},
    {'id': 'education', 'name': '教育', 'icon': 'school', 'color': '#3F51B5'},
    {'id': 'housing', 'name': '住房', 'icon': 'home', 'color': '#795548'},
    {'id': 'salary', 'name': '工资', 'icon': 'payments', 'color': '#4CAF50'},
    {'id': 'bonus', 'name': '奖金', 'icon': 'card_giftcard', 'color': '#8BC34A'},
    {'id': 'other', 'name': '其他', 'icon': 'more_horiz', 'color': '#607D8B'},
  ];

  // 通用请求方法
  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
  }) async {
    if (_mockMode) {
      return _getMockData(path);
    }

    try {
      Response response;
      if (method == 'GET') {
        response = await _dio.get(path);
      } else {
        response = await _dio.post(path, data: data);
      }
      return response.data;
    } catch (e) {
      return {'code': -1, 'message': e.toString()};
    }
  }

  Map<String, dynamic> _getMockData(String path) {
    if (path.contains('/bills') || path.contains('/summary')) {
      return _mockBills;
    } else if (path.contains('/statistics')) {
      return _mockStatistics;
    } else if (path.contains('/liabilities')) {
      return _mockLiabilities;
    } else if (path.contains('/categories')) {
      return {'code': 0, 'data': _mockCategories};
    }
    return {'code': 0, 'data': {}};
  }

  // 账单相关
  Future<Map<String, dynamic>> getBills({int? year, int? month}) async {
    return request('/api/bills');
  }

  Future<Map<String, dynamic>> addBill(Map<String, dynamic> billData) async {
    if (_mockMode) {
      return {'code': 0, 'data': {'billId': 'b${DateTime.now().millisecondsSinceEpoch}'}};
    }
    return request('/api/bills', method: 'POST', data: billData);
  }

  // 统计相关
  Future<Map<String, dynamic>> getStatistics({String period = 'month'}) async {
    return request('/api/statistics');
  }

  // 负债相关
  Future<Map<String, dynamic>> getLiabilities() async {
    return request('/api/liabilities');
  }

  Future<Map<String, dynamic>> addLiability(Map<String, dynamic> data) async {
    return request('/api/liabilities', method: 'POST', data: data);
  }

  Future<Map<String, dynamic>> addRepay(Map<String, dynamic> data) async {
    return request('/api/liabilities/repay', method: 'POST', data: data);
  }

  // 分类
  Future<List<Map<String, dynamic>>> getCategories() async {
    final result = await request('/api/categories');
    return List<Map<String, dynamic>>.from(result['data'] ?? []);
  }
}
