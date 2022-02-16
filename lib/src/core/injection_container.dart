import 'package:get_it/get_it.dart';
import 'package:tracker_test/src/features/devices/data/local/blue_device_local_data_source.dart';
import 'package:tracker_test/src/features/devices/data/repository/device_repository_implements.dart';
import 'package:tracker_test/src/features/devices/domain/repository/device_repository.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/connect_devices.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/disconnect_devices.dart';
import 'package:tracker_test/src/features/devices/domain/usecase/search_devices.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_list_cubic.dart';
import 'package:tracker_test/src/features/devices/presentation/bloc/device_selected_cubic.dart';

final s1 = GetIt.instance;

Future<void> init() async {
  s1.registerFactory<BlueDeviceLocalDataSource>(
      () => BlueDeviceLocalDataSourceImplements());
  s1.registerFactory<DeviceRepository>(
      () => DeviceRepositoryImplements(localDataSource: s1()));
  s1.registerFactory<ConnectDeviceUseCase>(
      () => ConnectDeviceUseCase(deviceRepository: s1()));
  s1.registerFactory<DisconnectDeviceUseCase>(
      () => DisconnectDeviceUseCase(deviceRepository: s1()));
  s1.registerFactory(
      () => SearchDevicesUseCase(deviceRepository: s1()));
  s1.registerSingleton<DeviceListCubit>(
      DeviceListCubit(searchDevicesUseCase: s1()));      
  s1.registerSingleton<DeviceSelectedCubit>(
      DeviceSelectedCubit(connectDeviceUseCase: s1(), disconnectDeviceUseCase: s1()));
}
