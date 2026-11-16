import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrTab extends StatefulWidget {
  const QrTab({super.key});

  @override
  State<QrTab> createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> {
  final controller = MobileScannerController(formats: [BarcodeFormat.qrCode]);
  bool _detected = false;
  bool _changingCamera = false;

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_detected || _changingCamera) return;
    final hasQr = capture.barcodes.any(
      (barcode) =>
          barcode.format == BarcodeFormat.qrCode &&
          (barcode.rawValue?.trim().isNotEmpty ?? false),
    );
    if (!hasQr) return;

    setState(() {
      _detected = true;
      _changingCamera = true;
    });
    try {
      await controller.stop();
    } on MobileScannerException {
      // 다시 스캔 버튼으로 카메라 시작을 재시도할 수 있습니다.
    } finally {
      if (mounted) setState(() => _changingCamera = false);
    }
  }

  Future<void> _scanAgain() async {
    if (_changingCamera) return;
    setState(() => _changingCamera = true);
    try {
      await controller.start();
      if (mounted && controller.value.isRunning) {
        setState(() => _detected = false);
      }
    } on MobileScannerException {
      // 스캐너가 준비되지 않았으면 다시 스캔 안내를 유지합니다.
    } finally {
      if (mounted) setState(() => _changingCamera = false);
    }
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
          MobileScanner(controller: controller, onDetect: _handleCapture),
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
                  Image.asset('assets/icons/QRscan.png', width: 220),
                  const SizedBox(height: 24),
                  Text(
                    // 스캔 전/후 상태에 따라 사용자 안내 문구 변경
                    _detected
                        ? 'QR을 읽었습니다. 출석 확인 기능은 준비 중입니다.'
                        : '탑승 확인을 위해\nQR을 스캔해주세요!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_detected)
                    FilledButton(
                      onPressed: _changingCamera ? null : _scanAgain,
                      child: const Text('다시 스캔'),
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
