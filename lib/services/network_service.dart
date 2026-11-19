import 'package:dio/dio.dart';

/// 预留的 HTTP 客户端（当前业务以本地 Drift 为准，不再走 Mock / 离线同步队列）。
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
  }) async {
    try {
      final Response response;
      if (method == 'GET') {
        response = await _dio.get(path);
      } else {
        response = await _dio.post(path, data: data);
      }
      final body = response.data;
      if (body is Map<String, dynamic>) return body;
      return {'code': 0, 'data': body};
    } catch (e) {
      return {'code': -1, 'message': e.toString()};
    }
  }
}
