import 'package:flutter/material.dart';
import 'home/tabs/alarm_tab.dart';
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
  int currentIndex = 0; // 탭 인덱스 상태

  final pages = const [
    HomeTab(key: PageStorageKey('home')),
    BusTab(key: PageStorageKey('bus')),
    QrTab(key: PageStorageKey('qr')),
    AlarmTab(key: PageStorageKey('alerts')),
    ProfileTab(key: PageStorageKey('profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
