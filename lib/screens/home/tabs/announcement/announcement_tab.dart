import 'package:flutter/material.dart';
import '../../../../widgets/app_logo_header.dart';
import 'announcement_detail.dart';

class AlarmTab extends StatelessWidget {
  const AlarmTab({super.key});

  static const _announcements = [
    _AnnouncementItem(
      title: '귀가버스 차량 정보',
      subtitle: '이미지 보기',
      date: '26.12.30',
      description: '귀가버스 차량 정보 공지 상세 내용입니다.',
      imageUrl: null,
    ),
    _AnnouncementItem(
      title: '귀가버스 출발 시간 안내',
      subtitle: '시간표 확인',
      date: '26.12.29',
      description: '출발 시간 변경 사항 및 탑승 유의사항 안내입니다.',
    ),
    _AnnouncementItem(
      title: '버스 탑승 위치 변경',
      subtitle: '위치 안내',
      date: '26.12.28',
      description: '탑승 위치가 변경되어 안내드립니다.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Align(alignment: Alignment.centerLeft),
          AppLogoHeader(),
          SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _announcements.length,

            itemBuilder: (context, index) {
              final item = _announcements[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: AnnouncementCard(
                  title: item.title,
                  subtitle: item.subtitle,
                  date: item.date,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnnouncementDetail(
                          title: item.title,
                          description: item.description,
                          imageUrl: item.imageUrl,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class AnnouncementCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final VoidCallback onTap;

  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [], // 필요 시 그림자 추가
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(subtitle),
                        ],
                      ),
                      Text(date),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementItem {
  const _AnnouncementItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.description,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String date;
  final String description;
  final String? imageUrl;
}
