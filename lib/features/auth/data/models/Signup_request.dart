class SignupRequest {
  /// Swagger의 `SignupRequestDto` 필드와 이름을 맞춘 회원가입 요청 모델입니다.
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
  final String studentNumber;
  final int grade;
  final int classNumber;
  final String? name;

  SignupRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.studentNumber,
    required this.grade,
    required this.classNumber,
    this.name,
  });

  /// Dio는 이 Map을 JSON request body로 직렬화합니다.
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'studentNumber': studentNumber,
      'grade': grade,
      'classNumber': classNumber,
      if (name != null) 'name': name,
    };
  }
}
