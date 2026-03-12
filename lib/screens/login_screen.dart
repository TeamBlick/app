import 'package:flutter/material.dart';
import '../widgets/another_input.dart';
import 'home_screen.dart'; // 👈 홈 화면 import

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 👈 화면 크기 가져오기
    final logoWidth = size.width * 0.32; // 👈 화면 비율 기반 로고 크기

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // 👈 키보드 올라올 때 대응
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  "assets/images/App_Logo.png",
                  width: logoWidth,
                ),
              ),

              const SizedBox(height: 40),

              const AnotherInput(
                label: "아이디",
                hint: "아이디를 입력해주세요",
              ),

              const SizedBox(height: 40),

              const AnotherInput(
                label: "비밀번호",
                hint: "비밀번호를 입력해주세요",
                obscure: true,
              ),

              const SizedBox(height: 50),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 👇 여기서 화면 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),// HomeScreen에 const 생성자 추가해야 함
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(83, 102, 251, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "로그인",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    // TODO: 웹 로그인 연동(SAML/OAuth 등) 시 여기서 처리
                  },
                  child: const Text(
                    '도담도담으로 로그인하기',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF4F6BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
