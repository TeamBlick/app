import 'package:flutter/material.dart';

/// Kakao 지도 자리를 위한 플레이스홀더 위젯.
/// 실제 지도 SDK 연동 시 이 파일 내부만 교체하면 됨.
class KakaoMapWidget extends StatelessWidget {
  const KakaoMapWidget({
    super.key,
    this.height = 240,
    this.subtitle = '동대구역까지 약 12.3km',
  });

  /// 지도를 표시할 높이.
  final double height;

  /// 부가 설명(거리 등).
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFE9EEF6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD6DDE6)),
          ),
          child: const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map, color: Color(0xFF4F6BFF), size: 32),
                SizedBox(height: 8),
                Text(
                  'Kakao Map Placeholder',
                  style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'SDK 연동 시 이 영역에 지도 표시',
                  style: TextStyle(color: Colors.black38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
