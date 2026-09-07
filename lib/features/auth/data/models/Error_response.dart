class ErrorResponse {
  final String code;
  final String message;
  final DateTime? timestamp;
  final Map<String, dynamic>?  details;


  ErrorResponse({
    required this.code,
    required this.message,
    required this.timestamp,
    required this.details,
  });


  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: Map<String, dynamic> .from(json['details'] as Map),
    );
  }
}