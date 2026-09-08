import 'dart:convert';

import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    '401 requests share one refresh and retry once with the new token',
    () async {
      var refreshCalls = 0;
      final store = TokenStore()
        ..save(
          const AuthTokens(accessToken: 'old-access', refreshToken: 'refresh'),
        );
      final dio = Dio()..httpClientAdapter = _TokenAwareAdapter();
      final client = ApiClient(
        baseUrl: 'https://example.test',
        dio: dio,
        tokenStore: store,
        enableLogging: false,
        refreshTokens: (refreshToken) async {
          refreshCalls++;
          expect(refreshToken, 'refresh');
          return const AuthTokens(
            accessToken: 'new-access',
            refreshToken: 'new-refresh',
          );
        },
      );
      final responses = await Future.wait([
        client.dio.get<Object>('/student/first'),
        client.dio.get<Object>('/student/second'),
      ]);

      expect(refreshCalls, 1);
      expect(
        responses.map((response) => response.statusCode),
        everyElement(200),
      );
      expect(store.accessToken, 'new-access');
    },
  );

  test('Dio status and timeout failures have distinct common error types', () {
    final options = RequestOptions(path: '/student/bus');
    final forbidden = ApiException.fromDio(
      DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 403),
        type: DioExceptionType.badResponse,
      ),
    );
    final timeout = ApiException.fromDio(
      DioException(
        requestOptions: options,
        type: DioExceptionType.receiveTimeout,
      ),
    );

    expect(forbidden.type, ApiErrorType.forbidden);
    expect(timeout.type, ApiErrorType.timeout);
  });
}

class _TokenAwareAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final hasNewAccessToken =
        options.headers['Authorization'] == 'Bearer new-access';
    return ResponseBody.fromString(
      jsonEncode(hasNewAccessToken ? {'ok': true} : {'message': 'expired'}),
      hasNewAccessToken ? 200 : 401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
