typedef RoutePoint = ({double latitude, double longitude});

class RouteQuery {
  const RouteQuery({required this.start, required this.end});

  final RoutePoint start;
  final RoutePoint end;

  Map<String, double> toQueryParameters() {
    _validate(start, 'start');
    _validate(end, 'end');
    return {
      'startLat': start.latitude,
      'startLng': start.longitude,
      'endLat': end.latitude,
      'endLng': end.longitude,
    };
  }

  static void _validate(RoutePoint point, String name) {
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      throw ArgumentError.value(point, name, '유효한 위도와 경도가 필요합니다.');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is RouteQuery && start == other.start && end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
