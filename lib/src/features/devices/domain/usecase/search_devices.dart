import 'package:dartz/dartz.dart';
import 'package:tracker_test/src/core/failures.dart';
import 'package:tracker_test/src/core/usecases.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';
import 'package:tracker_test/src/features/devices/domain/repository/device_repository.dart';

class SearchDevicesUseCase extends UseCase<void, SearchParams> {
  SearchDevicesUseCase({required this.deviceRepository});
  final DeviceRepository deviceRepository;
  @override
  Either<Failure, Stream<List<DeviceEntity>>> call(SearchParams params) {
    return deviceRepository.searchDevices(params.searchTerms);
  }
}

class SearchParams {
  SearchParams({required this.searchTerms});
  final List<String> searchTerms;
}
