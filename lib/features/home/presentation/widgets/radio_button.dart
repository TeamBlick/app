import 'package:flutter/material.dart';

/// 두 가지 선택(탑승/미탑승)을 표시하는 홈 화면 전용 라디오 버튼입니다.
class RadioButton extends StatelessWidget {
  const RadioButton({super.key, this.value, this.onChanged});

  final String? value;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4F6BFF);

    return RadioGroup<String>(
      groupValue: value,
      onChanged: (value) {
        if (value != null) onChanged?.call(value);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Radio<String>(
            value: '탑승',
            enabled: onChanged != null,
            activeColor: blue,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!('탑승'),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Text(
                '탑승',
                style: TextStyle(color: blue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          Radio<String>(
            value: '미탑승',
            enabled: onChanged != null,
            activeColor: Colors.grey,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          ),
          GestureDetector(
            onTap: onChanged == null ? null : () => onChanged!('미탑승'),
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
