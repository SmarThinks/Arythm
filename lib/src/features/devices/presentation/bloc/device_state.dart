import 'package:equatable/equatable.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';

enum DeviceStatus {
  initial,
  connected,
  error,
}

class DeviceState extends Equatable {
  DeviceState.initial()
      : device = DeviceEntity.empty(),
        message = null,
        connected = false,
        status = DeviceStatus.initial;

  const DeviceState.connected(this.device, this.connected)
      : message = null,
        status = DeviceStatus.connected;

  DeviceState.error(this.message)
      : device = DeviceEntity.empty(),
        connected = false,
        status = DeviceStatus.error;

  final DeviceStatus status;
  final String? message;
  final DeviceEntity device;
  final bool connected;

  @override
  List<Object?> get props => [
        message,
        device,
        status,
        connected,
      ];
}
