class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.username,
    required this.role,
  });

  final String accessToken;
  final String refreshToken;
  final String username;
  final String role;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }
}
