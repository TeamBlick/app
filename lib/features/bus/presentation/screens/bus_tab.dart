import 'package:blick/core/network/api_exception.dart';
import 'package:blick/features/bus/data/models/student_bus_models.dart';
import 'package:blick/features/bus/data/repositories/bus_repository.dart';
import 'package:blick/shared/widgets/app_logo_header.dart';
import 'package:blick/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class BusTab extends StatefulWidget {
  const BusTab({super.key, required this.repository});

  final BusRepository repository;

  @override
  State<BusTab> createState() => _BusTabState();
}

class _BusTabState extends State<BusTab> with AutomaticKeepAliveClientMixin {
  StudentBusState? _state;
  BusOption? _selected;
  String? _loadError;
  bool _loading = true;
  bool _submitting = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final state = await widget.repository.getBusState();
      if (!mounted) return;
      setState(() {
        _state = state;
        _selected = null;
      });
    } on ApiException catch (error) {
      if (mounted) setState(() => _loadError = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final state = _state;
    final selected = _selected;
    if (_submitting ||
        state == null ||
        selected == null ||
        selected.id == state.assigned?.id) {
      return;
    }
    setState(() => _submitting = true);
    try {
      final String message;
      final BusOption assigned;
      if (state.assigned == null) {
        final result = await widget.repository.requestBus(
          BusRequest(
            busId: selected.id,
            busDestination: selected.destination.apiValue,
          ),
        );
        assigned = BusOption(
          id: result.busId ?? selected.id,
          number: result.busNumber ?? selected.number,
          destination: selected.destination,
        );
        message = '버스를 신청했습니다.';
      } else {
        final result = await widget.repository.changeBus(
          BusChangeRequest(newBusId: selected.id),
        );
        assigned = BusOption(
          id: selected.id,
          number: result.newBusNumber ?? selected.number,
          destination: selected.destination,
        );
        message = result.message;
      }
      if (!mounted) return;
      setState(() {
        _state = StudentBusState(choices: state.choices, assigned: assigned);
        _selected = null;
      });
      _showMessage(message);
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
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
    final state = _state;
    final loadError = _loadError;
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
            _ when _loading => const Center(child: CircularProgressIndicator()),
            _ when loadError != null => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loadError),
                TextButton(onPressed: _load, child: const Text('다시 시도')),
              ],
            ),
            final state? => _selection(state),
            _ => const Text('신청 가능한 버스 정보를 확인할 수 없습니다.'),
          },
        ),
      ],
    );
  }

  Widget _selection(StudentBusState state) {
    final assigned = state.assigned;
    final choices = state.choices.where((option) => option.id != assigned?.id);
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
            value: _selected,
            items: [
              for (final option in choices)
                DropdownMenuItem(
                  value: option,
                  child: Text('${option.number} ${option.destination.label}'),
                ),
            ],
            onChanged: _submitting
                ? null
                : (option) => setState(() => _selected = option),
          ),
          if (_submitting)
            const LinearProgressIndicator()
          else
            FilledButton(
              onPressed: _selected == null ? null : _submit,
              child: Text(assigned == null ? '버스 신청' : '버스 변경'),
            ),
        ],
      ],
    );
  }
}
