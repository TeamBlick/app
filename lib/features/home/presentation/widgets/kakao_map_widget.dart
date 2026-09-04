import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

/// 홈 화면에서 현재 위치를 표시하는 지도 위젯입니다.
class KakaoMapWidget extends StatelessWidget {
  const KakaoMapWidget({
    super.key,
    this.height = 240,
    this.subtitle = '동대구역까지 약 12.3km',
  });

  final double height;
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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: KakaoMap(
              center: LatLng(35.8779, 128.6286),
              markers: [
                Marker(
                  markerId: 'dongdaegu',
                  latLng: LatLng(35.8779, 128.6286),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
