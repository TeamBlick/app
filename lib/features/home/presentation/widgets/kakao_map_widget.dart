import 'dart:math' as math;

import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/models/route_query.dart';
import 'package:blick/features/home/data/repositories/route_repository.dart';
import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// 지도와 경로 조회 결과를 표시합니다.
class KakaoMapWidget extends StatefulWidget {
  const KakaoMapWidget({
    super.key,
    this.height = 240,
    this.query,
    this.locationPermissionDenied = false,
    this.repository,
  }) : _demo = false;

  const KakaoMapWidget.demo({
    super.key,
    this.height = 240,
    this.query = const RouteQuery(
      start: (latitude: 35.818, longitude: 128.4914),
      end: (latitude: 35.8779, longitude: 128.6286),
    ),
    this.repository = const FakeRouteRepository(),
  }) : locationPermissionDenied = false,
       _demo = true;

  final double height;
  final RouteQuery? query;
  final bool locationPermissionDenied;
  final RouteRepository? repository;
  final bool _demo;

  @override
  State<KakaoMapWidget> createState() => _KakaoMapWidgetState();
}

class _KakaoMapWidgetState extends State<KakaoMapWidget> {
  late final RouteRepository _defaultRepository = ApiRouteRepository();
  Future<RoutePlan>? _route;

  @override
  void initState() {
    super.initState();
    _route = _loadRoute();
  }

  @override
  void didUpdateWidget(KakaoMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.locationPermissionDenied != widget.locationPermissionDenied ||
        oldWidget.repository != widget.repository) {
      _route = _loadRoute();
    }
  }

  Future<RoutePlan>? _loadRoute() {
    final query = widget.query;
    if (query == null || widget.locationPermissionDenied) return null;
    return (widget.repository ?? _defaultRepository).getRoute(query);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<RoutePlan>(
    future: _route,
    builder: (context, snapshot) {
      final observedRequest = _route;
      final plan = snapshot.connectionState == ConnectionState.done
          ? snapshot.data
          : null;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_route == null)
            Text(
              widget.locationPermissionDenied
                  ? '위치 권한을 허용하면 경로를 확인할 수 있습니다.'
                  : '출발 위치와 목적지가 필요합니다.',
            )
          else if (snapshot.connectionState == ConnectionState.waiting)
            const LinearProgressIndicator()
          else if (snapshot.hasError)
            Row(
              children: [
                Expanded(
                  child: Text(switch (snapshot.error) {
                    ApiException(:final message) => message,
                    _ => '경로를 불러오지 못했습니다.',
                  }),
                ),
                TextButton(
                  onPressed: () {
                    if (_route == observedRequest) {
                      final request = _loadRoute();
                      setState(() {
                        _route = request;
                      });
                    }
                  },
                  child: const Text('경로 다시 시도'),
                ),
              ],
            )
          else if (plan != null)
            Text(
              '${plan.summary.distanceKm.toStringAsFixed(1)} km · 약 ${plan.summary.durationMinutes}분',
            ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: double.infinity,
              height: widget.height,
              child: widget._demo
                  ? _OfflineRouteMap(points: plan?.points ?? const [])
                  : _KakaoRouteMap(
                      query: widget.locationPermissionDenied
                          ? null
                          : widget.query,
                      plan: plan,
                    ),
            ),
          ),
        ],
      );
    },
  );
}

class _KakaoRouteMap extends StatelessWidget {
  const _KakaoRouteMap({required this.query, required this.plan});

  final RouteQuery? query;
  final RoutePlan? plan;

  @override
  Widget build(BuildContext context) {
    final start = query?.start;
    final destination = query?.end;
    final geometry = plan?.points ?? const <RoutePoint>[];
    final points = [
      for (final point in geometry) LatLng(point.latitude, point.longitude),
    ];

    return KakaoMap(
      // The plugin cannot remove overlays absent from an updated list.
      key: ValueKey((query, geometry)),
      center: start != null
          ? LatLng(start.latitude, start.longitude)
          : LatLng(35.8779, 128.6286),
      markers: [
        if (destination != null)
          Marker(
            markerId: 'route-destination',
            latLng: LatLng(destination.latitude, destination.longitude),
          ),
      ],
      polylines: [
        if (points.length > 1)
          Polyline(
            polylineId: 'route',
            points: points,
            strokeColor: Theme.of(context).colorScheme.primary,
          ),
      ],
      onMapCreated: points.length > 1
          ? (controller) => controller.fitBounds(points)
          : null,
    );
  }
}

class _OfflineRouteMap extends StatelessWidget {
  const _OfflineRouteMap({required this.points});

  final List<RoutePoint> points;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colors.surfaceContainerHigh,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (points.length > 1)
            CustomPaint(
              key: const Key('demo-route-line'),
              painter: _RouteLinePainter(points, colors.primary),
            ),
          const Positioned(left: 12, top: 8, child: Text('테스트 경로 미리보기')),
        ],
      ),
    );
  }
}

class _RouteLinePainter extends CustomPainter {
  const _RouteLinePainter(this.points, this.color);

  final List<RoutePoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 24.0;
    final area = (Offset.zero & size).deflate(inset);
    if (area.isEmpty) return;
    final latitudes = points.map((point) => point.latitude);
    final longitudes = points.map((point) => point.longitude);
    final minLat = latitudes.reduce(math.min);
    final maxLng = longitudes.reduce(math.max);
    final minLng = longitudes.reduce(math.min);
    final latSpan = latitudes.reduce(math.max) - minLat;
    final lngSpan = maxLng - minLng;

    final offsets = [
      for (final point in points)
        Offset(
          lngSpan == 0
              ? area.center.dx
              : area.left + (point.longitude - minLng) / lngSpan * area.width,
          latSpan == 0
              ? area.center.dy
              : area.bottom - (point.latitude - minLat) / latSpan * area.height,
        ),
    ];
    final path = Path()..addPolygon(offsets, false);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    final endpointPaint = Paint()..color = color;
    canvas.drawCircle(offsets.first, 5, endpointPaint);
    canvas.drawCircle(offsets.last, 7, endpointPaint);
  }

  @override
  bool shouldRepaint(_RouteLinePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
