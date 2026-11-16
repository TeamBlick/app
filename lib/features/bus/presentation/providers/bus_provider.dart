import 'package:blick/features/bus/data/models/student_bus_models.dart';
import 'package:blick/features/bus/data/repositories/bus_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final busProvider = AsyncNotifierProvider.autoDispose
    .family<BusController, StudentBusState?, BusRepository>(BusController.new);

class BusController
    extends AutoDisposeFamilyAsyncNotifier<StudentBusState?, BusRepository> {
  late BusRepository _repository;

  @override
  Future<StudentBusState?> build(BusRepository repository) {
    _repository = repository;
    return _repository.getBusState();
  }

  Future<String?> select(BusOption option) async {
    final previous = state.valueOrNull;
    if (state.isLoading ||
        previous == null ||
        previous.assigned?.id == option.id) {
      return null;
    }

    final link = ref.keepAlive();
    try {
      state = const AsyncLoading();
      final String message;
      final BusOption assigned;
      if (previous.assigned == null) {
        final result = await _repository.requestBus(
          BusRequest(
            busId: option.id,
            busDestination: option.destination.apiValue,
          ),
        );
        assigned = BusOption(
          id: result.busId ?? option.id,
          number: result.busNumber ?? option.number,
          destination: option.destination,
        );
        message = '버스를 신청했습니다.';
      } else {
        final result = await _repository.changeBus(
          BusChangeRequest(newBusId: option.id),
        );
        assigned = BusOption(
          id: option.id,
          number: result.newBusNumber ?? option.number,
          destination: option.destination,
        );
        message = result.message;
      }
      state = AsyncData(
        StudentBusState(choices: previous.choices, assigned: assigned),
      );
      return message;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      link.close();
    }
  }
}
