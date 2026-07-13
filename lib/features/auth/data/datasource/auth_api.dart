import 'package:dio/dio.dart';
import 'package:blick/core/network/api_client.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String id,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'id': id,
        'password': password,
      },
    );

    final data = response.data;

    if (data == null) {
      throw Exception('로그인 응답 데이터가 없습니다.');
    }

    return data;
  }
}