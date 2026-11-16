import 'package:blick/core/network/api_client.dart';
import 'package:blick/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:blick/features/auth/presentation/screens/login_screen.dart'; // 👈 로그인 화면 import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오맵 플러그인 import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final kakaoKey = dotenv.env['KAKAO_JAVASCRIPT_KEY'];

  if (kakaoKey == null || kakaoKey.trim().isEmpty) {
    throw Exception('KAKAO_JAVASCRIPT_KEY가 .env에 없습니다.');
  }

  AuthRepository.initialize(appKey: kakaoKey);

  try {
    await ApiClient.restoreSession();
  } catch (_) {
    debugPrint('저장된 로그인 상태를 불러오지 못했습니다.');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthenticationState>(
      valueListenable: ApiClient.authenticationState,
      builder: (context, state, _) => MaterialApp(
        key: ValueKey(state),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Pretendard'),
        home: state == AuthenticationState.authenticated
            ? const HomeScreen()
            : const LoginScreen(),
      ),
    );
  }
}
