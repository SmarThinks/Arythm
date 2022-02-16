class DeviceEntity {
  DeviceEntity({
    required this.id,
    required this.name,
    required this.strenght,
    required this.kind,
  });

  final String id;
  final String name;
  final int strenght;
  final DeviceKind kind;

  factory DeviceEntity.empty() {
    return DeviceEntity(id: '', name: '', strenght: 0, kind: DeviceKind.none);
  }
}

enum DeviceKind {
  ble,
  wifi,
  classicBluetooth,
  usb,
  none,
  unknown,
}
