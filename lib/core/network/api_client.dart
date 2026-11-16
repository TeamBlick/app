import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
    FlutterSecureStorage? secureStorage,
    bool offline = false,
  }) : _tokens = tokenStore ?? TokenStore(),
       _refreshTokens = refreshTokens,
       _secureStorage = secureStorage,
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
    if (offline) {
      this.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
    }
    this.dio.interceptors.add(_AuthenticationInterceptor(this));
    if (enableLogging ?? kDebugMode) {
      this.dio.interceptors.add(_SafeLogInterceptor());
    }
  }

  static final ApiClient _shared = ApiClient(
    baseUrl: dotenv.env['API_BASE_URL']?.trim() ?? '',
    secureStorage: useFakeAuth ? null : const FlutterSecureStorage(),
    offline: useFakeAuth,
  );
  static const _sessionKey = 'blick.student.tokens.v1';
  static bool get useFakeAuth =>
      kDebugMode && dotenv.env['BLICK_FAKE_AUTH'] == 'true';
  static Dio get instance => _shared.dio;
  static ValueListenable<AuthenticationState> get authenticationState =>
      _shared._authenticationState;
  final Dio dio;
  final TokenStore _tokens;
  final RefreshTokens? _refreshTokens;
  final ValueNotifier<AuthenticationState> _authenticationState = ValueNotifier(
    AuthenticationState.expired,
  );
  final FlutterSecureStorage? _secureStorage;
  Future<void> _storageQueue = Future.value();
  Future<AuthTokens>? _refreshInFlight;
  int _sessionVersion = 0;
  bool _clearing = false;

  static Future<void> restoreSession() => _shared._restoreSession();
  static Future<void> setTokens(AuthTokens tokens) =>
      _shared._startSession(tokens);
  static Future<void> clearTokens() => _shared._clearTokens();

  Future<void> _restoreSession() async {
    final raw = await _secureStorage?.read(key: _sessionKey);
    if (raw == null) return;
    try {
      final value = jsonDecode(raw);
      if (value is Map &&
          value['accessToken'] is String &&
          value['refreshToken'] is String &&
          (value['accessToken'] as String).isNotEmpty &&
          (value['refreshToken'] as String).isNotEmpty) {
        _tokens.save(
          AuthTokens(
            accessToken: value['accessToken'] as String,
            refreshToken: value['refreshToken'] as String,
          ),
        );
        _authenticationState.value = AuthenticationState.authenticated;
        return;
      }
    } on FormatException {
      // 손상된 저장값은 아래에서 삭제합니다.
    }
    await _secureStorage?.delete(key: _sessionKey);
  }

  Future<void> _serializeStorage(Future<void> Function() operation) {
    final pending = _storageQueue.then((_) => operation());
    _storageQueue = pending.then<void>((_) {}, onError: (Object _) {});
    return pending;
  }

  Future<void> _startSession(AuthTokens tokens) {
    final version = ++_sessionVersion;
    _clearing = false;
    _refreshInFlight = null;
    return _saveTokens(tokens, version);
  }

  Future<void> _saveTokens(AuthTokens tokens, int version) =>
      _serializeStorage(() async {
        if (version != _sessionVersion) return;
        await _secureStorage?.write(
          key: _sessionKey,
          value: jsonEncode({
            'accessToken': tokens.accessToken,
            'refreshToken': tokens.refreshToken,
          }),
        );
        if (version != _sessionVersion) return;
        _tokens.save(tokens);
        _authenticationState.value = AuthenticationState.authenticated;
      });

  Future<void> _clearTokens({bool expireOnStorageError = false}) {
    final version = ++_sessionVersion;
    _refreshInFlight = null;
    _clearing = true;
    return _serializeStorage(() async {
      try {
        await _secureStorage?.delete(key: _sessionKey);
      } catch (_) {
        if (!expireOnStorageError) rethrow;
      }
      if (version != _sessionVersion) return;
      _tokens.clear();
      _authenticationState.value = AuthenticationState.expired;
    }).whenComplete(() {
      if (version == _sessionVersion) _clearing = false;
    });
  }

  Future<AuthTokens> refreshAccessToken() {
    final refreshToken = _tokens.refreshToken;
    if (_clearing || refreshToken == null || refreshToken.isEmpty) {
      return Future<AuthTokens>.error(StateError('갱신할 refresh token이 없습니다.'));
    }
    final version = _sessionVersion;
    return _refreshInFlight ??= _performRefresh(refreshToken, version)
        .whenComplete(() {
          if (version == _sessionVersion) _refreshInFlight = null;
        });
  }

  Future<AuthTokens> _performRefresh(String refreshToken, int version) async {
    final tokens = _refreshTokens != null
        ? await _refreshTokens(refreshToken)
        : await _requestRefresh(refreshToken);
    await _saveTokens(tokens, version);
    if (version != _sessionVersion) throw StateError('세션이 변경되었습니다.');
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
    if (data is! Map ||
        data['accessToken'] is! String ||
        (data['accessToken'] as String).isEmpty) {
      throw StateError('토큰 갱신 응답 형식이 올바르지 않습니다.');
    }
    return AuthTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: switch (data['refreshToken']) {
        final String rotated when rotated.isNotEmpty => rotated,
        _ => refreshToken,
      },
    );
  }
}

class _AuthenticationInterceptor extends Interceptor {
  _AuthenticationInterceptor(this._client);
  final ApiClient _client;
  static const _retriedKey = 'authRetryAttempted';
  static const _sessionKey = 'authSessionVersion';
  bool _isAuthRequest(RequestOptions options) =>
      options.path.startsWith('/auth/');
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_isAuthRequest(options)) {
      options.extra[_sessionKey] ??= _client._sessionVersion;
      final accessToken = _client._tokens.accessToken;
      if (!_client._clearing && accessToken != null && accessToken.isNotEmpty) {
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
    final version = options.extra[_sessionKey];
    final currentToken = _client._tokens.accessToken;
    final sentToken = options.headers['Authorization'];
    if (error.response?.statusCode != 401 ||
        _isAuthRequest(options) ||
        version != _client._sessionVersion ||
        currentToken == null ||
        sentToken == null) {
      handler.next(error);
      return;
    }

    if (options.extra[_retriedKey] == true) {
      if (sentToken == 'Bearer $currentToken') await _expireSession();
      handler.next(error);
      return;
    }

    final String accessToken;
    try {
      accessToken = sentToken != 'Bearer $currentToken'
          ? currentToken
          : (await _client.refreshAccessToken()).accessToken;
    } on DioException catch (refreshError) {
      if (version == _client._sessionVersion &&
          const {400, 401, 403}.contains(refreshError.response?.statusCode)) {
        await _expireSession();
      }
      handler.next(refreshError);
      return;
    } catch (_) {
      handler.next(error);
      return;
    }
    if (version != _client._sessionVersion) {
      handler.next(error);
      return;
    }

    options.headers['Authorization'] = 'Bearer $accessToken';
    options.extra[_retriedKey] = true;
    try {
      handler.resolve(await _client.dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<void> _expireSession() =>
      _client._clearTokens(expireOnStorageError: true);
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
