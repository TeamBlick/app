import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/api_response.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/models/Signup_response.dart';
import 'package:dio/dio.dart';

/// 학생 앱에서 사용하는 Swagger v1 API를 호출하는 Dio datasource입니다.
///
/// 각 기능 화면에서는 이 클래스의 메서드만 호출하고, HTTP 메서드·URL·응답
/// 검증은 이 파일에서 처리합니다. 요청은 `SignupRequest`처럼 각 API의 DTO
/// 모델을 받고, 응답도 `SignupResponseData`처럼 구체 타입으로 반환합니다.
///
/// ```dart
/// final response = await api.signup(signupRequest);
/// final username = response.data?.username;
/// ```
///
class BlickApi {
  /// 테스트에서는 가짜 Dio를 주입하고, 앱에서는 공통 설정을 가진 Dio를 사용합니다.
  BlickApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  // 학생: 버스 신청과 미탑승 처리
  Future<ApiResponse<dynamic>> requestBus(Map<String, dynamic> request) =>
      _post('/student/bus/request', data: request);
  Future<ApiResponse<dynamic>> changeBus(Map<String, dynamic> request) =>
      _post('/student/bus/change', data: request);
  Future<ApiResponse<dynamic>> getMyApplication(String date) =>
      _get('/student/bus/application', query: {'date': date});
  Future<ApiResponse<dynamic>> createApplication(
    Map<String, dynamic> request,
  ) => _post('/student/bus/application', data: request);
  Future<ApiResponse<dynamic>> cancelApplication(String date) =>
      _delete('/student/bus/application', query: {'date': date});
  Future<ApiResponse<dynamic>> updateApplication(
    Map<String, dynamic> request,
  ) => _patch('/student/bus/application', data: request);
  Future<ApiResponse<dynamic>> applyAbsent(Map<String, dynamic> request) =>
      _post('/student/attendance/absent', data: request);
  Future<ApiResponse<dynamic>> cancelAbsent() =>
      _delete('/student/attendance/absent');
  Future<ApiResponse<dynamic>> getStudentBusSchedule(String date) =>
      _get('/student/bus/schedule', query: {'date': date});
  Future<ApiResponse<dynamic>> getStudentApplicationPeriod(String date) =>
      _get('/student/application-period', query: {'date': date});

  // 학생: 공지 조회와 읽음 처리
  Future<ApiResponse<dynamic>> getStudentAnnouncements() =>
      _get('/student/announcements');
  Future<ApiResponse<dynamic>> getStudentAnnouncement(int announcementId) =>
      _get('/student/announcements/$announcementId');
  Future<ApiResponse<dynamic>> markAnnouncementAsRead(int announcementId) =>
      _post('/student/announcements/$announcementId/read');

  // 인증: 로그인, 회원가입, 비밀번호 재설정, 토큰 재발급
  /// 회원가입 요청과 응답을 모두 모델로 다룹니다.
  ///
  /// [SignupRequest.toJson]은 요청 모델을 JSON으로 바꾸고,
  /// [SignupResponseData.fromJson]은 응답의 `data`를 Dart 모델로 바꿉니다.
  Future<ApiResponse<SignupResponseData>> signup(SignupRequest request) =>
      _request<SignupResponseData>(
        () => _dio.post('/auth/signup', data: request.toJson()),
        (data) => SignupResponseData.fromJson(_asMap(data)),
      );
  Future<ApiResponse<dynamic>> refresh(Map<String, dynamic> request) =>
      _post('/auth/refresh', data: request);
  Future<ApiResponse<dynamic>> resetPassword(Map<String, dynamic> request) =>
      _post('/auth/password-reset', data: request);
  Future<ApiResponse<dynamic>> verifyPasswordResetCode(
    Map<String, dynamic> request,
  ) => _post('/auth/password-reset/verify', data: request);
  Future<ApiResponse<dynamic>> sendPasswordResetCode(
    Map<String, dynamic> request,
  ) => _post('/auth/password-reset/code', data: request);
  Future<ApiResponse<dynamic>> login(Map<String, dynamic> request) =>
      _post('/auth/login', data: request);

