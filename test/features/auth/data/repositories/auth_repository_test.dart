import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('가입한 테스트 계정으로 로그인할 수 있다', () async {
    final repository = FakeAuthRepository();
    final signup = await repository.signup(
      SignupRequest(
        username: '새 학생',
        email: 'new@example.test',
        password: 'password123',
        confirmPassword: 'password123',
        studentNumber: '2401',
        grade: 2,
        classNumber: 4,
      ),
    );
    final login = await repository.login(
      email: 'new@example.test',
      password: 'password123',
    );

    expect(signup.success, isTrue);
    expect(login.username, '새 학생');
    expect(login.role, 'STUDENT');
    expect(login.accessToken, 'fake-access');
  });

  test('잘못된 비밀번호는 인증에 실패한다', () async {
    final repository = FakeAuthRepository();

    await expectLater(
      repository.login(
        email: 'student@example.test',
        password: 'wrong-password',
      ),
      throwsA(isA<ApiException>()),
    );
  });
}
