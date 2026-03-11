import 'package:flutter/material.dart';

enum BottomTab { home, bus, scan, alerts, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
    BottomNavigationBarItem(icon: Icon(Icons.bus_alert), label: '버스'),
    BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'qr'),
    BottomNavigationBarItem(icon: Icon(Icons.notification_add), label: '알림'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: '유저프로필'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F6BFF),
        unselectedItemColor: const Color(0xFFB8B8B8),
        items: _items,
      ),
    );
  }
}
