import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/auth/data/datasource/auth_api.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/presentation/widgets/another_input.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authApi = AuthApi();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _gradeController = TextEditingController();
  final _classNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final grade = int.tryParse(_gradeController.text.trim());
    final classNumber = int.tryParse(_classNumberController.text.trim());
    if (grade == null || classNumber == null || grade < 1 || classNumber < 1) {
      _showMessage('학년과 반은 1 이상의 숫자로 입력해주세요.');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _authApi.signup(
        SignupRequest(
          username: _usernameController.text.trim(),
          name: _emptyToNull(_nameController.text),
          email: _emailController.text.trim(),
          studentNumber: _studentNumberController.text.trim(),
          grade: grade,
          classNumber: classNumber,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ),
      );
      if (!mounted) return;
      _showMessage('회원가입이 완료되었습니다. 로그인해주세요.');
      Navigator.of(context).pop();
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _studentNumberController.dispose();
    _gradeController.dispose();
    _classNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(40, 24, 40, 40),
            children: [
              const Text(
                'Blick 계정 만들기',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text('가입 정보를 입력해주세요.'),
              const SizedBox(height: 32),
              _requiredInput('아이디', '아이디를 입력해주세요', _usernameController),
              _optionalInput('이름 (선택)', '이름을 입력해주세요', _nameController),
              _requiredInput(
                '이메일',
                '이메일을 입력해주세요',
                _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              _requiredInput(
                '학번',
                '예: 2401',
                _studentNumberController,
                keyboardType: TextInputType.number,
              ),
              Row(
                children: [
                  Expanded(
                    child: _requiredInput(
                      '학년',
                      '예: 2',
                      _gradeController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _requiredInput(
                      '반',
                      '예: 4',
                      _classNumberController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _requiredInput(
                '비밀번호',
                '비밀번호를 입력해주세요',
                _passwordController,
                obscure: true,
              ),
              _requiredInput(
                '비밀번호 확인',
                '비밀번호를 다시 입력해주세요',
                _confirmPasswordController,
                obscure: true,
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5366FB),
                    foregroundColor: Colors.white,
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
                      : const Text('회원가입'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _requiredInput(
    String label,
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnotherInput(
            label: label,
            hint: hint,
            controller: controller,
            obscure: obscure,
            keyboardType: keyboardType,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return '$label을 입력해주세요.';
              if (label == '이메일' && !text.contains('@')) {
                return '올바른 이메일을 입력해주세요.';
              }
              if (label == '비밀번호 확인' && value != _passwordController.text) {
                return '비밀번호가 일치하지 않습니다.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _optionalInput(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AnotherInput(label: label, hint: hint, controller: controller),
    );
  }
}
