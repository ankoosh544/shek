import 'dart:async';
import 'package:sofia/enums/direction.dart';
import 'package:sofia/enums/operation_mode.dart';
import 'package:sofia/enums/type_mission_status.dart';
import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/models/BLESample.dart';
import 'package:sofia/models/user.dart';

abstract class ICoreController {
  bool? isInForeground;
  List<BLEDevice>? devices;
  BLEDevice? nearestDevice;
  BLEDevice? car;
  User? loggerUser;
  // IDataLoggerService dataLogger;
  OperationMode? operationMode = OperationMode.idle;
  bool? outOfService;
  bool? presenceOfLight;
  String? carFloor;
  int get carFloorNum {
    return int.tryParse(carFloor ?? '') ?? 0;
  }

  Direction? carDirection;
  int? eta;

  TypeMissionStatus? get missionStatus;
  set missionStatus(TypeMissionStatus? value);
  Stream<BLEDevice> get onNearestDeviceChanged;
  Stream<String> get onFloorChanged;
  Stream<void> get onMissionStatusChanged;
  Stream<void> get onCharacteristicUpdated;
  Stream<void> get onDeviceDisconnected;

  Future<void> startScanningAsync();
  Future<void> stopScanningAsync();
  Future<void> changeFloorAsync(List<int> destinationFloor);
  Future<void> getCarFloor();
  Future<void> connectDevice(BLEDevice device);
}
