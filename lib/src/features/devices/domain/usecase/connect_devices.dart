import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';
import 'package:tracker_test/src/core/usecases.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/domain/repository/device_repository.dart';

class ConnectDeviceUseCase extends UseCase<void, DeviceParams> {
  ConnectDeviceUseCase({required this.deviceRepository});
  final DeviceRepository deviceRepository;
  @override
  Either<Failure, bool> call(DeviceParams params) {
    return deviceRepository.connect(params.device);
  }
}

class DeviceParams {
  DeviceParams({required this.device});
  final DeviceEntity device;
}
