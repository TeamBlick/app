import 'package:flutter/material.dart';

class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({
    super.key,
    this.maxWidthFactor = 0.32,
    this.semanticLabel = 'BLICK 로고',
    this.alignment = Alignment.centerLeft,
  });

  /// 로고가 차지할 최대 가로 비율 (0~1).
  final double maxWidthFactor;

  /// 스크린리더용 라벨.
  final String semanticLabel;

  /// 로고 정렬 방향 (기본 왼쪽 정렬).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 0, 32), // 좌측 여백, 상단 16, 하단 32
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = constraints.maxWidth * maxWidthFactor; // 주어진 비율로 너비 계산
            return Align(
              alignment: alignment, // 로고를 왼쪽으로 치우치게 배치
              child: Semantics(
                label: semanticLabel, // 접근성 라벨
                child: Image.asset(
                  'assets/images/App_Logo.png',
                  width: logoWidth, // 동적으로 계산된 로고 크기
                  fit: BoxFit.contain, // 비율 유지하며 축소
                  errorBuilder: (_, __, ___) =>
                      const SizedBox.shrink(), // 이미지 없으면 공백 처리
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
