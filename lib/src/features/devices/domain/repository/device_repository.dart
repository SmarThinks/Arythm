import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';
import 'package:tracker_test/src/features/devices/data/models/device_modal.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';

abstract class DeviceRepository {
  Either<Failure, Stream<List<DeviceModel>>> searchDevices(
      List<String> searchTerms);
  Either<Failure, bool> connect(DeviceEntity device);
  Either<Failure, bool> disconnect(DeviceEntity device);
}
