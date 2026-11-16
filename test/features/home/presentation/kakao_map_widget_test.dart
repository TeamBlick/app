import 'dart:async';

import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/models/route_query.dart';
import 'package:blick/features/home/data/repositories/route_repository.dart';
import 'package:blick/features/home/presentation/widgets/kakao_map_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _QueuedRoutes implements RouteRepository {
  final requests = <Completer<RoutePlan>>[];

  @override
  Future<RoutePlan> getRoute(RouteQuery query) {
    final request = Completer<RoutePlan>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  testWidgets('테스트 경로는 지도 SDK 없이 경로와 거리 및 시간을 표시한다', (tester) async {
    const demo = KakaoMapWidget.demo();
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: demo)));
    await tester.pumpAndSettle();

    expect(find.text('테스트 경로 미리보기'), findsOneWidget);
    expect(find.text('12.3 km · 약 22분'), findsOneWidget);
    expect(find.byKey(const Key('demo-route-line')), findsOneWidget);
  });

  testWidgets('같은 위경도 요청을 재사용하고 실패 후 지도를 유지하며 재시도한다', (tester) async {
    final repository = _QueuedRoutes();
    const start = (latitude: 35.8, longitude: 128.4);
    const end = (latitude: 35.9, longitude: 128.6);

    Future<void> pumpDemo(RouteQuery query) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KakaoMapWidget.demo(query: query, repository: repository),
        ),
      ),
    );

    await pumpDemo(RouteQuery(start: start, end: end));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await pumpDemo(RouteQuery(start: start, end: end));
    expect(repository.requests, hasLength(1));

    repository.requests.first.completeError(
      const ApiException('경로를 찾을 수 없습니다.'),
    );
    await tester.pumpAndSettle();
    expect(find.text('경로를 찾을 수 없습니다.'), findsOneWidget);
    expect(find.text('테스트 경로 미리보기'), findsOneWidget);

    await tester.tap(find.text('경로 다시 시도'));
    await tester.pump();
    expect(repository.requests, hasLength(2));
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    repository.requests.last.complete(
      await const FakeRouteRepository().getRoute(
        const RouteQuery(start: start, end: end),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('12.3 km · 약 22분'), findsOneWidget);
    expect(find.byKey(const Key('demo-route-line')), findsOneWidget);
  });
}
