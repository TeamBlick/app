import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/home/data/repositories/attendance_repository.dart';
import 'package:blick/features/home/presentation/providers/attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blick/features/home/presentation/widgets/kakao_map_widget.dart';
import 'package:blick/features/home/presentation/widgets/radio_button.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/section_card.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key, required this.repository, this.showMap = true});

  final AttendanceRepository repository;
  final bool showMap;

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _changeAttendance(String value) async {
    final provider = attendanceProvider(widget.repository);
    final isAbsent = value == '미탑승';
    String? reason;
    if (isAbsent) {
      reason = await showDialog<String>(
        context: context,
        builder: (_) => const _AbsentReasonDialog(),
      );
      if (!mounted || reason == null) return;
    }

    try {
      final result = await ref
          .read(provider.notifier)
          .setAbsent(absent: isAbsent, reason: reason == '' ? null : reason);
      if (mounted && result != null) _showResult(result.message);
    } on ApiException catch (error) {
      if (mounted) _showResult(error.message);
    } on StateError {
      if (mounted) _showResult('탑승 상태 서버 설정을 확인해주세요.');
    } on TypeError {
      if (mounted) _showResult('탑승 상태 응답 형식이 올바르지 않습니다.');
    }
  }

  void _showResult(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = attendanceProvider(widget.repository);
    final attendance = ref.watch(provider);
    final busState = switch (attendance.valueOrNull) {
      true => '미탑승',
      false => '탑승',
      null => null,
    };
    final error = attendance.error;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 0, 24), // 각각
            child: Align(
              alignment: Alignment.centerLeft,
              child: AppLogoHeader(), // 로고를 좌측으로 붙임
            ),
          ),
          SectionCard(
            title: "귀가버스 탑승 여부",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioButton(
                  value: busState,
                  onChanged: attendance.isLoading ? null : _changeAttendance,
                ),
                if (attendance.isLoading)
                  const LinearProgressIndicator()
                else if (attendance.hasError && !attendance.hasValue) ...[
                  Text(
                    error is ApiException
                        ? error.message
                        : '탑승 상태를 불러오지 못했습니다.',
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(provider),
                    child: const Text('다시 시도'),
                  ),
                ] else if (busState == null)
                  const Text('기존 탑승 상태를 확인할 수 없습니다.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: "출석체크",
            child: busState == null
                ? const Text('탑승 상태 미확인')
                : _AttendanceButton(busState: busState),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: widget.showMap ? '현재위치' : '테스트 경로',
            child: widget.showMap
                ? const KakaoMapWidget()
                : const KakaoMapWidget.demo(),
          ),
        ],
      ),
    );
  }
}

class _AbsentReasonDialog extends StatefulWidget {
  const _AbsentReasonDialog();

  @override
  State<_AbsentReasonDialog> createState() => _AbsentReasonDialogState();
}

class _AbsentReasonDialogState extends State<_AbsentReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('미탑승 신청'),
      content: TextField(
        controller: _reason,
        decoration: const InputDecoration(labelText: '사유 (선택)'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _reason.text.trim()),
          child: const Text('신청'),
        ),
      ],
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  const _AttendanceButton({required this.busState});

  final String busState;

  @override
  Widget build(BuildContext context) {
    final isBoarding = busState == "탑승";
    // 탑승 상태에 따라 삼항으로 버튼 색/문구 결정
    final bgColor = isBoarding
        ? const Color.fromARGB(255, 128, 215, 58)
        : const Color(0xFFFF3B30);
    final label = isBoarding ? "탑승" : "미탑승";

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 52,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
