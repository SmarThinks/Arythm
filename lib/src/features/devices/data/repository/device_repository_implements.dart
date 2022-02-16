import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';
import 'package:tracker_test/src/features/devices/data/local/blue_device_local_data_source.dart';
import 'package:tracker_test/src/features/devices/data/models/device_modal.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/domain/repository/device_repository.dart';

class DeviceRepositoryImplements extends DeviceRepository {
  DeviceRepositoryImplements({required this.localDataSource});
  final BlueDeviceLocalDataSource localDataSource;
  @override
  Either<Failure, Stream<List<DeviceModel>>> searchDevices(List<String>searchTerms) {
    try {
      final result = localDataSource.searchDevices(searchTerms);
      return Right(result);
    } on Exception {
      return Left(BluetoothFailure());
    }
  }

  @override
  Either<Failure, bool> connect(DeviceEntity device) {
    try {
      final result = localDataSource.connect(device as DeviceModel);
      return Right(result);
    } on Exception {
      return Left(BluetoothFailure());
    }
  }

  @override
  Either<Failure, bool> disconnect(DeviceEntity device) {
    try {
      final result = localDataSource.disconnect(device as DeviceModel);
      return Right(result);
    } on Exception {
      return Left(BluetoothFailure());
    }
  }

}
