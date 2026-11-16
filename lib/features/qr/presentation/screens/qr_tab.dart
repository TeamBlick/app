import 'package:blick/core/network/api_client.dart';
import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/qr/data/qr_attendance.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrTab extends StatefulWidget {
  const QrTab({super.key, this.fake, this.demoRepository});

  final bool? fake;

  final FakeQrAttendanceRepository? demoRepository;

  @override
  State<QrTab> createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> with AutomaticKeepAliveClientMixin {
  late final _demoRepository =
      widget.demoRepository ??
      ((widget.fake ?? ApiClient.useFakeAuth)
          ? FakeQrAttendanceRepository()
          : null);
  bool _checkingDemo = false;
  String? _demoMessage;

  @override
  bool get wantKeepAlive => _demoRepository != null;

  MobileScannerController? _controller;
  MobileScannerController get controller =>
      _controller ??= MobileScannerController(formats: [BarcodeFormat.qrCode]);
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

  Future<void> _chooseDemoCode(FakeQrAttendanceRepository repository) async {
    if (_checkingDemo) return;
    final code = await showModalBottomSheet<DemoQrCode>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in DemoQrCode.values)
              ListTile(
                title: Text(option.label),
                onTap: () => Navigator.pop(sheetContext, option),
              ),
          ],
        ),
      ),
    );
    if (!mounted || code == null) return;

    setState(() {
      _checkingDemo = true;
      _demoMessage = null;
    });
    try {
      final result = await repository.check(code);
      if (mounted) setState(() => _demoMessage = result.message);
    } on ApiException catch (error) {
      if (mounted) setState(() => _demoMessage = error.message);
    } finally {
      if (mounted) setState(() => _checkingDemo = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final demoRepository = _demoRepository;
    if (demoRepository != null) {
      final message = _demoMessage;
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_checkingDemo)
                  const CircularProgressIndicator()
                else if (message != null)
                  Text(message),
                FilledButton(
                  onPressed: _checkingDemo
                      ? null
                      : () => _chooseDemoCode(demoRepository),
                  child: const Text('테스트 QR 선택'),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
