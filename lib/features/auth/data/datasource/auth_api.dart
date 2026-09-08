import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/models/login_response.dart';
import 'package:dio/dio.dart';

class AuthApi {
  AuthApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final body = response.data;
      final data = body?['data'];

      if (body == null || body['success'] != true || data is! Map) {
        throw ApiException(
          _messageFrom(body) ?? '로그인에 실패했습니다.',
          statusCode: response.statusCode,
        );
      }

      final login = LoginResponse.fromJson(Map<String, dynamic>.from(data));
      ApiClient.setAccessToken(login.accessToken);
      return login;
    } on DioException catch (error) {
      throw ApiException(
        _messageFrom(error.response?.data) ?? '네트워크 연결을 확인해주세요.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  String? _messageFrom(Object? body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return body['message'] is String ? body['message'] as String : null;
  }
}
