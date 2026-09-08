import 'error_response.dart';

class ApiResponse<T> {
  final T data;
  final bool success;
  final String message;
  final ErrorResponse? error;

  ApiResponse({
    required this.data,
    required this.success,
    required this.message,
    required this.error,
  });

  // 생성자 작성
  factory ApiResponse.fromJson(Map<String, dynamic> json,
  T Function(Map<String,dynamic>) fromJsonT,) {
    return ApiResponse(
      data: fromJsonT(json['data'] as Map<String, dynamic>),
      success: json['success'] as bool,
      message: json['message'] as String,
      error: json['error'] == null ? null :
        ErrorResponse.fromJson(
          json['error'] as Map<String, dynamic>,
        ),
    );
  }
}
