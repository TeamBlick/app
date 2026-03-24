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
