// import 'dart:async';

// import 'package:sofia_test_app/enums/direction.dart';
// import 'package:sofia_test_app/enums/operation_mode.dart';
// import 'package:sofia_test_app/enums/type_mission_status.dart';
// import 'package:sofia_test_app/models/BLEDevice.dart';
// import 'package:sofia_test_app/models/user.dart';


// typedef NearestDeviceChangedHandler = void Function(BLEDevice device);
// typedef FloorChangedHandler = void Function(String floor);
// typedef MissionStatusChangedHandler = void Function();
// typedef CharacteristicUpdatedHandler = void Function();
// typedef DeviceDisconnectedHandler = void Function();

// abstract class ICoreController {
//   bool? isInForeground;
//   List<BLEDevice>? devices;
//   BLEDevice? nearestDevice;
//   BLEDevice? car;
//   User? loggerUser;
//   //IDataLoggerService? dataLogger;
//   OperationMode? operationMode;
//   bool? outOfService;
//   bool? presenceOfLight;
//   String? carFloor;
//   int? carFloorNum;

//   Direction? get carDirection;
//   set carDirection(Direction? value);
//   int? eta;
//   TypeMissionStatus? get missionStatus;
//   set missionStatus(TypeMissionStatus? value);

//   Future<void> startScanningAsync();
//   Future<void> stopScanningAsync();
//   Future<void> changeFloorAsync(List<int> destinationFloor);
//   Future<void> getCarFloor();
//   Future<void> connectDevice(BLEDevice device);

//   // Event declarations
//   late StreamController<BLEDevice> _nearestDeviceChangedController;
//   late StreamController<String> _floorChangedController;
//   late StreamController<void> _missionStatusChangedController;
//   late StreamController<void> _characteristicUpdatedController;
//   late StreamController<void> _deviceDisconnectedController;

//   // Event subscriptions
//   Stream<BLEDevice> get onNearestDeviceChanged => _nearestDeviceChangedController.stream;
//   Stream<String> get onFloorChanged => _floorChangedController.stream;
//   Stream<void> get onMissionStatusChanged => _missionStatusChangedController.stream;
//   Stream<void> get onCharacteristicUpdated => _characteristicUpdatedController.stream;
//   Stream<void> get onDeviceDisconnected => _deviceDisconnectedController.stream;

//   // Event handlers
//   void coreController_OnNearestDeviceChanged(BLEDevice device) {
//     _nearestDeviceChangedController.add(device);
//   }

//   void coreController_OnFloorChanged(String floor) {
//     _floorChangedController.add(floor);
//   }

//   void coreController_OnMissionStatusChanged() {
//     _missionStatusChangedController.add(null);
//   }

//   void coreController_OnCharacteristicUpdated() {
//     _characteristicUpdatedController.add(null);
//   }

//   void coreController_OnDeviceDisconnected() {
//     _deviceDisconnectedController.add(null);
//   }

// //    static final StreamController<BLEDevice> _nearestDeviceController =
// //       StreamController<BLEDevice>.broadcast();
// //   static final StreamController<String> _floorController =
// //       StreamController<String>.broadcast();
// //   static final StreamController<void> _missionStatusController =
// //       StreamController<void>.broadcast();
// //   static final StreamController<void> _characteristicUpdatedController =
// //       StreamController<void>.broadcast();
// //   static final StreamController<void> _deviceDisconnectedController =
// //       StreamController<void>.broadcast();


// //  static Stream<BLEDevice> get onNearestDeviceChanged =>
// //       _nearestDeviceController.stream;

// //   static Stream<String> get onFloorChanged => _floorController.stream;

// //   static Stream<void> get onMissionStatusChanged =>
// //       _missionStatusController.stream;

// //   static Stream<void> get onCharacteristicUpdated =>
// //       _characteristicUpdatedController.stream;

// //   static Stream<void> get onDeviceDisconnected =>
// //       _deviceDisconnectedController.stream;


// }


import 'dart:async';

import 'package:sofia_test_app/enums/direction.dart';
import 'package:sofia_test_app/enums/operation_mode.dart';
import 'package:sofia_test_app/enums/type_mission_status.dart';
import 'package:sofia_test_app/models/BLEDevice.dart';
import 'package:sofia_test_app/models/BLESample.dart';
import 'package:sofia_test_app/models/user.dart';

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
