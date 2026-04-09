import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart'; // 👈 로그인 화면 import

void main() {
  runApp(const MyApp()); // 👈 앱 시작
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
