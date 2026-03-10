import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';
import '../../../widgets/radio_buttom.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 0, 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppLogoHeader(), // 로고를 좌측으로 붙임
            ),
          ),
          SectionCard(title: "귀가버스 탑승 여부", child: RadioButtom()), // 라디오 위젯 분리
          SizedBox(height: 32),
          SectionCard(title: "출석체크", child: Text("출석 췤")),
          SizedBox(height: 32),
          SectionCard(title: "현재위치", child: Text("현재 위치")),
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
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}
