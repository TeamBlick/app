import 'package:blick/features/home/data/models/home_models.dart';
import 'package:flutter/material.dart';

String announcementDate(BuildContext context, String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return MaterialLocalizations.of(context).formatCompactDate(date.toLocal());
}

class AnnouncementDetail extends StatelessWidget {
  const AnnouncementDetail({super.key, required this.item});

  final Announcement item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '공지사항',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${item.author} · ${announcementDate(context, item.createdDate)}',
            ),
            const SizedBox(height: 20),
            Text(
              item.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Color(0xFF4A4A4A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
