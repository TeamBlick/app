import 'package:flutter/material.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/section_card.dart';

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
          Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 0, 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppLogoHeader(), // 로고를 좌측으로 붙임
            ),
          ),
          SectionCard(title: "버스 변경 위치", child: _BusChangeDropdown()),
          const SizedBox(height: 16),
          SectionCard(title: "버스 변경 사유", child: BusChangeReason()),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "용산역",
          style: TextStyle(color: Color(0xFF656565), fontSize: 18),
        ),
        SizedBox(
          width: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PopupMenuButton<String>(
                position: PopupMenuPosition.under,
                onSelected: (value) {
                  setState(() {
                    selectedTerminal = value; // 선택값 변경
                  });
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "용산역", child: Text("용산역")),
                  PopupMenuItem(value: "동대구역", child: Text("동대구역")),
                  PopupMenuItem(value: "대곡역", child: Text("대곡역")),
                ],
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selectedTerminal,
                        style: const TextStyle(
                          color: Color(0xFF4F6BFF),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.unfold_more, color: Color(0xFF4F6BFF)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BusChangeReason extends StatefulWidget {
  const BusChangeReason({super.key});
  @override
  State<BusChangeReason> createState() => _BusChangeReasonState();
}

class _BusChangeReasonState extends State<BusChangeReason> {
  final TextEditingController reasonController = TextEditingController();

  bool get _canSubmit => reasonController.text.trim().isNotEmpty;

  void _submitReason() {
    final reason = reasonController.text.trim();
    if (reason.isEmpty) return;

    print("제출: $reason");

    reasonController.clear();
    setState(() {});
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("제출되었습니다."),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF4A4A4A),
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }


  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: TextFormField(
            //큰 필드가 안됨 그래서 Textfrom
            controller: reasonController,
            maxLines: null, // expands=true와 함께 사용 시 필수
            expands: true, //
            keyboardType: TextInputType.multiline, //키보드도 여러줄 입력 가능하게
            decoration: InputDecoration(
              hintText: "버스 변경 사유를 입력해주세요",
              border: InputBorder.none,
            ),
            style: TextStyle(color: Color(0xFF6A6A6A), height: 1.25),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              
              child: const Text(
                "제출하기",
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
              onPressed: _canSubmit ? _submitReason : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: reasonController.text.trim().isNotEmpty
                    ? const Color(0xFF4F6BFF)
                    : const Color(0xFFB8B8B8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
