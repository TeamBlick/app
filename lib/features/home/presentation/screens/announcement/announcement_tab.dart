import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/models/home_models.dart';
import 'package:blick/features/home/data/repositories/announcement_repository.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_detail.dart';
import 'package:blick/features/home/presentation/widgets/announcement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blick/features/home/presentation/providers/announcement_provider.dart';

class AnnouncementTab extends ConsumerStatefulWidget {
  const AnnouncementTab({super.key, required this.repository});

  final AnnouncementRepository repository;

  @override
  ConsumerState<AnnouncementTab> createState() => _AnnouncementTabState();
}

class _AnnouncementTabState extends ConsumerState<AnnouncementTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _markAsRead(Announcement item) async {
    try {
      await ref
          .read(announcementsProvider(widget.repository).notifier)
          .markAsRead(item);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException ? error.message : '읽음 상태를 변경하지 못했습니다.',
          ),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: () => _markAsRead(item),
          ),
        ),
      );
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
    final provider = announcementsProvider(widget.repository);
    final announcements = ref.watch(provider);
    final items = announcements.valueOrNull;
    final error = announcements.error;
    Future<void> refresh() => ref.read(provider.notifier).refresh();
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
            null when announcements.isLoading => const Center(
              child: CircularProgressIndicator(),
            ),
            _ when !announcements.isLoading && error != null => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error is ApiException ? error.message : '공지사항을 불러오지 못했습니다.',
                    textAlign: TextAlign.center,
                  ),
                  TextButton(onPressed: refresh, child: const Text('다시 시도')),
                ],
              ),
            ),
            final items? when items.isNotEmpty => RefreshIndicator(
              onRefresh: refresh,
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
                    isRead: item.read,
                    onTap: () => _open(item),
                  );
                },
              ),
            ),
            _ => RefreshIndicator(
              onRefresh: refresh,
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
