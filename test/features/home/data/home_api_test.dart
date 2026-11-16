import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('미탑승 신청과 취소는 같은 경로에 다른 HTTP 메서드를 사용한다', () async {
    final requests = <RequestOptions>[];
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests.add(options);
            handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'success': true,
                  'data': {'success': true, 'message': '변경 완료'},
                },
              ),
            );
          },
        ),
      );
    final api = HomeApi(dio: dio);

    await api.applyAbsent(const AbsentRequest(reason: '별도 귀가'));
    await api.applyAbsent(const AbsentRequest());
    await api.cancelAbsent();

    expect(requests.map((request) => request.path), [
      '/student/attendance/absent',
      '/student/attendance/absent',
      '/student/attendance/absent',
    ]);
    expect(requests.map((request) => request.method), [
      'POST',
      'POST',
      'DELETE',
    ]);
    expect(requests[0].data, {'reason': '별도 귀가'});
    expect(requests[1].data, isEmpty);
    expect(requests[2].data, isNull);
  });
}
