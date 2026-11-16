import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/models/route_query.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

const _query = RouteQuery(
  start: (latitude: 35.8, longitude: 128.4),
  end: (latitude: 35.9, longitude: 128.6),
);

void main() {
  test('두 경로 API는 같은 위경도 쿼리를 GET으로 보내고 응답을 변환한다', () async {
    final requests = <RequestOptions>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            requests.add(request);
            final payload = request.path == '/api/route/summary'
                ? {
                    'distance': 12300,
                    'distanceKm': 12.3,
                    'duration': 1320,
                    'durationMinutes': 22,
                    'taxiFare': 14000,
                    'toll': 0,
                  }
                : {'opaque': <String, dynamic>{}};
            handler.resolve(
              Response(
                requestOptions: request,
                data: {'success': true, 'data': payload},
              ),
            );
          },
        ),
      );
    final api = HomeApi(dio: dio);

    final detail = await api.getRoute(_query);
    final summary = await api.getRouteSummaryFor(_query);
    expect(requests.map((request) => request.path), [
      '/api/route',
      '/api/route/summary',
    ]);
    for (final request in requests) {
      expect(request.method, 'GET');
      expect(request.queryParameters, {
        'startLat': 35.8,
        'startLng': 128.4,
        'endLat': 35.9,
        'endLng': 128.6,
      });
    }
    expect(detail.data, {'opaque': <String, dynamic>{}});
    expect(summary.data?.distanceKm, 12.3);
    expect(summary.data?.durationMinutes, 22);
  });

  test('유효하지 않은 위경도는 네트워크 요청을 보내지 않는다', () async {
    var calls = 0;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            calls++;
            handler.reject(DioException(requestOptions: request));
          },
        ),
      );
    final api = HomeApi(dio: dio);
    const invalid = RouteQuery(
      start: (latitude: double.nan, longitude: 128.4),
      end: (latitude: 35.9, longitude: 200),
    );

    await expectLater(api.getRoute(invalid), throwsArgumentError);
    await expectLater(api.getRouteSummaryFor(invalid), throwsArgumentError);
    expect(calls, 0);
  });

  test('요약 응답의 타입 오류를 경로 조회 오류로 바꾼다', () async {
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) => handler.resolve(
            Response(
              requestOptions: request,
              data: {
                'success': true,
                'data': {'distance': 'invalid'},
              },
            ),
          ),
        ),
      );

    await expectLater(
      HomeApi(dio: dio).getRouteSummaryFor(_query),
      throwsA(isA<ApiException>()),
    );
  });
}
