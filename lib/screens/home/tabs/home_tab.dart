import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';
import '../../../widgets/radio_buttom.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String busState = "탑승"; // 현재 탑승 상태

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 0, 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppLogoHeader(), // 로고를 좌측으로 붙임
            ),
          ),
          SectionCard(
            title: "귀가버스 탑승 여부",
            child: RadioButtom(
              initialValue: busState,
              onChanged: (value) => setState(() => busState = value),
            ),
          ),
          const SizedBox(height: 32),
          SectionCard(
            title: "출석체크",
            child: _AttendanceButton(busState: busState),
          ),
          const SizedBox(height: 32),
          const SectionCard(title: "현재위치", child: Text("현재 위치")),
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

class _AttendanceButton extends StatelessWidget {
  const _AttendanceButton({required this.busState});

  final String busState;

  @override
  Widget build(BuildContext context) {
    final isBoarding = busState == "탑승";
    // 탑승 상태에 따라 삼항으로 버튼 색/문구 결정
    final bgColor = isBoarding ? const Color.fromARGB(255,128,215,58) : const Color(0xFFFF3B30);
    final label = isBoarding ? "탑승" : "미탑승";

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
