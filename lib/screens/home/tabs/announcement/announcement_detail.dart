import 'package:flutter/material.dart';
import 'announcement_item.dart';

class AnnouncementDetail extends StatelessWidget {
  const AnnouncementDetail({
    super.key,
    required this.item,
  });

  final AnnouncementItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('공지 상세'),
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: double.infinity,
                height: 220,
                color: Colors.white,
                child: item.imageUrl == null
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFB8B8B8),
                        ),
                      )
                    : Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item.description,
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
