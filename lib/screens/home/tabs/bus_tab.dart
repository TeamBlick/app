import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';

class BusTab extends StatelessWidget {
  const BusTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          Align(alignment: Alignment.centerLeft),
          AppLogoHeader(),
          SizedBox(height: 32),
          Center(child: Text('버스 탭')),
        ],
      ),
    );
  }
}
