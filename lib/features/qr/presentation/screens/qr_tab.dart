import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrTab extends StatefulWidget {
  const QrTab({super.key});

  @override
  State<QrTab> createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> {
  late final MobileScannerController controller;
  bool isHandled = false; // 첫 스캔만 처리하기 위한 플래그

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(); // 카메라 스캐너 컨트롤러
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1) 실제 카메라 프리뷰 + 바코드 감지 레이어
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isHandled) return;
              final barcodes = capture.barcodes;
              if (barcodes.isEmpty) return;

              // 첫 스캔만 처리해서 연속 감지(중복 처리) 방지
              setState(() => isHandled = true);
            },
          ),
          // 2) 카메라 위에 반투명 어두운 마스크
          IgnorePointer(
            child: Container(
              color: Colors.black.withValues(alpha: 0.45), // 반투명 레이어
            ),
          ),
          // 3) 중앙 가이드 이미지 + 안내 문구 오버레이
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/QRscan.png',
                    width: 220,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    // 스캔 전/후 상태에 따라 사용자 안내 문구 변경
                    isHandled ? 'QR 확인이 완료됐습니다.' : '탑승 확인을 위해\nQR을 스캔해주세요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
