import 'package:dio/dio.dart';

/// 화면과 datasource가 공통으로 처리하는 네트워크 실패 종류입니다.
enum ApiErrorType {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  server,
  timeout,
  network,
  cancelled,
  unknown,
}

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.type = ApiErrorType.unknown,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final ApiErrorType type;
  final Object? cause;

  factory ApiException.fromDio(DioException error) {
    final statusCode = error.response?.statusCode;
    return ApiException(
      _messageFrom(error.response?.data) ?? _defaultMessage(error, statusCode),
      statusCode: statusCode,
      type: _typeFrom(error, statusCode),
      cause: error,
    );
  }

  static ApiErrorType _typeFrom(DioException error, int? statusCode) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiErrorType.timeout;
    }
    if (error.type == DioExceptionType.connectionError) {
      return ApiErrorType.network;
    }
    if (error.type == DioExceptionType.cancel) {
      return ApiErrorType.cancelled;
    }
    return switch (statusCode) {
      400 => ApiErrorType.badRequest,
      401 => ApiErrorType.unauthorized,
      403 => ApiErrorType.forbidden,
      404 => ApiErrorType.notFound,
      final code? when code >= 500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };
  }

  static String _defaultMessage(DioException error, int? statusCode) =>
      switch (_typeFrom(error, statusCode)) {
        ApiErrorType.badRequest => '요청 정보를 다시 확인해주세요.',
        ApiErrorType.unauthorized => '로그인이 필요하거나 세션이 만료되었습니다.',
        ApiErrorType.forbidden => '이 작업을 수행할 권한이 없습니다.',
        ApiErrorType.notFound => '요청한 정보를 찾을 수 없습니다.',
        ApiErrorType.server => '서버에 문제가 발생했습니다. 잠시 후 다시 시도해주세요.',
        ApiErrorType.timeout => '요청 시간이 초과되었습니다. 네트워크를 확인해주세요.',
        ApiErrorType.network => '네트워크 연결을 확인해주세요.',
        ApiErrorType.cancelled => '요청이 취소되었습니다.',
        ApiErrorType.unknown => '알 수 없는 네트워크 오류가 발생했습니다.',
      };

  static String? _messageFrom(Object? body) {
    if (body is! Map) {
      return null;
    }
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return body['message'] is String ? body['message'] as String : null;
  }

  @override
  String toString() => message;
}
