class SignupResponseData {
  final bool success;
  final String message;
  final String username;

  SignupResponseData({
    required this.success,
    required this.message,
    required this.username,
  });

  /// 서버 응답의 `data` 객체를 Dart 모델로 바꿉니다.
  factory SignupResponseData.fromJson(Map<String, dynamic> json) {
    return SignupResponseData(
      success: json['success'] as bool,
      message: json['message'] as String,
      username: json['username'] as String,
    );
  }
}
