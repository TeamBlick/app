import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blick/core/fun/controllers/speki_easter_egg_controller.dart';
import 'package:blick/core/fun/widgets/speki_easter_egg.dart';
import 'package:blick/features/auth/presentation/widgets/another_input.dart';
import 'package:blick/features/home/presentation/screens/home_screen.dart'; // 👈 홈 화면 import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final Uri _dodamLoginUri = Uri.parse('https://dodam.b1nd.com/');

  final idController = TextEditingController();
  final pwController = TextEditingController();
  final _spekiController = SpekiEasterEggController();

  @override
  void dispose() {
    idController.dispose();
    pwController.dispose();
    _spekiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; // 👈 화면 크기 가져오기
    final logoWidth = size.width * 0.32; // 👈 화면 비율 기반 로고 크기

    return Scaffold(
      backgroundColor: Colors.white,
      body: SpekiEasterEgg(
        controller: _spekiController,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _spekiController.handleLogoTap,
                          child: Center(
                            child: Image.asset(
                              'assets/images/App_Logo.png',
                              width: logoWidth.clamp(120.0, 200.0),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        AnotherInput(
                          label: '아이디',
                          hint: '아이디를 입력해주세요',
                          controller: idController,
                        ),

                        const SizedBox(height: 40),

                        AnotherInput(
                          label: '비밀번호',
                          hint: '비밀번호를 입력해주세요',
                          obscure: true,
                          controller: pwController,
                        ),

                        const SizedBox(height: 50),

                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final id = idController.text.trim();
                              final pw = pwController.text.trim();

                              if (id.isEmpty || pw.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('아이디와 비밀번호를 입력해주세요'),
                                  ),
                                );
                                return;
                              }

                              if (id == 'admin' && pw == '1234') {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('아이디 또는 비밀번호가 올바르지 않습니다'),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5366FB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              '로그인',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('도담도담으로 '),
                              TextButton(
                                onPressed: () async {
                                  if (await canLaunchUrl(_dodamLoginUri)) {
                                    await launchUrl(
                                      _dodamLoginUri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF4F6BFF),
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '로그인',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Text('하기'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
