import 'package:blick/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final fakeModeProvider = Provider<bool>((ref) => ApiClient.useFakeAuth);

final secureStorageProvider = Provider<FlutterSecureStorage?>(
  (ref) => ref.watch(fakeModeProvider) ? null : const FlutterSecureStorage(),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    baseUrl: dotenv.env['API_BASE_URL']?.trim() ?? '',
    secureStorage: ref.watch(secureStorageProvider),
    offline: ref.watch(fakeModeProvider),
  );
  ref.onDispose(client.dispose);
  return client;
});

final dioProvider = Provider<Dio>((ref) => ref.watch(apiClientProvider).dio);
