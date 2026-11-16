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
