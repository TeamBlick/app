import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/models/Signup_response.dart';
import 'package:blick/features/auth/data/models/login_response.dart';

abstract interface class AuthRepository {
  Future<LoginResponse> login({
    required String email,
    required String password,
  });
  Future<SignupResponseData> signup(SignupRequest request);
}

class FakeAuthRepository implements AuthRepository {
  final _accounts = <String, ({String username, String password})>{
    'student@example.test': (username: '테스트 학생', password: 'blick-test'),
  };
  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final account = _accounts[email];
    if (account == null || account.password != password) {
      throw const ApiException('이메일 또는 비밀번호가 일치하지 않습니다.');
    }
    return LoginResponse(
      accessToken: 'fake-access',
      refreshToken: 'fake-refresh',
      username: account.username,
      role: 'STUDENT',
    );
  }

  @override
  Future<SignupResponseData> signup(SignupRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (_accounts.containsKey(request.email)) {
      throw const ApiException('이미 사용 중인 이메일입니다.');
    }
    _accounts[request.email] = (
      username: request.username,
      password: request.password,
    );
    return SignupResponseData(
      success: true,
      message: '회원가입 완료',
      username: request.username,
    );
  }
}
