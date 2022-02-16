import 'package:flutter_blue/flutter_blue.dart';
import 'package:tracker_test/src/core/exceptions.dart';
import 'package:tracker_test/src/features/devices/data/local/helpers/blue_device_extension.dart';
import 'package:tracker_test/src/features/devices/data/models/device_modal.dart';
import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';

abstract class BlueDeviceLocalDataSource {
  Stream<List<DeviceModel>> searchDevices(List<String> searchTerms);

  bool connect(DeviceModel device);
  bool disconnect(DeviceModel device);
}

class BlueDeviceLocalDataSourceImplements extends BlueDeviceLocalDataSource {
  @override
  Stream<List<DeviceModel>> searchDevices(searchTerms) {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    flutterBlue.startScan(timeout: const Duration(seconds: 5));
    return flutterBlue.scanResults.map((event) => event
            .map((e) => DeviceModel(
                  id: e.device.id.id,
                  name: e.device.name,
                  strenght: e.rssi,
                  kind: DeviceKind.ble,
                ))
            .where((deviceModel) {
          if (searchTerms.isNotEmpty) {
            final regex = r'(' +
                searchTerms.reduce((value, element) => '$value|$element') +
                ')';
            flutterBlue.stopScan();
            return deviceModel.name.contains(RegExp(regex));
          }
          return true;
        }).toList());
  }

  @override
  bool connect(DeviceModel device) {
    final blueDevice = device.toBlueoothDevice();
    blueDevice
        .connect()
        .onError((error, stackTrace) => throw UnableToConnectException());

    return true;
  }

  @override
  bool disconnect(DeviceModel device) {
    final blueDevice = device.toBlueoothDevice();
    blueDevice
        .disconnect()
        .onError((error, stackTrace) => throw UnableToConnectException());
    return true;
  }
}
