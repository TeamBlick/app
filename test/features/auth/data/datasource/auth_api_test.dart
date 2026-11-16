import 'package:blick/features/auth/data/datasource/auth_api.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('signup sends the Swagger DTO and reads its data envelope', () async {
    RequestOptions? captured;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {
                  'success': true,
                  'message': '회원가입 완료',
                  'data': {
                    'success': true,
                    'message': '회원가입 완료',
                    'username': 'blick',
                  },
                },
              ),
            );
          },
        ),
      );
    final request = SignupRequest(
      username: 'blick',
      name: '빛',
      email: 'blick@dgsw.hs.kr',
      password: 'password123',
      confirmPassword: 'password123',
      studentNumber: '2401',
      grade: 2,
      classNumber: 4,
    );

    final signup = await AuthApi(dio: dio).signup(request);

    expect(captured!.path, '/auth/signup');
    expect(captured!.data, request.toJson());
    expect(signup.username, 'blick');
  });
}
