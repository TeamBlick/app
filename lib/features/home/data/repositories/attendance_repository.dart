import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/models/home_models.dart';

abstract interface class AttendanceRepository {
  Future<bool?> getAbsent();
  Future<AbsentResult> setAbsent({required bool absent, String? reason});
}

class ApiAttendanceRepository implements AttendanceRepository {
  ApiAttendanceRepository({HomeApi? api}) : _api = api ?? HomeApi();

  final HomeApi _api;

  @override
  Future<bool?> getAbsent() async {
    // 서버의 학생 상태 조회 API가 제공되기 전에는 현재 상태를 알 수 없습니다.
    return null;
  }

  @override
  Future<AbsentResult> setAbsent({required bool absent, String? reason}) async {
    final response = absent
        ? await _api.applyAbsent(AbsentRequest(reason: reason))
        : await _api.cancelAbsent();
    final result = response.data;
    if (result == null || !result.success) {
      throw ApiException(result?.message ?? '탑승 상태 변경에 실패했습니다.');
    }
    return result;
  }
}

class FakeAttendanceRepository implements AttendanceRepository {
  FakeAttendanceRepository({required Future<void> Function() wait})
    : _wait = wait;

  final Future<void> Function() _wait;
  bool _absent = false;
  bool get isAbsent => _absent;

  @override
  Future<bool> getAbsent() async {
    await _wait();
    return _absent;
  }

  @override
  Future<AbsentResult> setAbsent({required bool absent, String? reason}) async {
    await _wait();
    _absent = absent;
    return AbsentResult(
      success: true,
      message: absent ? '미탑승을 신청했습니다.' : '미탑승 신청을 취소했습니다.',
    );
  }
}
