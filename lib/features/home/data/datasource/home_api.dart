import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/api_response.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/models/route_query.dart';
import 'package:dio/dio.dart';

/// 홈 화면·공지 화면에서 사용하는 학생 API입니다.
class HomeApi {
  HomeApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;
  final Dio _dio;

  Future<ApiResponse<BusSchedule>> getBusSchedule(String date) => _request(
    () => _dio.get('/student/bus/schedule', queryParameters: {'date': date}),
    BusSchedule.fromJson,
  );

  Future<ApiResponse<ApplicationPeriod>> getApplicationPeriod(String date) =>
      _request(
        () => _dio.get(
          '/student/application-period',
          queryParameters: {'date': date},
        ),
        ApplicationPeriod.fromJson,
      );

  Future<ApiResponse<List<Announcement>>> getAnnouncements() => _requestList(
    () => _dio.get('/student/announcements'),
    Announcement.fromJson,
  );

  Future<ApiResponse<Announcement>> getAnnouncement(int announcementId) =>
      _request(
        () => _dio.get('/student/announcements/$announcementId'),
        Announcement.fromJson,
      );

  Future<void> markAnnouncementAsRead(int announcementId) async {
    await _perform(
      () => _dio.post('/student/announcements/$announcementId/read'),
      allowEmpty: true,
    );
  }

  Future<ApiResponse<AbsentResult>> applyAbsent(AbsentRequest request) =>
      _request(
        () => _dio.post('/student/attendance/absent', data: request.toJson()),
        AbsentResult.fromJson,
      );

  Future<ApiResponse<AbsentResult>> cancelAbsent() => _request(
    () => _dio.delete('/student/attendance/absent'),
    AbsentResult.fromJson,
  );

  // 현재 계약에서 상세 경로 data는 JSON 객체입니다.
  Future<ApiResponse<Map<String, dynamic>>> getRoute(RouteQuery query) async {
    final parameters = query.toQueryParameters();
    return _request(
      () => _dio.get('/api/route', queryParameters: parameters),
      (data) => data,
    );
  }

  Future<ApiResponse<RouteSummary>> getRouteSummary({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) => getRouteSummaryFor(
    RouteQuery(
      start: (latitude: startLat, longitude: startLng),
      end: (latitude: endLat, longitude: endLng),
    ),
  );

  Future<ApiResponse<RouteSummary>> getRouteSummaryFor(RouteQuery query) async {
    final parameters = query.toQueryParameters();
    try {
      return await _request(
        () => _dio.get('/api/route/summary', queryParameters: parameters),
        RouteSummary.fromJson,
      );
    } on TypeError {
      throw const ApiException('경로 요약 응답 형식이 올바르지 않습니다.');
    }
  }

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = await _perform(request);
    final data = body['data'];
    if (data is! Map) throw const ApiException('서버 응답의 data 형식이 올바르지 않습니다.');
    return ApiResponse(
      success: true,
      message: body['message'] as String?,
      data: fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResponse<List<T>>> _requestList<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final body = await _perform(request);
    final data = body['data'];
    if (data is! List) throw const ApiException('서버 응답의 data 형식이 올바르지 않습니다.');
    try {
      return ApiResponse(
        success: true,
        message: body['message'] as String?,
        data: [
          for (final item in data)
            fromJson(Map<String, dynamic>.from(item as Map)),
        ],
      );
    } on TypeError {
      throw const ApiException('서버 응답의 data 형식이 올바르지 않습니다.');
    }
  }

  Future<Map> _perform(
    Future<Response<dynamic>> Function() request, {
    bool allowEmpty = false,
  }) async {
    try {
      final response = await request();
      final body = response.data;
      if (allowEmpty && (body == null || body == '')) return const {};
      if (body is! Map || body['success'] != true) {
        final message = body is Map ? body['message'] : null;
        final error = body is Map ? body['error'] : null;
        final detail = error is Map ? error['message'] : null;
        throw ApiException(
          detail is String
              ? detail
              : message is String
              ? message
              : '요청에 실패했습니다.',
          statusCode: response.statusCode,
        );
      }
      return body;
    } on DioException catch (error) {
      throw ApiException.fromDio(error);
    }
  }
}
