import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/bus/data/datasource/student_bus_api.dart';
import 'package:blick/features/bus/data/repositories/bus_repository.dart';
import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/repositories/announcement_repository.dart';
import 'package:blick/features/home/data/repositories/attendance_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 로그인 세션에서 사용할 학생 기능의 저장소를 구성합니다.
class StudentRepositories {
  const StudentRepositories({
    required this.announcements,
    required this.attendance,
    required this.bus,
    this.isFake = false,
  });

  factory StudentRepositories.fromEnvironment({Dio? dio}) {
    if (ApiClient.useFakeAuth) {
      return StudentRepositories.fake(
        simulateNetworkFailure:
            dotenv.env['BLICK_FAKE_NETWORK_FAILURE'] == 'true',
      );
    }
    final homeApi = HomeApi(dio: dio);
    return StudentRepositories(
      announcements: ApiAnnouncementRepository(api: homeApi),
      attendance: ApiAttendanceRepository(api: homeApi),
      bus: ApiBusRepository(api: StudentBusApi(dio: dio)),
    );
  }

  factory StudentRepositories.fake({
    bool simulateNetworkFailure = false,
    Duration delay = const Duration(milliseconds: 350),
  }) {
    Future<void> wait() async {
      await Future<void>.delayed(delay);
      if (simulateNetworkFailure) {
        throw const ApiException(
          '네트워크 연결을 확인해주세요.',
          type: ApiErrorType.network,
        );
      }
    }

    final attendance = FakeAttendanceRepository(wait: wait);
    return StudentRepositories(
      announcements: FakeAnnouncementRepository(wait: wait),
      attendance: attendance,
      bus: FakeBusRepository(wait: wait, isAbsent: () => attendance.isAbsent),
      isFake: true,
    );
  }

  final AnnouncementRepository announcements;
  final AttendanceRepository attendance;
  final BusRepository bus;
  final bool isFake;
}
