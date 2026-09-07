class LoginResponse {
  // LoginResponse가 가지는 액세스 토큰. String이며 생성 후 변경 불가
  final String accessToken;

  // LoginResponse가 가지는 리프레시 토큰
  final String refreshToken;

  // LoginResponse 객체를 만드는 생성자
  // 두 값을 반드시 전달해야 함
  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  // JSON(Map)을 받아 LoginResponse 객체로 변환하는 생성자
  // factory는 생성자에서 객체를 반환할때 사용
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      // JSON의 accessToken 값을 꺼내 String으로 확인해서 넣음
      accessToken: json['accessToken'] as String,

      // JSON의 refreshToken 값도 동일
      refreshToken: json['refreshToken'] as String,
    );
  }
}