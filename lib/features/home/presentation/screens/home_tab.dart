import 'package:flutter/material.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/kakao_map_widget.dart';
import 'package:blick/shared/widgets/radio_buttom.dart';
import 'package:blick/shared/widgets/section_card.dart';

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
          const SizedBox(height: 16),
          SectionCard(
            title: "출석체크",
            child: _AttendanceButton(busState: busState),
          ),
          const SizedBox(height: 16),
          const SectionCard(title: "현재위치", child: KakaoMapWidget()),
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
    final bgColor = isBoarding ? const Color.fromARGB(255, 128, 215, 58) : const Color(0xFFFF3B30);
    final label = isBoarding ? "탑승" : "미탑승";

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
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
