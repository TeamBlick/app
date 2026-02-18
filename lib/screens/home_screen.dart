import 'package:flutter/material.dart';

void main() {
  runApp(HomeScreen());
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final logoWidth = size.width * 0.32;

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(245, 245, 245, 1),
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              SizedBox(height: 40),
              SectionCard(title: "귀가버스 탑승 여부", child: Text("탑승")),
              SizedBox(height: 40),
              SectionCard(title: "출석체크", child: Text("출석 췤")),
              SizedBox(height: 40),
              SectionCard(title: "현재위치", child: Text("현재 위치")),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
            BottomNavigationBarItem(icon: Icon(Icons.bus_alert), label: "버스"),
            BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "qr"),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_add),
              label: "알림",
            ), //아마 알림일 듯
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "유저프로필",
            ), //
          ],
        ),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            // blurRadius 낮게하려면
            blurRadius: 8, //
            color: Colors.black.withValues(alpha: 0.1),
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
