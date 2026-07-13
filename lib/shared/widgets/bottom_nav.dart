import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum BottomTab { home, bus, scan, alerts, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap; //탭 변경 시 호출되는 콜백

  static const _iconPaths = [
    'assets/icons/home.svg',
    'assets/icons/mdi_bus.svg',
    'assets/icons/gg_qr.svg',
    'assets/icons/bell.svg',
    'assets/icons/iconamoon_profile-fill.svg',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        backgroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed, // 고정형 네비게이션
        showSelectedLabels: false, // 라벨 숨김
        showUnselectedLabels: false, //라벨 숨김
        selectedItemColor: const Color(0xFF4F6BFF),
        unselectedItemColor: const Color(0xFFB8B8B8),
        items: List.generate(_iconPaths.length, (index) {
          //final isActive = index == currentIndex; 현재 눌렸는지 확인
          final path = _iconPaths[index]; // 아이콘 경로
          return BottomNavigationBarItem(
            label: '',
            icon: _InactiveIcon(path),
            activeIcon: _ActiveIcon(path),
          );
        }),
    );
  }
}

class _InactiveIcon extends StatelessWidget {
  const _InactiveIcon(this.assetPath);
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: 28,
      height: 28,
      colorFilter: const ColorFilter.mode(Color(0xFFB8B8B8), BlendMode.srcIn),
    );
  }
}

class _ActiveIcon extends StatelessWidget {
  const _ActiveIcon(this.assetPath);
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Container
    (
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4F6BFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SvgPicture.asset(
        assetPath,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}
