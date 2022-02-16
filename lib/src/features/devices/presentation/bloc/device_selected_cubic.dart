import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/connect_devices.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/disconnect_devices.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_state.dart';

class DeviceSelectedCubit extends Cubit<DeviceState> {
  DeviceSelectedCubit({required this.connectDeviceUseCase, required this.disconnectDeviceUseCase})
      : super(DeviceState.initial());
  final ConnectDeviceUseCase connectDeviceUseCase;
  final DisconnectDeviceUseCase disconnectDeviceUseCase;

  void connect(DeviceEntity device) {
    final result = connectDeviceUseCase.call(DeviceParams(device: device));

    result.fold((l) => emit(DeviceState.error('No se pudo conectar')),
        (r) => emit(DeviceState.connected(device, true)));
  }
   void disconnect(DeviceEntity device) {
    final result = disconnectDeviceUseCase.call(DeviceParams(device: device));

    result.fold((l) => emit(DeviceState.error('No se pudo desconectar')),
        (r) => emit(DeviceState.connected(device, false)));
  }
}
