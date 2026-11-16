import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/repositories/announcement_repository.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_detail.dart';
import 'package:blick/features/home/presentation/widgets/announcement_card.dart';
import 'package:flutter/material.dart';

class AnnouncementTab extends StatefulWidget {
  const AnnouncementTab({super.key, this.repository});

  final AnnouncementRepository? repository;

  @override
  State<AnnouncementTab> createState() => _AnnouncementTabState();
}

class _AnnouncementTabState extends State<AnnouncementTab>
    with AutomaticKeepAliveClientMixin {
  late final _repository = widget.repository ?? ApiAnnouncementRepository();
  final _readIds = <int>{};
  final _pendingReadIds = <int>{};
  List<Announcement>? _announcements;
  String? _loadError;
  bool _loading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final announcements = await _repository.getAnnouncements();
      if (!mounted) return;
      setState(() => _announcements = announcements);
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _loadError = error.message);
    } on StateError {
      if (!mounted) return;
      setState(() => _loadError = '공지사항 서버 설정을 확인해주세요.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(Announcement item) async {
    if (item.read ||
        _readIds.contains(item.id) ||
        !_pendingReadIds.add(item.id)) {
      return;
    }
    try {
      await _repository.markAsRead(item.id);
      if (mounted) setState(() => _readIds.add(item.id));
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: () => _markAsRead(item),
          ),
        ),
      );
    } finally {
      _pendingReadIds.remove(item.id);
    }
  }

  void _open(Announcement item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => AnnouncementDetail(item: item)),
    );
    _markAsRead(item);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = _announcements;
    final error = _loadError;
    return Column(
      children: [
        const SafeArea(
          bottom: false,
          child: SizedBox(
            height: 64,
            child: Center(
              child: Text(
                '공지사항',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        Expanded(
          child: switch (items) {
            null when _loading => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when error != null => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(error, textAlign: TextAlign.center),
                  TextButton(onPressed: _load, child: const Text('다시 시도')),
                ],
              ),
            ),
            final items? when items.isNotEmpty => RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AnnouncementCard(
                    title: item.title,
                    subtitle: item.author,
                    date: announcementDate(context, item.createdDate),
                    isRead: item.read || _readIds.contains(item.id),
                    onTap: () => _open(item),
                  );
                },
              ),
            ),
            _ => RefreshIndicator(
              onRefresh: _load,
              child: LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Center(child: Text('등록된 공지사항이 없습니다.')),
                    ),
                  ],
                ),
              ),
            ),
          },
        ),
      ],
    );
  }
}
