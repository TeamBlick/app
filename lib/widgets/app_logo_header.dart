import 'package:flutter/material.dart';

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({
    super.key,
    this.maxWidthFactor = 0.32,
    this.semanticLabel = 'BLICK 로고',
  });

  /// 로고가 차지할 최대 가로 비율 (0~1).
  final double maxWidthFactor;

  /// 스크린리더용 라벨.
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 주어진 부모 너비에 따라 로고 크기를 비율로 계산
        final logoWidth = constraints.maxWidth * maxWidthFactor;
        return Center(
          child: Semantics(
            label: semanticLabel, // 접근성 리더기에 노출될 텍스트
            child: Image.asset(
              'assets/images/App_Logo.png',
              width: logoWidth,
              fit: BoxFit.contain, // 비율 유지하며 축소
              errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(), // 에셋 누락 시 공간만 유지하고 비움
            ),
          ),
        );
      },
    );
  }
}
