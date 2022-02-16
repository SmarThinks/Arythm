import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/search_devices.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit({required this.searchDevicesUseCase})
      : super(const DeviceListState.initial());
  final SearchDevicesUseCase searchDevicesUseCase;
  void startSearching([List<String> searchPrefix = const <String>[]]) {
    emit(const DeviceListState.searching());
    final result =
        searchDevicesUseCase.call(SearchParams(searchTerms: searchPrefix));
    result.fold(
        (l) => emit(
            const DeviceListState.error("No se puede habilitar el Bluetooth")),
        (stream) => stream.forEach((event) {
              emit(DeviceListState.done(event));
            }));
  }
}
