import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';
import 'package:tracker_test/src/core/usecases.dart';
import 'package:tracker_test/src/features/devices/domain/repository/device_repository.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/connect_devices.dart';

class DisconnectDeviceUseCase extends UseCase<void, DeviceParams> {
  DisconnectDeviceUseCase({required this.deviceRepository});
  final DeviceRepository deviceRepository;
  @override
  Either<Failure, bool> call(DeviceParams params) {
    return deviceRepository.disconnect(params.device);
  }
}
