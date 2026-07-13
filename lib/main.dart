import 'package:flutter/material.dart';
import 'package:blick/features/auth/presentation/screens/login_screen.dart'; // 👈 로그인 화면 import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오맵 플러그인 import

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  final kakaoKey = dotenv.env['KAKAO_JAVASCRIPT_KEY'];

  if (kakaoKey == null || kakaoKey.isEmpty) {
    throw Exception('KAKAO_JAVASCRIPT_KEY가 없습니다.');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Pretendard', // 앱 전체 기본 폰트
      ),
      home: const LoginScreen(), // 👈 첫 화면을 LoginScreen으로 지정
    );
  }
}
