import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/core/network/network_providers.dart';
import 'package:blick/features/auth/data/models/login_response.dart';
import 'package:blick/features/auth/data/repositories/auth_repository.dart';
import 'package:blick/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fake 로그인은 실패와 성공 상태를 표시하고 학생 세션을 갱신한다', () async {
    final client = ApiClient(baseUrl: '', offline: true);
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    addTearDown(client.dispose);
    addTearDown(container.dispose);

    expect(
      (await container.read(authSessionProvider.future)).status,
      AuthenticationState.expired,
    );

    final controller = container.read(loginProvider.notifier);
    final rejected = controller.submit(
      email: 'student@example.test',
      password: 'wrong-password',
    );
    expect(container.read(loginProvider).isLoading, isTrue);
    await rejected;
    expect(container.read(loginProvider).error, isA<ApiException>());
    expect(client.session.value, AuthenticationState.expired);

    await controller.submit(
      email: 'student@example.test',
      password: 'blick-test',
    );

    expect(container.read(loginProvider).hasError, isFalse);
    final signedIn = container.read(authSessionProvider).requireValue;
    expect(signedIn.status, AuthenticationState.authenticated);
    expect(signedIn.student?.email, 'student@example.test');

    await container.read(authSessionProvider.notifier).logout();
    final signedOut = container.read(authSessionProvider).requireValue;
    expect(signedOut.status, AuthenticationState.expired);
    expect(signedOut.student, isNull);
  });

  test('학생이 아닌 응답으로 로그인 세션을 시작하지 않는다', () async {
    final client = ApiClient(baseUrl: '', offline: true);
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(client),
        authRepositoryProvider.overrideWithValue(_StaffRepository()),
      ],
    );
    addTearDown(client.dispose);
    addTearDown(container.dispose);

    await container.read(authSessionProvider.future);
    await container
        .read(loginProvider.notifier)
        .submit(email: 'staff@example.test', password: 'password');

    expect(
      container.read(loginProvider).error,
      isA<ApiException>().having(
        (error) => error.message,
        'message',
        '학생 계정으로 로그인해주세요.',
      ),
    );
    expect(client.session.value, AuthenticationState.expired);
  });

  test('보안 저장소의 토큰 쌍과 기존 학생 정보를 복원한다', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final previousClient = ApiClient(
      baseUrl: '',
      secureStorage: const FlutterSecureStorage(),
    );
    await previousClient.startSession(
      const AuthTokens(
        accessToken: 'saved-access',
        refreshToken: 'saved-refresh',
      ),
      student: const SessionStudent(
        username: '복원된 학생',
        email: 'saved@example.test',
      ),
    );
    previousClient.dispose();

    final client = ApiClient(
      baseUrl: '',
      secureStorage: const FlutterSecureStorage(),
    );
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(client)],
    );
    addTearDown(client.dispose);
    addTearDown(container.dispose);

    final session = await container.read(authSessionProvider.future);
    expect(session.status, AuthenticationState.authenticated);
    expect(session.student?.username, '복원된 학생');
    expect(session.student?.email, 'saved@example.test');
  });
}

class _StaffRepository extends FakeAuthRepository {
  @override
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async => const LoginResponse(
    accessToken: 'staff-access',
    refreshToken: 'staff-refresh',
    username: '교직원',
    role: 'TEACHER',
  );
}
