import 'package:flutter/material.dart';

/// 두 가지 선택(탑승/미탑승) 라디오 버튼 묶음.
class RadioButtom extends StatefulWidget {
  const RadioButtom({
    super.key,
    this.initialValue = '탑승',
    this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String>? onChanged;

  @override
  State<RadioButtom> createState() => _RadioButtomState();
}

class _RadioButtomState extends State<RadioButtom> {
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<String>(
          value: '탑승',
          groupValue: selected,
          activeColor: blue,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          onChanged: (value) => _update(value!),
        ),
        GestureDetector(
          onTap: () => _update('탑승'),
          child: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              '탑승',
              style: TextStyle(
                color: blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Radio<String>(
          value: '미탑승',
          groupValue: selected,
          activeColor: Colors.grey,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          onChanged: (value) => _update(value!),
        ),
        GestureDetector(
          onTap: () => _update('미탑승'),
          child: const Text(
            '미탑승',
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
