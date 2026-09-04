import 'package:flutter/material.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_detail.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_item.dart';
import 'package:blick/features/home/presentation/widgets/announcement_card.dart';

class AnnouncementTab extends StatelessWidget {
  const AnnouncementTab({super.key});

  static const _announcements = [
    AnnouncementItem(
      title: '귀가버스 차량 정보',
      subtitle: '이미지 보기',
      date: '26.12.30',
      description: '귀가버스 차량 정보 공지 상세 내용입니다.',
    ),
    AnnouncementItem(
      title: '귀가버스 출발 시간 안내',
      subtitle: '시간표 확인',
      date: '26.12.29',
      description: '출발 시간 변경 사항 및 탑승 유의사항 안내입니다.',
    ),
    AnnouncementItem(
      title: '버스 탑승 위치 변경',
      subtitle: '위치 안내',
      date: '26.12.28',
      description: '탑승 위치가 변경되어 안내드립니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _AnnouncementHeader(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            itemCount: _announcements.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _announcements[index];
              return AnnouncementCard(
                title: item.title,
                subtitle: item.subtitle,
                date: item.date,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnnouncementDetail(item: item),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnnouncementHeader extends StatelessWidget {
  const _AnnouncementHeader();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 64,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Text(
              '공지사항',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
