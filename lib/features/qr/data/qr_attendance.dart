import 'package:blick/core/network/api_exception.dart';

class QrAttendanceRequest {
  const QrAttendanceRequest({
    required this.token,
    required this.busId,
    required this.timestamp,
  });

  final String token;
  final int busId;
  final int timestamp;

  Map<String, Object> toJson() => {
    'token': token,
    'busId': busId,
    'timestamp': timestamp,
  };
}

class QrAttendanceResult {
  const QrAttendanceResult({
    required this.success,
    required this.message,
    this.checkTime,
    this.busName,
  });

  final bool success;
  final String message;
  final String? checkTime;
  final String? busName;

  factory QrAttendanceResult.fromJson(Map<String, dynamic> json) {
    final success = json['success'];
    final message = json['message'];
    final checkTime = json['checkTime'];
    final busName = json['busName'];
    if (success is! bool ||
        message is! String ||
        (checkTime != null && checkTime is! String) ||
        (busName != null && busName is! String)) {
      throw const ApiException('출석 확인 응답 형식이 올바르지 않습니다.');
    }
    return QrAttendanceResult(
      success: success,
      message: message,
      checkTime: checkTime as String?,
      busName: busName as String?,
    );
  }
}

/// 앱의 오프라인 시연 전용 값입니다.
enum DemoQrCode {
  valid('정상 QR'),
  expired('만료된 QR'),
  invalid('잘못된 QR');

  const DemoQrCode(this.label);
  final String label;
}

class FakeQrAttendanceRepository {
  FakeQrAttendanceRepository({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  bool _checkedIn = false;

  Future<QrAttendanceResult> check(DemoQrCode code) async {
    await Future<void>.delayed(delay);
    switch (code) {
      case DemoQrCode.expired:
        throw const ApiException('만료된 QR입니다.');
      case DemoQrCode.invalid:
        throw const ApiException('올바른 출석 QR이 아닙니다.');
      case DemoQrCode.valid:
        if (_checkedIn) throw const ApiException('이미 출석을 확인했습니다.');
        _checkedIn = true;
        return QrAttendanceResult(
          success: true,
          message: '테스트 출석을 확인했습니다.',
          checkTime: DateTime.now().toIso8601String(),
          busName: '테스트 귀가버스',
        );
    }
  }
}
