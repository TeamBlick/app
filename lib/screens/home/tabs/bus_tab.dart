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
          SectionCard(title: "버스 변경 위치", child: _BusChangeDropdown()),
          const SizedBox(height: 32),
          SectionCard(title: "버스 변경 사유", child: Text("ㅗㅑ")),
        ],
      ),
    );
  }
}

class _BusChangeDropdown extends StatefulWidget {
  const _BusChangeDropdown({super.key});

  @override
  State<_BusChangeDropdown> createState() => _BusChangeDropdownState();
}

class _BusChangeDropdownState extends State<_BusChangeDropdown> {
  String selectedTerminal = "용산역";

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "용산역",
          style: TextStyle(
            color: Color(0xFF656565),
            fontSize: 18,
          ),
        ),
        SizedBox(
          width: 220,
          child: Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTerminal,
                  items: const [
                    DropdownMenuItem(value: "용산역", child: Text("용산역")),
                    DropdownMenuItem(value: "동대구역", child: Text("동대구역")),
                    DropdownMenuItem(value: "대곡역", child: Text("대곡역")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTerminal = value!; // 선택값 변경
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
