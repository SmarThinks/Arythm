import 'package:tracker_test/src/features/devices/domain/entity/device_entity.dart';

class DeviceModel extends DeviceEntity {
  DeviceModel({
    required String id,
    required String name,
    required int strenght,
    required DeviceKind kind,
  }) : super(id: id, name: name, strenght: strenght, kind: kind);
}
