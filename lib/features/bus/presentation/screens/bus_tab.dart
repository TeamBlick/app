import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/bus/presentation/providers/bus_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blick/features/bus/data/repositories/bus_repository.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class BusTab extends ConsumerStatefulWidget {
  const BusTab({super.key, required this.repository});

  final BusRepository repository;

  @override
  ConsumerState<BusTab> createState() => _BusTabState();
}

class _BusTabState extends ConsumerState<BusTab>
    with AutomaticKeepAliveClientMixin {
  BusOption? _selected;

  @override
  bool get wantKeepAlive => true;

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null) return;

    try {
      final message = await ref
          .read(busProvider(widget.repository).notifier)
          .select(selected);
      if (!mounted || message == null) return;
      setState(() => _selected = null);
      _showMessage(message);
    } catch (error) {
      if (mounted) {
        _showMessage(
          error is ApiException ? error.message : '버스 상태를 변경하지 못했습니다.',
        );
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = busProvider(widget.repository);
    final bus = ref.watch(provider);
    final state = bus.valueOrNull;
    final error = bus.error;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(8, 16, 0, 24),
          child: Align(alignment: Alignment.centerLeft, child: AppLogoHeader()),
        ),
        SectionCard(
          title: state?.assigned == null ? '귀가버스 신청' : '귀가버스 변경',
          child: switch (state) {
            null when bus.isLoading => const Center(
              child: CircularProgressIndicator(),
            ),
            null when bus.hasError && !bus.hasValue => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error is ApiException ? error.message : '버스 정보를 불러오지 못했습니다.',
                ),
                TextButton(
                  onPressed: () => ref.invalidate(provider),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
            final state? => _selection(state, isSubmitting: bus.isLoading),
            _ => const Text('신청 가능한 버스 정보를 확인할 수 없습니다.'),
          },
        ),
      ],
    );
  }

  Widget _selection(StudentBusState state, {required bool isSubmitting}) {
    final assigned = state.assigned;
    final choices = state.choices.where((option) => option.id != assigned?.id);
    final selected = choices.contains(_selected) ? _selected : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (assigned != null)
          Text('신청한 버스: ${assigned.number} ${assigned.destination.label}'),
        if (choices.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('선택 가능한 버스가 없습니다.'),
          )
        else ...[
          DropdownButton<BusOption>(
            isExpanded: true,
            hint: const Text('버스 선택'),
            value: selected,
            items: [
              for (final option in choices)
                DropdownMenuItem(
                  value: option,
                  child: Text('${option.number} ${option.destination.label}'),
                ),
            ],
            onChanged: isSubmitting
                ? null
                : (option) => setState(() => _selected = option),
          ),
          if (isSubmitting)
            const LinearProgressIndicator()
          else
            FilledButton(
              onPressed: selected == null ? null : _submit,
              child: Text(assigned == null ? '버스 신청' : '버스 변경'),
            ),
        ],
      ],
    );
  }
}
