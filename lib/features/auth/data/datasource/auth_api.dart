import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/models/login_response.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/models/Signup_response.dart';
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
      ApiClient.setTokens(
        AuthTokens(
          accessToken: login.accessToken,
          refreshToken: login.refreshToken,
        ),
      );
      return login;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 회원가입 후 서버가 반환한 가입 완료 정보를 돌려줍니다.
  ///
  /// 회원가입은 로그인과 달리 토큰을 발급하지 않으므로, 완료 뒤 사용자가
  /// 로그인 화면에서 자격 증명을 입력하도록 합니다.
  Future<SignupResponseData> signup(SignupRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/signup',
        data: request.toJson(),
      );
      final body = response.data;
      final data = body?['data'];

      if (body == null || body['success'] != true || data is! Map) {
        throw ApiException(
          _messageFrom(body) ?? '회원가입에 실패했습니다.',
          statusCode: response.statusCode,
        );
      }

      return SignupResponseData.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
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
