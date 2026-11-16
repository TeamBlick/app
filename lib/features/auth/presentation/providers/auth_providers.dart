import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/network_providers.dart';
import 'package:blick/features/auth/data/datasource/auth_api.dart';
import 'package:blick/features/auth/data/models/Signup_request.dart';
import 'package:blick/features/auth/data/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef AuthSession = ({AuthenticationState status, SessionStudent? student});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => ref.watch(fakeModeProvider)
      ? FakeAuthRepository()
      : AuthApi(dio: ref.watch(dioProvider)),
);

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSession>(
      AuthSessionController.new,
    );

class AuthSessionController extends AsyncNotifier<AuthSession> {
  @override
  Future<AuthSession> build() async {
    final client = ref.watch(apiClientProvider);
    AuthSession readSession() =>
        (status: client.session.value, student: client.student);

    var active = true;
    void syncSession() => state = AsyncData(readSession());
    ref.onDispose(() {
      active = false;
      client.session.removeListener(syncSession);
    });

    try {
      await client.loadSession();
    } catch (_) {
      debugPrint('저장된 로그인 상태를 불러오지 못했습니다.');
    }

    if (active) client.session.addListener(syncSession);
    return readSession();
  }

  Future<void> logout() => ref.read(apiClientProvider).endSession();
}

final loginProvider = NotifierProvider<LoginController, AsyncValue<void>>(
  LoginController.new,
);

class LoginController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit({required String email, required String password}) async {
    if (state.isLoading) return;
    final repository = ref.read(authRepositoryProvider);
    final client = ref.read(apiClientProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final login = await repository.login(email: email, password: password);
      if (login.role != 'STUDENT') {
        throw const ApiException('학생 계정으로 로그인해주세요.');
      }
      if (login.accessToken.isEmpty || login.refreshToken.isEmpty) {
        throw const ApiException('로그인 토큰을 발급받지 못했습니다.');
      }

      try {
        await client.startSession(
          AuthTokens(
            accessToken: login.accessToken,
            refreshToken: login.refreshToken,
          ),
          student: SessionStudent(username: login.username, email: email),
        );
      } catch (_) {
        throw const ApiException('로그인 정보를 저장하지 못했습니다. 다시 시도해주세요.');
      }
    });
  }
}

final signupProvider = NotifierProvider<SignupController, AsyncValue<void>>(
  SignupController.new,
);

class SignupController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit(SignupRequest request) async {
    if (state.isLoading) return;
    final repository = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await repository.signup(request);
    });
  }
}
