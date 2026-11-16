import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/repositories/attendance_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final attendanceProvider = AsyncNotifierProvider.autoDispose
    .family<AttendanceController, bool?, AttendanceRepository>(
      AttendanceController.new,
    );

class AttendanceController
    extends AutoDisposeFamilyAsyncNotifier<bool?, AttendanceRepository> {
  late AttendanceRepository _repository;

  @override
  Future<bool?> build(AttendanceRepository repository) {
    _repository = repository;
    return _repository.getAbsent();
  }

  Future<AbsentResult?> setAbsent({
    required bool absent,
    String? reason,
  }) async {
    if (state.isLoading || (state.hasValue && state.valueOrNull == absent)) {
      return null;
    }

    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      final result = await _repository.setAbsent(
        absent: absent,
        reason: reason,
      );
      state = AsyncData(absent);
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      link.close();
    }
  }
}
