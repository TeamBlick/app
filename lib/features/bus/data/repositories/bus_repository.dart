import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/bus/data/datasource/student_bus_api.dart';
import 'package:blick/features/bus/data/models/student_bus_models.dart';

enum BusDestination {
  yongsan('YONGSAN', '용산역'),
  daegok('DAEGOK', '대곡역'),
  dongdaegu('DONGDAEGU', '동대구역'),
  daegokDongdaegu('DAEGOKDONDAEGU', '대곡역·동대구역');

  const BusDestination(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class BusOption {
  const BusOption({
    required this.id,
    required this.number,
    required this.destination,
  });

  final int id;
  final String number;
  final BusDestination destination;
}

class StudentBusState {
  const StudentBusState({required this.choices, this.assigned});

  final List<BusOption> choices;
  final BusOption? assigned;
}

abstract interface class BusRepository {
  Future<StudentBusState?> getBusState();
  Future<StudentInfo> requestBus(BusRequest request);
  Future<BusChangeResult> changeBus(BusChangeRequest request);
}

class ApiBusRepository implements BusRepository {
  ApiBusRepository({StudentBusApi? api}) : _api = api ?? StudentBusApi();

  final StudentBusApi _api;

  @override
  Future<StudentBusState?> getBusState() async {
    // 서버에서 학생의 현재 버스와 선택 목록을 제공하면 여기서 조회합니다.
    return null;
  }

  @override
  Future<StudentInfo> requestBus(BusRequest request) async {
    final response = await _api.requestBus(request);
    return response.data ?? (throw const ApiException('버스 신청 결과가 없습니다.'));
  }

  @override
  Future<BusChangeResult> changeBus(BusChangeRequest request) async {
    final response = await _api.changeBus(request);
    final result = response.data;
    if (result == null || !result.success) {
      throw ApiException(result?.message ?? '버스를 변경하지 못했습니다.');
    }
    return result;
  }
}

class FakeBusRepository implements BusRepository {
  FakeBusRepository({
    required Future<void> Function() wait,
    required bool Function() isAbsent,
  }) : _wait = wait,
       _isAbsent = isAbsent;

  final Future<void> Function() _wait;
  final bool Function() _isAbsent;
  static const _choices = [
    BusOption(id: 101, number: '1호차', destination: BusDestination.yongsan),
    BusOption(id: 102, number: '2호차', destination: BusDestination.daegok),
    BusOption(id: 103, number: '3호차', destination: BusDestination.dongdaegu),
    BusOption(
      id: 104,
      number: '4호차',
      destination: BusDestination.daegokDongdaegu,
    ),
  ];
  BusOption? _assigned;

  @override
  Future<StudentBusState> getBusState() async {
    await _wait();
    return StudentBusState(choices: _choices, assigned: _assigned);
  }

  @override
  Future<StudentInfo> requestBus(BusRequest request) async {
    await _wait();
    final bus = _findBus(request.busId);
    if (_assigned != null ||
        bus.destination.apiValue != request.busDestination) {
      throw const ApiException(
        '신청할 버스와 목적지를 확인해주세요.',
        statusCode: 400,
        type: ApiErrorType.badRequest,
      );
    }
    _assigned = bus;
    return StudentInfo(
      id: 1,
      username: '테스트 학생',
      email: 'student@example.test',
      absent: _isAbsent(),
      busId: bus.id,
      busNumber: bus.number,
      destination: bus.destination.apiValue,
    );
  }

  @override
  Future<BusChangeResult> changeBus(BusChangeRequest request) async {
    await _wait();
    final bus = _findBus(request.newBusId);
    if (_assigned == null || _assigned?.id == bus.id) {
      throw const ApiException(
        '변경할 버스를 선택해주세요.',
        statusCode: 400,
        type: ApiErrorType.badRequest,
      );
    }
    _assigned = bus;
    return BusChangeResult(
      success: true,
      message: '버스를 변경했습니다.',
      newBusNumber: bus.number,
    );
  }

  BusOption _findBus(int id) {
    for (final bus in _choices) {
      if (bus.id == id) return bus;
    }
    throw const ApiException(
      '선택한 버스를 찾을 수 없습니다.',
      statusCode: 400,
      type: ApiErrorType.badRequest,
    );
  }
}
