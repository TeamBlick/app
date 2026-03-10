import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';

class QrTab extends StatelessWidget {
  const QrTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          AppLogoHeader(),
          SizedBox(height: 32),
          Center(child: Text('QR 탭')),
        ],
      ),
    );
  }
}
