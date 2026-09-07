class SignupResponseData {
  final bool success;
  final String message;
  final String username;

  SignupResponseData({
    required this.success,
    required this.message,
    required this.username,
  });
  // JSON(Map)을 받아 SignupResponse 객체로 변환하는 생성자
  // JSON을 받아 SignupResponse 객체를 만들어 반환하는 factory 생성자
  factory SignupResponseData.fromJson(Map<String, dynamic> json) {
    return SignupResponseData(
      //Json에서 값을 꺼내 해당형태의 타입이 맞는지 대조
      success: json["success"] as bool,
      message: json["message"] as String,
      username: json["username"] as String,
    );
  }
}
