import 'dart:core';
import 'package:sofia/enums/ble_device_type.dart';
import 'package:sofia/models/BLESample.dart';
import 'package:sofia/models/LimitedQueue.dart';

class BLEDevice {
  BleDeviceType type;
  String id;
  String alias;
  LimitedQueue<BLESample> samples;

  static const int MAX_POWER_LEVEL = 6;
  static const int SAMPLE_QUEUE_CAPACITY = 5;
  static const int IS_ALIVE_TIMEOUT = 2000;

  BLEDevice({
    required this.type,
    required this.id,
    required this.alias,
  }) : samples = LimitedQueue<BLESample>(SAMPLE_QUEUE_CAPACITY);

  DateTime? get lastSampleTimestamp =>
      samples.isNotEmpty ? samples.last!.timestamp : null;

  bool get isAlive =>
      lastSampleTimestamp != null &&
      DateTime.now().difference(lastSampleTimestamp!) <
          Duration(milliseconds: IS_ALIVE_TIMEOUT);

  double? get avgRxPower {
    var samplesWithTxPower = samples
        .where((s) => s.txPower != null); // && s.txPower == MAX_POWER_LEVEL);
    if (samplesWithTxPower.isEmpty) {
      return null;
    }

    var avg = samplesWithTxPower
            .map((s) => s.rxPower ?? 0)
            .reduce((a, b) => (a ?? 0) + (b ?? 0)) /
        samplesWithTxPower.length;
    return avg;
  }

  double? get lastRxPower {
    BLESample? lastSample;
    List<BLESample> sampleList = samples.toList();
    for (int i = sampleList.length - 1; i >= 0; i--) {
      if (sampleList[i].txPower != null) {
        lastSample = sampleList[i];
        break;
      }
    }
    return lastSample?.rxPower;
  }

  @override
  String toString() {
    return '${type.toString().split('.').last} - $alias (LST: ${lastRxPower?.toStringAsFixed(0)}) (AVG: ${avgRxPower?.toStringAsFixed(0)})';
  }
}
