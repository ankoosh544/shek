import 'package:sofia/models/BLECharacteristicEventArgs.dart';
import 'package:sofia/models/BLESample.dart';

abstract class IBleService {
  static const String FLOOR_SERVICE_GUID =
      '6c962546-6011-4e1b-9d8c-05027adb3a01';
  static const String CAR_SERVICE_GUID = '6c962546-6011-4e1b-9d8c-05027adb3a02';

  static const String ESP_SERVICE_GUID = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';

  String get connectedDeviceId;

  List<int> get valueFromCharacteristic;

  void timer1msTickk();

  Stream<BLESample> get onSampleReceived;

  Stream<void> get onScanningEnd;

  Stream<void> get onDeviceConnected;

  Stream<void> get onDeviceDisconnected;

  Stream<BLECharacteristicEventArgs> get onCharacteristicUpdated;

  Future<void> startScanningAsync(int scanTimeout);

  Future<void> stopScanningAsync();

  Future<void> connectToDeviceAsync(String deviceId);

  Future<void> disconnectToDeviceAsync();

  Future<void> startCharacteristicWatchAsync(
      String serviceGuid, String characteristicGuid);

  Future<void> stopCharacteristicWatchAsync(
      String serviceGuid, String characteristicGuid);

  Future<void> sendCommandAsync(
      String serviceGuid, String characteristicGuid, List<int> message);

  Future<void> getValueFromCharacteristicGuid(
      String serviceGuid, String characteristicGuid);
}
