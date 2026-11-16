import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/repositories/announcement_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final announcementsProvider = AsyncNotifierProvider.autoDispose
    .family<
      AnnouncementsController,
      List<Announcement>,
      AnnouncementRepository
    >(AnnouncementsController.new);

class AnnouncementsController
    extends
        AutoDisposeFamilyAsyncNotifier<
          List<Announcement>,
          AnnouncementRepository
        > {
  late AnnouncementRepository _repository;
  final _readIds = <int>{};
  final _pendingReadIds = <int>{};

  @override
  Future<List<Announcement>> build(AnnouncementRepository repository) {
    _repository = repository;
    return _load();
  }

  Future<List<Announcement>> _load() async {
    final items = await _repository.getAnnouncements();
    return [
      for (final item in items)
        _readIds.contains(item.id) ? item.asRead() : item,
    ];
  }

  Future<void> refresh() async {
    if (state.isLoading) return;
    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      state = await AsyncValue.guard(_load);
    } finally {
      link.close();
    }
  }

  Future<void> markAsRead(Announcement item) async {
    if (item.read ||
        _readIds.contains(item.id) ||
        !_pendingReadIds.add(item.id)) {
      return;
    }

    final link = ref.keepAlive();
    try {
      await _repository.markAsRead(item.id);
      _readIds.add(item.id);
      final items = state.valueOrNull;
      if (items != null && !state.isLoading && !state.hasError) {
        state = AsyncData([
          for (final current in items)
            current.id == item.id ? current.asRead() : current,
        ]);
      }
    } finally {
      _pendingReadIds.remove(item.id);
      link.close();
    }
  }
}
