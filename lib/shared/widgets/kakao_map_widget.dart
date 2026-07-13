import 'package:flutter/material.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';

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
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: height,
            child: KakaoMap(
              center: LatLng(
                35.8779,
                128.6286,
              ),
              markers: [
                Marker(
                  markerId: 'dongdaegu',
                  latLng: LatLng(
                    35.8779,
                    128.6286,
                  ),)
              ],
            ),
          ),
        )
      ]
    );
  }
}
