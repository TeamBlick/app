import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';
import '../../../widgets/section_card.dart';

class BusTab extends StatefulWidget {
  const BusTab({super.key});
  @override
  State<BusTab> createState() => _BusTabState();
}

class _BusTabState extends State<BusTab> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          SectionCard(title: "버스 변경 위치", child: Text("hi")),
          const SizedBox(height: 32),
          SectionCard(title: "버스 변경 사유", child: Text("ㅗㅑ")),
        ],
      ),
    );
  }
}
