import 'package:blick/core/network/api_client.dart';
import 'package:blick/features/auth/presentation/providers/auth_providers.dart';
import 'package:blick/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:blick/features/auth/presentation/screens/login_screen.dart'; // 👈 로그인 화면 import
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart'; // 카카오맵 플러그인 import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  final kakaoKey = dotenv.env['KAKAO_JAVASCRIPT_KEY'];

  if (!ApiClient.useFakeAuth) {
    if (kakaoKey == null || kakaoKey.trim().isEmpty) {
      throw StateError('KAKAO_JAVASCRIPT_KEY가 .env에 없습니다.');
    }
    AuthRepository.initialize(appKey: kakaoKey);
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);
    final status = session.valueOrNull?.status;

    return MaterialApp(
      key: ValueKey(status),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Pretendard'),
      home: session.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : status == AuthenticationState.authenticated
          ? const HomeScreen()
          : const LoginScreen(),
    );
  }
}
