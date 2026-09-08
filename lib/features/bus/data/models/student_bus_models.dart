/// 학생 버스 신청 상태입니다. 서버의 `status` 문자열과 값이 일치해야 합니다.
enum BusApplicationStatus {
  applied('APPLIED'),
  notUsing('NOT_USING');

  const BusApplicationStatus(this.value);
  final String value;
}

class BusRequest {
  const BusRequest({required this.busId, required this.busDestination});

  final int busId;
  final String busDestination;

  Map<String, dynamic> toJson() => {
    'busId': busId,
    'busDestination': busDestination,
  };
}

class BusChangeRequest {
  const BusChangeRequest({required this.newBusId});
  final int newBusId;
  Map<String, dynamic> toJson() => {'newBusId': newBusId};
}

class BusApplicationRequest {
  const BusApplicationRequest({
    required this.date,
    required this.status,
    this.busId,
    this.absentReason,
  });

  final String date;
  final BusApplicationStatus status;
  final int? busId;
  final String? absentReason;

  Map<String, dynamic> toJson() => {
    'date': date,
    'status': status.value,
    if (busId != null) 'busId': busId,
    if (absentReason != null) 'absentReason': absentReason,
  };
}

class StudentInfo {
  const StudentInfo({
    required this.id,
    required this.username,
    required this.email,
    required this.absent,
    this.busId,
    this.busNumber,
    this.destination,
  });

  final int id;
  final String username;
  final String email;
  final bool absent;
  final int? busId;
  final String? busNumber;
  final String? destination;

  factory StudentInfo.fromJson(Map<String, dynamic> json) => StudentInfo(
    id: json['id'] as int,
    username: json['username'] as String,
    email: json['email'] as String,
    absent: json['absent'] as bool,
    busId: json['busId'] as int?,
    busNumber: json['busNumber'] as String?,
    destination: json['destination'] as String?,
  );
}

class BusChangeResult {
  const BusChangeResult({
    required this.success,
    required this.message,
    this.newBusNumber,
  });

  final bool success;
  final String message;
  final String? newBusNumber;

  factory BusChangeResult.fromJson(Map<String, dynamic> json) =>
      BusChangeResult(
        success: json['success'] as bool,
        message: json['message'] as String,
        newBusNumber: json['newBusNumber'] as String?,
      );
}

class BusDetail {
  const BusDetail({
    required this.id,
    required this.busNumber,
    required this.route,
  });

  final int id;
  final String busNumber;
  final String route;

  factory BusDetail.fromJson(Map<String, dynamic> json) => BusDetail(
    id: json['id'] as int,
    busNumber: json['busNumber'] as String,
    route: json['route'] as String,
  );
}

class BusApplication {
  const BusApplication({
    required this.applicationId,
    required this.date,
    required this.status,
    this.absentReason,
    this.requestedBus,
    this.assignedBus,
  });

  final int applicationId;
  final String date;
  final BusApplicationStatus status;
  final String? absentReason;
  final BusDetail? requestedBus;
  final BusDetail? assignedBus;

  factory BusApplication.fromJson(Map<String, dynamic> json) => BusApplication(
    applicationId: json['applicationId'] as int,
    date: json['date'] as String,
    status: BusApplicationStatus.values.firstWhere(
      (status) => status.value == json['status'],
    ),
    absentReason: json['absentReason'] as String?,
    requestedBus: _mapOrNull(json['requestedBus'], BusDetail.fromJson),
    assignedBus: _mapOrNull(json['assignedBus'], BusDetail.fromJson),
  );
}

T? _mapOrNull<T>(Object? value, T Function(Map<String, dynamic>) fromJson) {
  if (value is! Map) return null;
  return fromJson(Map<String, dynamic>.from(value));
}
