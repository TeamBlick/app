class AbsentRequest {
  const AbsentRequest({required this.reason});
  final String reason;
  Map<String, dynamic> toJson() => {'reason': reason};
}

class AbsentResult {
  const AbsentResult({required this.success, required this.message});
  final bool success;
  final String message;
  factory AbsentResult.fromJson(Map<String, dynamic> json) => AbsentResult(
    success: json['success'] as bool,
    message: json['message'] as String,
  );
}

class BusSchedule {
  const BusSchedule({
    required this.scheduleId,
    required this.busId,
    required this.busNumber,
    required this.busDestination,
    required this.serviceDate,
    required this.departureTime,
    required this.arrivalTime,
    this.notice,
  });

  final int scheduleId;
  final int busId;
  final String busNumber;
  final String busDestination;
  final String serviceDate;
  final String departureTime;
  final String arrivalTime;
  final String? notice;

  factory BusSchedule.fromJson(Map<String, dynamic> json) => BusSchedule(
    scheduleId: json['scheduleId'] as int,
    busId: json['busId'] as int,
    busNumber: json['busNumber'] as String,
    busDestination: json['busDestination'] as String,
    serviceDate: json['serviceDate'] as String,
    departureTime: json['departureTime'] as String,
    arrivalTime: json['arrivalTime'] as String,
    notice: json['notice'] as String?,
  );
}

class ApplicationPeriod {
  const ApplicationPeriod({
    required this.id,
    required this.date,
    required this.deadline,
    required this.closed,
  });

  final int id;
  final String date;
  final String deadline;
  final bool closed;

  factory ApplicationPeriod.fromJson(Map<String, dynamic> json) =>
      ApplicationPeriod(
        id: json['id'] as int,
        date: json['date'] as String,
        deadline: json['deadline'] as String,
        closed: json['closed'] as bool,
      );
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.createdDate,
    required this.read,
  });

  final int id;
  final String title;
  final String content;
  final String author;
  final String createdDate;
  final bool read;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
    id: json['id'] as int,
    title: json['title'] as String,
    content: json['content'] as String,
    author: json['author'] as String,
    createdDate: json['createdDate'] as String,
    read: json['read'] as bool,
  );
}

class RouteSummary {
  const RouteSummary({
    required this.distance,
    required this.distanceKm,
    required this.duration,
    required this.durationMinutes,
    required this.taxiFare,
    required this.toll,
  });

  final int distance;
  final double distanceKm;
  final int duration;
  final int durationMinutes;
  final int taxiFare;
  final int toll;

  factory RouteSummary.fromJson(Map<String, dynamic> json) => RouteSummary(
    distance: json['distance'] as int,
    distanceKm: (json['distanceKm'] as num).toDouble(),
    duration: json['duration'] as int,
    durationMinutes: json['durationMinutes'] as int,
    taxiFare: json['taxiFare'] as int,
    toll: json['toll'] as int,
  );
}
