import 'package:blick/core/config/student_repositories.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/bus/data/models/student_bus_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('학생 테스트 저장소는 세션 안에서 상태를 변경하고 새 세션에서 초기화한다', () async {
    final repo = StudentRepositories.fake(delay: Duration.zero);
    final notice = (await repo.announcements.getAnnouncements()).first;
    await repo.announcements.markAsRead(notice.id);
    expect((await repo.announcements.getAnnouncements()).first.read, isTrue);

    final initialBus = (await repo.bus.getBusState())!;
    final first = initialBus.choices.first;
    final second = initialBus.choices[1];
    expect(initialBus.assigned, isNull);
    await repo.attendance.setAbsent(absent: true, reason: '가족 행사');
    expect(await repo.attendance.getAbsent(), isTrue);

    final application = await repo.bus.requestBus(
      BusRequest(busId: first.id, busDestination: first.destination.apiValue),
    );
    expect(application.busId, first.id);
    expect(application.absent, isTrue);
    final change = await repo.bus.changeBus(
      BusChangeRequest(newBusId: second.id),
    );
    expect(change.newBusNumber, second.number);
    expect((await repo.bus.getBusState())!.assigned?.id, second.id);

    await repo.attendance.setAbsent(absent: false);
    expect(await repo.attendance.getAbsent(), isFalse);

    final nextSession = StudentRepositories.fake(delay: Duration.zero);
    expect(
      (await nextSession.announcements.getAnnouncements()).first.read,
      isFalse,
    );
    expect((await nextSession.bus.getBusState())!.assigned, isNull);
  });

  test('잘못된 버스 요청은 선택을 변경하지 않는다', () async {
    final repo = StudentRepositories.fake(delay: Duration.zero);
    final first = (await repo.bus.getBusState())!.choices.first;
    final validationFailure = throwsA(
      isA<ApiException>().having(
        (error) => error.type,
        'type',
        ApiErrorType.badRequest,
      ),
    );

    await expectLater(
      repo.bus.requestBus(
        BusRequest(busId: first.id, busDestination: 'UNKNOWN'),
      ),
      validationFailure,
    );
    expect((await repo.bus.getBusState())!.assigned, isNull);

    await repo.bus.requestBus(
      BusRequest(busId: first.id, busDestination: first.destination.apiValue),
    );
    await expectLater(
      repo.bus.changeBus(BusChangeRequest(newBusId: first.id)),
      validationFailure,
    );
    expect((await repo.bus.getBusState())!.assigned?.id, first.id);
  });

  test('네트워크 오류 시 학생 API를 시뮬레이션한다', () async {
    final repo = StudentRepositories.fake(
      simulateNetworkFailure: true,
      delay: Duration.zero,
    );
    final networkFailure = throwsA(
      isA<ApiException>().having(
        (error) => error.type,
        'type',
        ApiErrorType.network,
      ),
    );
    await expectLater(repo.announcements.getAnnouncements(), networkFailure);
    await expectLater(repo.bus.getBusState(), networkFailure);
    await expectLater(repo.attendance.setAbsent(absent: true), networkFailure);
  });
}
