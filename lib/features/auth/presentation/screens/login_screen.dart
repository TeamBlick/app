import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blick/core/fun/controllers/speki_easter_egg_controller.dart';
import 'package:blick/core/fun/widgets/speki_easter_egg.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/datasource/auth_api.dart';
import 'package:blick/features/auth/presentation/widgets/another_input.dart';
import 'package:blick/features/auth/presentation/screens/signup_screen.dart';
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
  final _authApi = AuthApi();
  bool _isSubmitting = false;

  Future<void> _login() async {
    final email = idController.text.trim();
    final password = pwController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _authApi.login(email: email, password: password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

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
                          label: '이메일',
                          hint: '이메일을 입력해주세요',
                          controller: idController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),

                        const SizedBox(height: 40),

                        AnotherInput(
                          label: '비밀번호',
                          hint: '비밀번호를 입력해주세요',
                          obscure: true,
                          controller: pwController,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_isSubmitting) _login();
                          },
                        ),

                        const SizedBox(height: 50),

                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5366FB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    '로그인',
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Center(
                          child: TextButton(
                            onPressed: _isSubmitting
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignupScreen(),
                                      ),
                                    );
                                  },
                            child: const Text('회원가입'),
                          ),
                        ),

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
