import 'package:flutter/material.dart';
import 'home/tabs/alarm_tab.dart';
import 'home/tabs/bus_tab.dart';
import 'home/tabs/home_tab.dart';
import 'home/tabs/profile_tab.dart';
import 'home/tabs/qr_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // 탭 인덱스 상태

  final pages = const [
    HomeTab(),
    BusTab(),
    QrTab(),
    AlarmTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
      appBar: AppBar(),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.bus_alert), label: "버스"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "qr"),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_add),
            label: "알림",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "유저프로필"),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // blurRadius 낮게하려면
            blurRadius: 8, //
            color: Colors.black.withOpacity(
              0.1,
            ), // 문제: Color에는 withValues가 없어 컴파일 오류
            offset: Offset(0, 4), //
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
