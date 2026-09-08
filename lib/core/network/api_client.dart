import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthTokens {
  const AuthTokens({required this.accessToken, required this.refreshToken});
  final String accessToken;
  final String refreshToken;
}

/// 저장 구현을 분리해 두어 secure storage로 바꿔도 인증 로직은 유지됩니다.
class TokenStore {
  String? accessToken;
  String? refreshToken;
  void save(AuthTokens tokens) {
    accessToken = tokens.accessToken;
    refreshToken = tokens.refreshToken;
  }

  void clear() {
    accessToken = null;
    refreshToken = null;
  }
}

enum AuthenticationState { authenticated, expired }

typedef RefreshTokens = Future<AuthTokens> Function(String refreshToken);

/// 모든 실제 API가 공유하는 Dio 설정과 인증 인터셉터입니다.
class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    TokenStore? tokenStore,
    RefreshTokens? refreshTokens,
    bool? enableLogging,
  }) : _tokens = tokenStore ?? TokenStore(),
       _refreshTokens = refreshTokens,
       dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 10),
               sendTimeout: const Duration(seconds: 10),
               headers: const {
                 Headers.contentTypeHeader: Headers.jsonContentType,
                 Headers.acceptHeader: 'application/json',
               },
             ),
           ) {
    this.dio.options.baseUrl = baseUrl;
    this.dio.options.connectTimeout = const Duration(seconds: 10);
    this.dio.options.receiveTimeout = const Duration(seconds: 10);
    this.dio.options.sendTimeout = const Duration(seconds: 10);
    this.dio.options.headers.addAll(const {
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: 'application/json',
    });
    this.dio.interceptors.add(_AuthenticationInterceptor(this));
    if (enableLogging ?? kDebugMode) {
      this.dio.interceptors.add(_SafeLogInterceptor());
    }
  }

  static final ApiClient _shared = ApiClient(baseUrl: _baseUrlFromEnv());
  static Dio get instance => _shared.dio;
  static ValueListenable<AuthenticationState> get authenticationState =>
      _shared._authenticationState;
  final Dio dio;
  final TokenStore _tokens;
  final RefreshTokens? _refreshTokens;
  final ValueNotifier<AuthenticationState> _authenticationState = ValueNotifier(
    AuthenticationState.expired,
  );
  Future<AuthTokens>? _refreshInFlight;

  static String _baseUrlFromEnv() {
    final baseUrl = dotenv.env['API_BASE_URL'];
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw StateError('API_BASE_URL이 .env에 없습니다.');
    }
    return baseUrl;
  }

  static void setTokens(AuthTokens tokens) => _shared._setTokens(tokens);
  static void setAccessToken(String? accessToken) {
    if (accessToken == null || accessToken.isEmpty) {
      _shared._clearTokens();
      return;
    }
    _shared._tokens.accessToken = accessToken;
    _shared._authenticationState.value = AuthenticationState.authenticated;
  }

  static void clearTokens() => _shared._clearTokens();
  void _setTokens(AuthTokens tokens) {
    _tokens.save(tokens);
    _authenticationState.value = AuthenticationState.authenticated;
  }

  void _clearTokens() {
    _tokens.clear();
    _authenticationState.value = AuthenticationState.expired;
  }

  Future<AuthTokens> refreshAccessToken() {
    final refreshToken = _tokens.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      return Future<AuthTokens>.error(StateError('갱신할 refresh token이 없습니다.'));
    }
    return _refreshInFlight ??= _performRefresh(refreshToken).whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<AuthTokens> _performRefresh(String refreshToken) async {
    final tokens = _refreshTokens != null
        ? await _refreshTokens(refreshToken)
        : await _requestRefresh(refreshToken);
    _setTokens(tokens);
    return tokens;
  }

  Future<AuthTokens> _requestRefresh(String refreshToken) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: dio.options.baseUrl,
        connectTimeout: dio.options.connectTimeout,
        receiveTimeout: dio.options.receiveTimeout,
        sendTimeout: dio.options.sendTimeout,
        headers: const {
          Headers.contentTypeHeader: Headers.jsonContentType,
          Headers.acceptHeader: 'application/json',
        },
      ),
    );
    final response = await refreshDio.post<Object>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final body = response.data;
    final data = body is Map && body['data'] is Map ? body['data'] : body;
    if (data is! Map || data['accessToken'] is! String) {
      throw StateError('토큰 갱신 응답 형식이 올바르지 않습니다.');
    }
    return AuthTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: (data['refreshToken'] as String?) ?? refreshToken,
    );
  }
}

class _AuthenticationInterceptor extends QueuedInterceptor {
  _AuthenticationInterceptor(this._client);
  final ApiClient _client;
  static const _retriedKey = 'authRetryAttempted';
  bool _isAuthRequest(RequestOptions options) =>
      options.path.startsWith('/auth/');
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isAuthRequest(options)) {
      final accessToken = _client._tokens.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    if (error.response?.statusCode != 401 ||
        _isAuthRequest(options) ||
        options.extra[_retriedKey] == true) {
      handler.next(error);
      return;
    }
    try {
      final currentToken = _client._tokens.accessToken;
      final tokenUsedForRequest = options.headers['Authorization'];
      // 대기 중이던 다른 요청은 refresh 완료 전의 토큰으로 401을 받을 수 있다.
      // 이 경우 refresh를 다시 보내지 않고 새 토큰으로 한 번만 재시도한다.
      final accessToken =
          currentToken != null &&
              currentToken.isNotEmpty &&
              tokenUsedForRequest != 'Bearer $currentToken'
          ? currentToken
          : (await _client.refreshAccessToken()).accessToken;
      options.headers['Authorization'] = 'Bearer $accessToken';
      options.extra[_retriedKey] = true;
      handler.resolve(await _client.dio.fetch<Object>(options));
    } catch (_) {
      _client._clearTokens();
      handler.next(error);
    }
  }
}

/// 디버그에서만 URL 경로·상태만 기록한다. 토큰, 헤더, 본문은 절대 남기지 않는다.
class _SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[HTTP] ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    debugPrint(
      '[HTTP] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri.path}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException error, ErrorInterceptorHandler handler) {
    debugPrint(
      '[HTTP] ${error.response?.statusCode ?? error.type.name} ${error.requestOptions.method} ${error.requestOptions.uri.path}',
    );
    handler.next(error);
  }
}
