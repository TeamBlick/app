import 'package:blick/features/bus/data/datasource/student_bus_api.dart';
import 'package:blick/features/bus/data/models/student_bus_models.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('버스 변경은 DTO를 JSON으로 보내고 DTO로 응답을 받는다', () async {
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
                  'message': '변경 완료',
                  'data': {
                    'success': true,
                    'message': '변경 완료',
                    'newBusNumber': '2호차',
                  },
                },
              ),
            );
          },
        ),
      );

    final result = await StudentBusApi(
      dio: dio,
    ).changeBus(const BusChangeRequest(newBusId: 2));

    expect(captured!.path, '/student/bus/change');
    expect(captured!.data, {'newBusId': 2});
    expect(result.data?.newBusNumber, '2호차');
  });
}
