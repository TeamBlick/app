import 'package:flutter/material.dart';
import '../../../widgets/app_logo_header.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: const [
          AppLogoHeader(),
          SizedBox(height: 32),
          Center(child: Text('프로필 탭')),
        ],
      ),
    );
  }
}
