import 'package:blick/core/network/blick_api.dart';
import 'package:blick/features/qr/data/qr_attendance.dart';
import 'package:blick/features/qr/presentation/screens/qr_tab.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QR 출석 API가 문서의 명칭으로 요청과 결과를 처리한다', () async {
    RequestOptions? request;
    final dio = Dio()
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            request = options;
            handler.resolve(
              Response(
                requestOptions: options,
                data: {
                  'success': true,
                  'data': {
                    'success': true,
                    'message': '출석 완료',
                    'checkTime': '2026-11-16T12:30:00',
                    'busName': '1호차',
                  },
                },
              ),
            );
          },
        ),
      );

    final response = await BlickApi(dio: dio).checkQrAttendance(
      const QrAttendanceRequest(token: 'fixture', busId: 3, timestamp: 123),
    );
    expect(request!.method, 'POST');
    expect(request!.path, '/student/bus/check/qr');
    expect(request!.data, {'token': 'fixture', 'busId': 3, 'timestamp': 123});
    expect(response.data?.success, isTrue);
    expect(response.data?.busName, '1호차');
  });

  testWidgets('시연 QR에서 실패 후 재시도와 중복 출석을 확인한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: QrTab(
          demoRepository: FakeQrAttendanceRepository(delay: Duration.zero),
        ),
      ),
    );

    Future<void> choose(String label) async {
      await tester.tap(find.text('테스트 QR 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    await choose('만료된 QR');
    expect(find.text('만료된 QR입니다.'), findsOneWidget);
    await choose('잘못된 QR');
    expect(find.text('올바른 출석 QR이 아닙니다.'), findsOneWidget);
    await choose('정상 QR');
    expect(find.text('테스트 출석을 확인했습니다.'), findsOneWidget);
    await choose('정상 QR');
    expect(find.text('이미 출석을 확인했습니다.'), findsOneWidget);
  });
}
