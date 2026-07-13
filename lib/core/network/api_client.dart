import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  ApiClient._();

  static final Dio instance = _createDio();

  static Dio _createDio() {
    final baseUrl = dotenv.env['API_BASE_URL'];

    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw Exception('API_BASE_URL이 .env에 없습니다.');
    }

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
      ),
    );

    return dio;
  }
}