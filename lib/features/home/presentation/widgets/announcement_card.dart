import 'package:flutter/material.dart';

class AnnouncementCard extends StatelessWidget {
  const AnnouncementCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.onTap,
    required this.isRead,
  });

  final String title;
  final String subtitle;
  final String date;
  final VoidCallback onTap;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isRead ? Colors.white : const Color(0xFFEEF0FF),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 84,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB5B5B5),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Text('안 읽음', style: TextStyle(fontSize: 11)),
                  ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFB5B5B5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
