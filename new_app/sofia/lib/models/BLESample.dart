import 'dart:core';

import 'package:sofia/enums/ble_device_type.dart';

class BLESample {
  String deviceId;
  BleDeviceType deviceType;
  String alias;
  DateTime timestamp;
  double? txPower;
  double? rxPower;

  BLESample({
    required this.deviceId,
    required this.deviceType,
    required this.alias,
    required this.timestamp,
    this.txPower,
    this.rxPower,
  });

  @override
  String toString() {
    return 'BLESample{'
        'deviceId: $deviceId, '
        'deviceType: $deviceType, '
        'alias: $alias, '
        'timestamp: $timestamp, '
        'txPower: $txPower, '
        'rxPower: $rxPower'
        '}';
  }
}
