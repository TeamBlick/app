/// 공지사항 화면에서 사용하는 표시용 모델입니다.
class AnnouncementItem {
  const AnnouncementItem({
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
