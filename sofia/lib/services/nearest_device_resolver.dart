import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sofia/enums/ble_device_type.dart';
import 'package:sofia/interfaces/i_nearest_device_service.dart';
import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/models/BLESample.dart';

class NearestDeviceResolver implements INearestDeviceResolver {
  static const int NEAREST_DEVICE_TIMEOUT = 3000;
  static const int UNREACHABLE_DEVICE_TIMEOUT = 5000;

  DateTime? nearestDeviceAssignTimestamp;
  bool isRaised = false;
  BLEDevice? tmpNearestDevice;
  bool? _monitoraggioSoloPiano = false;
  List<BLEDevice> devices = [];

  @override
  BLEDevice? nearestDevice;

  final ValueNotifier<BLEDevice?> onNearestDeviceChangedNotifier =
      ValueNotifier<BLEDevice?>(null);

  final StreamController<BLEDevice> _onNearestDeviceChanged =
      StreamController<BLEDevice>.broadcast();

  NearestDeviceResolver() {
    _monitoraggioSoloPiano = true;
    devices = <BLEDevice>[];
  }

  @override
  Stream<BLEDevice> get onNearestDeviceChanged =>
      _onNearestDeviceChanged.stream;

  @override
  void addSample(BLESample sample) {
    var device = findDevice(sample);
    device.samples.enqueue(sample);
    refreshNearestDevice(sample.timestamp);
  }

  @override
  void refreshNearestDevice(DateTime timestamp) {
    clearUnreachableDevices(
        timestamp.subtract(Duration(milliseconds: UNREACHABLE_DEVICE_TIMEOUT)));
    var currentNearestDevice =
        getNearestDeviceImpl(devices.toList()); // Convert to List
    var lastTs = currentNearestDevice != null
        ? currentNearestDevice.lastSampleTimestamp!
        : timestamp;
    if (currentNearestDevice != tmpNearestDevice) {
      nearestDeviceAssignTimestamp = lastTs;
      isRaised = false;
      tmpNearestDevice = currentNearestDevice;
    }

    if (isTimeToFireEvent(lastTs)) {
      if (tmpNearestDevice != null) {
        nearestDevice = tmpNearestDevice;
        fireEvent();
        isRaised = true;
      }
    }
  }

  @override
  void clearUnreachableDevices(DateTime from) {
    devices.removeWhere((d) =>
        d.lastSampleTimestamp != null && d.lastSampleTimestamp!.isBefore(from));
  }

  BLEDevice findDevice(BLESample sample) {
    var device = devices.firstWhere(
      (d) => d.id == sample.deviceId,
      orElse: () {
        var newDevice = BLEDevice(
          type: sample.deviceType,
          id: sample.deviceId,
          alias: sample.alias,
        );
        devices.add(newDevice);
        print(
            "***************findDevice in nearestDeviceResolver**********$devices");
        return newDevice;
      },
    );
    return device;
  }

  BLEDevice? getNearestDeviceImpl(List<BLEDevice> devices) {
    print("======getNearestDeviceImp============$devices");
    if (_monitoraggioSoloPiano == true) {
      debugPrint("Check for nearestDevices$devices");

      if (devices.where((d) => d.type == BleDeviceType.esp32).length == 0) {
        return null;
      }
    } else {
      if (devices.isEmpty) {
        return null;
      }
    }
    print("=====Devices=============$devices");
    var nearestDevice = devices.firstOrNull;
    print("========nearestdevice==========$nearestDevice");
    var maxRxPowerValue = double.negativeInfinity;
    double? avgRxPowerValue = double.negativeInfinity;

    for (var device in devices) {
      if (_monitoraggioSoloPiano! && device.type == BleDeviceType.esp32) {
        avgRxPowerValue = device.avgRxPower;
      }
      if (!_monitoraggioSoloPiano!) {
        avgRxPowerValue = device.avgRxPower;
      }

      if (avgRxPowerValue != null && avgRxPowerValue > maxRxPowerValue) {
        maxRxPowerValue = avgRxPowerValue;
        nearestDevice = device;
      }
    }

    print("=================NearDevice =======$nearestDevice");
    return nearestDevice;
  }

  bool isTimeToFireEvent(DateTime currentStampleTimestamp) {
    if (isRaised) {
      return false;
    }

    if (devices.isEmpty) {
      return true;
    }

    if (devices.length == 1) {
      return true;
    }

    if (tmpNearestDevice?.type == BleDeviceType.car) {
      return true;
    }

    var delay = currentStampleTimestamp.difference(currentStampleTimestamp);
    return delay.inMilliseconds >= NEAREST_DEVICE_TIMEOUT;
  }

  void fireEvent() {
    onNearestDeviceChangedNotifier.value = nearestDevice;
    _onNearestDeviceChanged.add(nearestDevice!);
  }

  @override
  bool get monitoraggioSoloPiano => _monitoraggioSoloPiano!;

  @override
  set monitoraggioSoloPiano(bool? value) {
    _monitoraggioSoloPiano = value ?? false;
  }

  void dispose() {
    onNearestDeviceChangedNotifier.dispose();
    _onNearestDeviceChanged.close();
  }
}
