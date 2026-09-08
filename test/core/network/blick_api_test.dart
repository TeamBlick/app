import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/api_response.dart';
import 'package:blick/core/network/blick_api.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/models/Signup_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route summary uses Swagger query parameter names', () async {
    RequestOptions? captured;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'message': 'ok',
                  'data': {'distanceKm': 12.4},
                },
              ),
            );
          },
        ),
      );

    final response = await BlickApi(dio: dio).getRouteSummary(
      startLat: 35.1,
      startLng: 128.1,
      endLat: 35.2,
      endLng: 128.2,
    );

    expect(captured!.method, 'GET');
    expect(captured!.path, '/api/route/summary');
    expect(captured!.queryParameters, {
      'startLat': 35.1,
      'startLng': 128.1,
      'endLat': 35.2,
      'endLng': 128.2,
    });
    expect(response.data, {'distanceKm': 12.4});
  });

  test('API envelope errors become ApiException messages', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 401,
                data: {
                  'success': false,
                  'error': {'message': '이메일 또는 비밀번호가 일치하지 않습니다.'},
                },
              ),
            );
          },
        ),
      );

    await expectLater(
      BlickApi(
        dio: dio,
      ).login({'email': 'student@dgsw.hs.kr', 'password': 'password'}),
      throwsA(
        isA<ApiException>().having(
          (error) => error.message,
          'message',
          '이메일 또는 비밀번호가 일치하지 않습니다.',
        ),
      ),
    );
  });

  test('signup converts request and response JSON to DTO models', () async {
    RequestOptions? captured;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            captured = options;
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
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
      email: 'blick@dgsw.hs.kr',
      password: 'password123',
      confirmPassword: 'password123',
      studentNumber: '2401',
      grade: 2,
      classNumber: 4,
    );

    final response = await BlickApi(dio: dio).signup(request);

    expect(response, isA<ApiResponse<SignupResponseData>>());
    expect(response.data?.username, 'blick');
    expect(captured!.path, '/auth/signup');
    expect(captured!.data, request.toJson());
  });
}
