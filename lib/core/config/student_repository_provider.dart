import 'package:blick/core/config/student_repositories.dart';
import 'package:blick/core/network/network_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final studentRepositoriesProvider = Provider.autoDispose<StudentRepositories>(
  (ref) => StudentRepositories.fromEnvironment(
    dio: ref.watch(dioProvider),
    fakeMode: ref.watch(fakeModeProvider),
  ),
);
