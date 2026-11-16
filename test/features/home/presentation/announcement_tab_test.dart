import 'dart:async';

import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/repositories/announcement_repository.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _notice = Announcement(
  id: 42,
  title: '버스 공지',
  content: '금요일 오후 5시에 출발합니다.',
  author: '담당 교사',
  createdDate: '2026-11-16T10:00:00',
  read: false,
);

class _FakeRepository implements AnnouncementRepository {
  Future<List<Announcement>> Function() load = () async => [_notice];
  Future<void> Function() mark = () async {};
  final marked = <int>[];

  @override
  Future<List<Announcement>> getAnnouncements() => load();

  @override
  Future<void> markAsRead(int id) {
    marked.add(id);
    return mark();
  }
}

Future<void> _pump(WidgetTester tester, AnnouncementRepository repository) =>
    tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: AnnouncementTab(repository: repository)),
      ),
    );

void main() {
  testWidgets('서버 확인 후 읽음이 반영되고 중복 요청을 보내지 않는다', (tester) async {
    final pending = Completer<void>();
    final repository = _FakeRepository()..mark = () => pending.future;
    await _pump(tester, repository);
    await tester.pumpAndSettle();
    expect(find.text('안 읽음'), findsOneWidget);

    await tester.tap(find.text(_notice.title));
    await tester.pumpAndSettle();
    expect(find.text(_notice.content), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('안 읽음'), findsOneWidget);

    await tester.tap(find.text(_notice.title));
    await tester.pumpAndSettle();
    expect(repository.marked, [42]);
    pending.complete();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('안 읽음'), findsNothing);

    await tester.tap(find.text(_notice.title));
    await tester.pumpAndSettle();
    expect(repository.marked, [42]);
  });

  testWidgets('목록 로딩, 실패 후 재시도와 빈 상태를 보여준다', (tester) async {
    final pending = Completer<List<Announcement>>();
    final repository = _FakeRepository()..load = () => pending.future;
    await _pump(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    pending.completeError(const ApiException('목록을 불러올 수 없습니다.'));
    await tester.pumpAndSettle();
    expect(find.text('목록을 불러올 수 없습니다.'), findsOneWidget);

    repository.load = () async => [];
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('등록된 공지사항이 없습니다.'), findsOneWidget);
  });
}
