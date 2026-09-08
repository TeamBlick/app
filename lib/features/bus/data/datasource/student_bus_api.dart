import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/api_response.dart';
import 'package:blick/features/bus/data/models/student_bus_models.dart';
import 'package:dio/dio.dart';

/// 학생 버스 탭에서 쓰는 API만 모은 datasource입니다.
class StudentBusApi {
  StudentBusApi({Dio? dio}) : _dio = dio ?? ApiClient.instance;

  final Dio _dio;

  Future<ApiResponse<StudentInfo>> requestBus(BusRequest request) => _request(
    () => _dio.post('/student/bus/request', data: request.toJson()),
    StudentInfo.fromJson,
  );

  Future<ApiResponse<BusChangeResult>> changeBus(BusChangeRequest request) =>
      _request(
        () => _dio.post('/student/bus/change', data: request.toJson()),
        BusChangeResult.fromJson,
      );

  Future<ApiResponse<BusApplication>> getMyApplication(String date) => _request(
    () => _dio.get('/student/bus/application', queryParameters: {'date': date}),
    BusApplication.fromJson,
  );

  Future<ApiResponse<BusApplication>> createApplication(
    BusApplicationRequest request,
  ) => _request(
    () => _dio.post('/student/bus/application', data: request.toJson()),
    BusApplication.fromJson,
  );

  Future<ApiResponse<void>> cancelApplication(String date) => _voidRequest(
    () => _dio.delete(
      '/student/bus/application',
      queryParameters: {'date': date},
    ),
  );

  Future<ApiResponse<BusApplication>> updateApplication(
    BusApplicationRequest request,
  ) => _request(
    () => _dio.patch('/student/bus/application', data: request.toJson()),
    BusApplication.fromJson,
  );

  Future<ApiResponse<T>> _request<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    try {
      final response = await request();
      final body = _body(response.data, response.statusCode);
      final data = body['data'];
      if (data is! Map) {
        throw ApiException('서버 응답의 data 형식이 올바르지 않습니다.');
      }
      return ApiResponse(
        success: true,
        message: body['message'] as String?,
        data: fromJson(Map<String, dynamic>.from(data)),
      );
    } on DioException catch (error) {
      throw ApiException(
        '네트워크 연결을 확인해주세요.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Future<ApiResponse<void>> _voidRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      final response = await request();
      final body = _body(response.data, response.statusCode);
      return ApiResponse(
        success: true,
        message: body['message'] as String?,
        data: null,
      );
    } on DioException catch (error) {
      throw ApiException(
        '네트워크 연결을 확인해주세요.',
        statusCode: error.response?.statusCode,
      );
    }
  }

  Map _body(Object? body, int? statusCode) {
    if (body is! Map || body['success'] != true) {
      throw ApiException('요청에 실패했습니다.', statusCode: statusCode);
    }
    return body;
  }
}
