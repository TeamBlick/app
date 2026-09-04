import 'package:flutter/material.dart';

/// 두 가지 선택(탑승/미탑승)을 표시하는 홈 화면 전용 라디오 버튼입니다.
class RadioButton extends StatefulWidget {
  const RadioButton({super.key, this.initialValue = '탑승', this.onChanged});

  final String initialValue;
  final ValueChanged<String>? onChanged;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  late String selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialValue;
  }

  void _update(String value) {
    setState(() => selected = value);
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4F6BFF);

    return RadioGroup<String>(
      groupValue: selected,
      onChanged: (value) {
        if (value != null) _update(value);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Radio<String>(
            value: '탑승',
            activeColor: blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          ),
          GestureDetector(
            onTap: () => _update('탑승'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '탑승',
                style: TextStyle(color: blue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Radio<String>(
            value: '미탑승',
            activeColor: Colors.grey,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity(horizontal: -2, vertical: -2),
          ),
          GestureDetector(
            onTap: () => _update('미탑승'),
            child: const Text(
              '미탑승',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
