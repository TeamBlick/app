import 'package:blick/core/config/student_repositories.dart';
import 'package:flutter/material.dart';
import 'package:blick/features/bus/presentation/screens/bus_tab.dart';
import 'package:blick/features/home/presentation/screens/home_tab.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_tab.dart';
import 'package:blick/features/home/presentation/widgets/bottom_nav.dart';
import 'package:blick/features/profile/presentation/screens/profile_tab.dart';
import 'package:blick/features/qr/presentation/screens/qr_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.repositories});

  final StudentRepositories? repositories;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0; // 탭 인덱스 상태

  late final _repositories =
      widget.repositories ?? StudentRepositories.fromEnvironment();
  late final pages = [
    HomeTab(
      key: const PageStorageKey('home'),
      repository: _repositories.attendance,
      showMap: !_repositories.isFake,
    ),
    BusTab(key: const PageStorageKey('bus'), repository: _repositories.bus),
    if (_repositories.isFake)
      const Center(child: Text('오프라인 테스트에서는 QR 출석을 사용할 수 없습니다.'))
    else
      const QrTab(key: PageStorageKey('qr')),
    AnnouncementTab(
      key: const PageStorageKey('alerts'),
      repository: _repositories.announcements,
    ),
    const ProfileTab(key: PageStorageKey('profile')),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => currentIndex = index),
        children: pages,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
