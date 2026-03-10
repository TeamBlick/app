import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          AppLogoHeader(),
          SizedBox(height: 32),
          SectionCard(title: "귀가버스 탑승 여부", child: BusSelect()),
          SizedBox(height: 40),
          SectionCard(title: "출석체크", child: Text("출석 췤")),
          SizedBox(height: 40),
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

class BusSelect extends StatefulWidget {
  const BusSelect({super.key});

  @override
  State<BusSelect> createState() => _BusSelectState();
}

class _BusSelectState extends State<BusSelect> {
  String selected = "탑승"; // 현재 탑승 선택 상태를 저장
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded로 감싸 화면이 좁아도 두 타일이 균등 분할되어 overflow 방지
        Expanded(
          child: RadioListTile<String>(
            title: const Text("탑승"),
            value: "탑승",
            groupValue: selected,
            onChanged: (value) => setState(() => selected = value!),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text("미탑승"),
            value: "미탑승",
            groupValue: selected,
            onChanged: (value) => setState(() => selected = value!),
          ),
        ),
      ],
    );
  }
}

// NOTE: BusSelect의 RadioListTile은 Expanded로 분할해 overflow 대응 완료.
// TODO: 탑승 여부 상태를 상위(HomeScreen 등)로 올려 공유 필요 시 콜백/상태관리 적용.
// TODO: 홈 화면 콘텐츠가 텍스트 placeholder뿐이라 “화면 안 보임”처럼 보일 수 있음 → 실제 버튼/지도/로딩 UI 추가.
