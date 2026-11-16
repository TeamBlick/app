import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/models/route_query.dart';

class RoutePlan {
  const RoutePlan({required this.summary, this.points = const []});

  final RouteSummary summary;
  final List<RoutePoint> points;
}

abstract interface class RouteRepository {
  Future<RoutePlan> getRoute(RouteQuery query);
}

class ApiRouteRepository implements RouteRepository {
  ApiRouteRepository({HomeApi? api}) : _api = api ?? HomeApi();

  final HomeApi _api;

  @override
  Future<RoutePlan> getRoute(RouteQuery query) async {
    final response = await _api.getRouteSummaryFor(query);
    final summary = response.data;
    if (summary == null) {
      throw const ApiException('경로 요약을 읽을 수 없습니다.');
    }
    // 상세 경로 계약이 확정되면 getRoute 응답에서 좌표를 변환합니다.
    return RoutePlan(summary: summary);
  }
}

class FakeRouteRepository implements RouteRepository {
  const FakeRouteRepository();

  @override
  Future<RoutePlan> getRoute(RouteQuery query) async => RoutePlan(
    summary: const RouteSummary(
      distance: 12300,
      distanceKm: 12.3,
      duration: 1320,
      durationMinutes: 22,
      taxiFare: 0,
      toll: 0,
    ),
    points: [
      query.start,
      (
        latitude:
            query.start.latitude +
            (query.end.latitude - query.start.latitude) * .25,
        longitude:
            query.start.longitude +
            (query.end.longitude - query.start.longitude) * .6,
      ),
      (
        latitude:
            query.start.latitude +
            (query.end.latitude - query.start.latitude) * .75,
        longitude:
            query.start.longitude +
            (query.end.longitude - query.start.longitude) * .65,
      ),
      query.end,
    ],
  );
}
