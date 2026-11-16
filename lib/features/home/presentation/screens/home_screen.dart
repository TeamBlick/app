import 'package:blick/core/config/student_repositories.dart';
import 'package:blick/core/config/student_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:blick/features/bus/presentation/screens/bus_tab.dart';
import 'package:blick/features/home/presentation/screens/home_tab.dart';
import 'package:blick/features/home/presentation/screens/announcement/announcement_tab.dart';
import 'package:blick/features/home/presentation/widgets/bottom_nav.dart';
import 'package:blick/features/profile/presentation/screens/profile_tab.dart';
import 'package:blick/features/qr/presentation/screens/qr_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.repositories});

  final StudentRepositories? repositories;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0; // 탭 인덱스 상태

  List<Widget> _pages(StudentRepositories repositories) => [
    HomeTab(
      key: const PageStorageKey('home'),
      repository: repositories.attendance,
      showMap: !repositories.isFake,
    ),
    BusTab(key: const PageStorageKey('bus'), repository: repositories.bus),
    if (repositories.isFake)
      const Center(child: Text('오프라인 테스트에서는 QR 출석을 사용할 수 없습니다.'))
    else
      const QrTab(key: PageStorageKey('qr')),
    AnnouncementTab(
      key: const PageStorageKey('alerts'),
      repository: repositories.announcements,
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
    final repositories =
        widget.repositories ??
        ref.watch<StudentRepositories>(studentRepositoriesProvider);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) => setState(() => currentIndex = index),
        children: _pages(repositories),
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
