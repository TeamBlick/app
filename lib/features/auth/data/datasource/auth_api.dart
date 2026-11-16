import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/models/login_request.dart';
import 'package:blick/features/auth/data/repositories/auth_repository.dart';
import 'package:blick/features/auth/data/models/login_response.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/models/Signup_response.dart';
import 'package:dio/dio.dart';

class AuthApi implements AuthRepository {
  AuthApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: LoginRequest(email: email, password: password).toJSON(),
      );
      final body = response.data;
      final data = body?['data'];

      if (body == null || body['success'] != true || data is! Map) {
        throw ApiException(
          _messageFrom(body) ?? '로그인에 실패했습니다.',
          statusCode: response.statusCode,
        );
      }

      if (data['success'] == false) {
        throw ApiException(_messageFrom(data) ?? '로그인에 실패했습니다.');
      }
      return LoginResponse.fromJson(Map<String, dynamic>.from(data));
    } on TypeError {
      throw const ApiException('로그인 응답 형식이 올바르지 않습니다.');
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }

  /// 회원가입 후 서버가 반환한 가입 완료 정보를 돌려줍니다.
  ///
  /// 회원가입은 로그인과 달리 토큰을 발급하지 않으므로, 완료 뒤 사용자가
  /// 로그인 화면에서 자격 증명을 입력하도록 합니다.
  @override
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

      final signup = SignupResponseData.fromJson(
        Map<String, dynamic>.from(data),
      );
      if (!signup.success) throw ApiException(signup.message);
      return signup;
    } on TypeError {
      throw const ApiException('회원가입 응답 형식이 올바르지 않습니다.');
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
