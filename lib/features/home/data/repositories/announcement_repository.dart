import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/datasource/home_api.dart';
import 'package:blick/features/home/data/models/home_models.dart';

abstract interface class AnnouncementRepository {
  Future<List<Announcement>> getAnnouncements();
  Future<void> markAsRead(int id);
}

class ApiAnnouncementRepository implements AnnouncementRepository {
  ApiAnnouncementRepository({HomeApi? api}) : _api = api ?? HomeApi();

  final HomeApi _api;

  @override
  Future<List<Announcement>> getAnnouncements() async {
    final response = await _api.getAnnouncements();
    return response.data!;
  }

  @override
  Future<void> markAsRead(int id) => _api.markAnnouncementAsRead(id);
}

class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository({required Future<void> Function() wait})
    : _wait = wait;

  final Future<void> Function() _wait;
  final _readIds = <int>{};
  static const _items = [
    Announcement(
      id: 1,
      title: '귀가버스 운행 안내',
      content: '금요일 16시 30분까지 학교 정문 앞에 모여주세요.',
      author: '학생생활부',
      createdDate: '2026-09-03T14:00:00+09:00',
      read: false,
    ),
    Announcement(
      id: 2,
      title: '버스 신청 기간 안내',
      content: '귀가버스 신청 마감은 목요일 18시입니다.',
      author: '학생생활부',
      createdDate: '2026-09-02T10:00:00+09:00',
      read: false,
    ),
  ];

  @override
  Future<List<Announcement>> getAnnouncements() async {
    await _wait();
    return [
      for (final item in _items)
        _readIds.contains(item.id) ? item.asRead() : item,
    ];
  }

  @override
  Future<void> markAsRead(int id) async {
    await _wait();
    if (!_items.any((item) => item.id == id)) {
      throw const ApiException(
        '공지사항을 찾을 수 없습니다.',
        statusCode: 404,
        type: ApiErrorType.notFound,
      );
    }
    _readIds.add(id);
  }
}
