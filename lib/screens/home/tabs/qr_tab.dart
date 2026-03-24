import 'package:flutter/material.dart';

class QrTab extends StatelessWidget {
  const QrTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5C5F6B), // 어두운 배경
      body: SafeArea(
        child: Stack(
          children: [
            /// 👇 가운데 내용
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 👇 QR 프레임 (임시)
                  Image.asset(
                    'assets/icons/QRscan.svg',
                    width: 200,
                  ),

                  const SizedBox(height: 24),

                  /// 안내 문구
                  const Text(
                    "탑승 확인을 위해\nQR을 스캔해주세요!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
