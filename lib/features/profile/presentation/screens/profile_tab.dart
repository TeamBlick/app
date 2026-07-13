import 'package:flutter/material.dart';
import 'package:blick/features/auth/presentation/screens/login_screen.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/section_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("로그아웃"),
          content: const Text("정말 로그아웃 하시겠어요?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text("확인"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AppLogoHeader(),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_circle_rounded,
                  size: 72,
                  color: Color(0xFF4F6BFF),
                ),
                SizedBox(height: 8),
                Text(
                      "우성민",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: "기본정보",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                _InfoRow(label: "이름", value: "우성민"),
                SizedBox(height: 18),
                _InfoRow(label: "학번", value: "2311"),
                SizedBox(height: 18),
                _InfoRow(
                  label: "도착지",
                  value: "동대구역",
                  valueColor: Color(0xFF4F6BFF),
                ),
                SizedBox(height: 18),
                _InfoRow(label: "이메일", value: "wusm1230@dgsw.hs.kr"),
                SizedBox(height: 18),
                _InfoRow(label: "전화번호", value: "010-9424-0935"),
              ],
            )
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _handleLogout(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "로그아웃",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF232323),
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