  // 경로: 출발·도착 위경도를 query parameter로 전달합니다.
  Future<ApiResponse<dynamic>> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) => _get(
    '/api/route',
    query: {
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
    },
  );
  Future<ApiResponse<dynamic>> getRouteSummary({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) => _get(
    '/api/route/summary',
    query: {
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
    },
  );

  /// 아직 모델을 만들지 않은 API는 원본 `data`를 그대로 반환합니다.
  /// 모델을 추가할 때는 [signup]처럼 `_request<T>`에 변환 함수를 전달합니다.
  ///
  /// 공개 메서드에서 반복되는 Dio 호출을 HTTP 메서드별로 한 곳에 모읍니다.
  ///
  /// query는 URL의 `?date=...` 같은 query parameter이고, data는 JSON body입니다.
  Future<ApiResponse<dynamic>> _get(
    String path, {
    Map<String, dynamic>? query,
  }) => _request<dynamic>(
    () => _dio.get(path, queryParameters: query),
    (data) => data,
  );

  Future<ApiResponse<dynamic>> _post(String path, {Object? data}) =>
      _request<dynamic>(() => _dio.post(path, data: data), (data) => data);

  Future<ApiResponse<dynamic>> _patch(String path, {Object? data}) =>
      _request<dynamic>(() => _dio.patch(path, data: data), (data) => data);

  Future<ApiResponse<dynamic>> _delete(
    String path, {
    Map<String, dynamic>? query,
  }) => _request<dynamic>(
    () => _dio.delete(path, queryParameters: query),
    (data) => data,
  );

  /// [T]는 이 API 응답 `data`의 Dart 타입입니다.
  ///
  /// [fromData]를 받는 이유는 Dio가 JSON을 Map/List로만 알기 때문입니다.
  /// 여기서 Map을 모델로 변환해 두면 화면은 JSON 키를 직접 다룰 필요가 없습니다.
  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Object? data) fromData,
  ) async {
    try {
      final response = await request();
      // 서버의 공통 응답 형식(success, message, data)을 확인합니다.
      return _parse<T>(response.data, response.statusCode, fromData);
    } on DioException catch (error) {
      // HTTP 4xx/5xx 또는 연결 실패를 화면에서 처리할 수 있는 예외로 바꿉니다.
      throw ApiException(
        _messageFrom(error.response?.data) ?? '네트워크 연결을 확인해주세요.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  ApiResponse<T> _parse<T>(
    Object? body,
    int? statusCode,
    T Function(Object? data) fromData,
  ) {
    if (body is! Map) {
      throw ApiException('서버 응답 형식이 올바르지 않습니다.', statusCode: statusCode);
    }
    final success = body['success'];
    if (success != true) {
      // 성공 HTTP 상태여도 success가 false이면 API 요청은 실패로 취급합니다.
      throw ApiException(
        _messageFrom(body) ?? '요청에 실패했습니다.',
        statusCode: statusCode,
      );
    }
    return ApiResponse<T>(
      success: true,
      message: body['message'] as String?,
      // Void 응답처럼 data가 없을 수 있으므로 null은 그대로 둡니다.
      data: body['data'] == null ? null : fromData(body['data']),
    );
  }

  /// JSON 객체가 와야 하는 응답을 안전하게 Map으로 변환합니다.
  Map<String, dynamic> _asMap(Object? data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('서버 응답의 data 형식이 올바르지 않습니다.');
  }

  String? _messageFrom(Object? body) {
    if (body is! Map) return null;
    final error = body['error'];
    // 서버는 실패 사유를 error.message에, 일부 응답은 message에 담습니다.
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return body['message'] is String ? body['message'] as String : null;
  }
}
