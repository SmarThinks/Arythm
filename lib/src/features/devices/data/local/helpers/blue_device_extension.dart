import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue/gen/flutterblue.pb.dart' as proto;
import 'package:tracker_test/src/features/devices/data/models/device_modal.dart';

extension BlueDeviceExtension on DeviceModel {
  BluetoothDevice toBlueoothDevice() {
    proto.BluetoothDevice blueProto = proto.BluetoothDevice.create();
    blueProto.name = name;
    blueProto.type = proto.BluetoothDevice_Type.LE;
    blueProto.remoteId = id;
    return BluetoothDevice.fromProto(blueProto);
  }
}
