import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/api_response.dart';
import 'package:blick/features/home/data/models/home_models.dart';
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

  Future<ApiResponse<Announcement>> markAnnouncementAsRead(
    int announcementId,
  ) => _request(
    () => _dio.post('/student/announcements/$announcementId/read'),
    Announcement.fromJson,
  );

  Future<ApiResponse<AbsentResult>> applyAbsent(AbsentRequest request) =>
      _request(
        () => _dio.post('/student/attendance/absent', data: request.toJson()),
        AbsentResult.fromJson,
      );

  Future<ApiResponse<AbsentResult>> cancelAbsent() => _request(
    () => _dio.delete('/student/attendance/absent'),
    AbsentResult.fromJson,
  );

  Future<ApiResponse<RouteSummary>> getRouteSummary({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) => _request(
    () => _dio.get(
      '/api/route/summary',
      queryParameters: {
        'startLat': startLat,
        'startLng': startLng,
        'endLat': endLat,
        'endLng': endLng,
      },
    ),
    RouteSummary.fromJson,
  );

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
    return ApiResponse(
      success: true,
      message: body['message'] as String?,
      data: data
          .map((item) => fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  Future<Map> _perform(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is! Map || body['success'] != true) {
        throw ApiException('요청에 실패했습니다.', statusCode: response.statusCode);
      }
      return body;
    } on DioException catch (error) {
      throw ApiException(
        '네트워크 연결을 확인해주세요.',
        statusCode: error.response?.statusCode,
      );
    }
  }
}
