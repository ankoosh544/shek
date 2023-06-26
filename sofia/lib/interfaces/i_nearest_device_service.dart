import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/models/BLESample.dart';

abstract class INearestDeviceResolver {
  List<BLEDevice> get devices;
  BLEDevice? get nearestDevice;
  bool? monitoraggioSoloPiano;

  void addSample(BLESample sample);
  void refreshNearestDevice(DateTime timestamp);
  void clearUnreachableDevices(DateTime from);

  Stream<BLEDevice> get onNearestDeviceChanged;
}
