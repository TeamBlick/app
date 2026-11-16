import 'dart:convert';
import 'dart:typed_data';

import 'package:blick/features/auth/presentation/screens/login_screen.dart';
import 'package:blick/features/home/presentation/screens/home_screen.dart';
import 'package:blick/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('앱 시작과 오프라인 로그인에 서버 URL 및 카카오 키를 요구하지 않는다', (tester) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      expect(utf8.decode(message!.buffer.asUint8List()), '.env');
      return ByteData.sublistView(
        Uint8List.fromList(
          utf8.encode(
            'API_BASE_URL=\nKAKAO_JAVASCRIPT_KEY=\nBLICK_FAKE_AUTH=true\n',
          ),
        ),
      );
    });
    try {
      await app.main();
    } finally {
      messenger.setMockMessageHandler('flutter/assets', null);
    }
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'student@example.test');
    await tester.enterText(fields.at(1), 'blick-test');
    final loginButton = find.widgetWithText(ElevatedButton, '로그인');
    await tester.ensureVisible(loginButton);
    await tester.tap(loginButton);
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('테스트 경로'), findsOneWidget);
    tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar)).onTap!(
      2,
    );
    await tester.pumpAndSettle();
    expect(find.text('테스트 QR 선택'), findsOneWidget);
  });
}
