import 'package:flutter/material.dart';
import 'home/tabs/announcement/announcement_tab.dart';
import 'home/tabs/bus_tab.dart';
import 'home/tabs/home_tab.dart';
import 'home/tabs/profile_tab.dart';
import 'home/tabs/qr_tab.dart';
import '../widgets/bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0; // 탭 인덱스 상태

  final pages = const [
    HomeTab(key: PageStorageKey('home')),
    BusTab(key: PageStorageKey('bus')),
    QrTab(key: PageStorageKey('qr')),
    AlarmTab(key: PageStorageKey('alerts')),
    ProfileTab(key: PageStorageKey('profile')),
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
