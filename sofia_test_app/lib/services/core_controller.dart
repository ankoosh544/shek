import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sofia_test_app/enums/ble_device_type.dart';
import 'package:sofia_test_app/enums/direction.dart';
import 'package:sofia_test_app/enums/operation_mode.dart';
import 'package:sofia_test_app/enums/type_mission_status.dart';
import 'package:sofia_test_app/interfaces/i_audio_service.dart';
import 'package:sofia_test_app/interfaces/i_auth_service.dart';
import 'package:sofia_test_app/interfaces/i_ble_service.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/interfaces/i_data_logger_service.dart';
import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';
import 'package:sofia_test_app/interfaces/i_notification_manager.dart';
import 'package:sofia_test_app/models/BLECharacteristicEventArgs.dart';
import 'package:sofia_test_app/models/BLEDevice.dart';
import 'package:sofia_test_app/models/BLESample.dart';
import 'package:sofia_test_app/models/user.dart';
import 'package:vibration/vibration.dart';

class CoreController implements ICoreController {
  // Constants
  static const int SCAN_TIMEOUT = -1; // infinito
  static const int REFRESH_TIMEOUT = 500; // 500 ms
  static const double MIN_CAR_RX_POWER = -700;

  static const String FLOOR_REQUEST_CHARACTERISTIC_GUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String FLOOR_CHANGE_CHARACTERISTIC_GUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a9";
  static const String ESP_EXAMPLE_CHARACTERTISTIC_GUID =
      "00002a05-0000-1000-8000-00805f9b34fb";
  static const String MISSION_STATUS_CHARACTERISTIC_GUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26aa";
  static const String OUT_OF_SERVICE_CHARACTERISTIC_GUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26ab";
  static const String MOVEMENT_DIRECTION_CAR =
      "beb5483e-36e1-4688-b7f5-ea07361b26ac";

  List<String> Characteristics = [];
  int IntervalloAvvisoVicinoAscensore = 60;
  int tickAttuali = 0;
  int SecondiPassati = 0;
  bool PrimaConnessioneDevice = true;
  bool ConnessioneInCorso = false;

  late IAuthService authService;
  late IBleService bleService;
  late INotificationManager notificationManager;
  late INearestDeviceResolver resolver;
  late IAudioService audioService;
  late IDataLoggerService dataloggerService;

  bool isStarted = false;

//isInForeground
  bool? _isInForeground = false;
  @override
  bool? get isInForeground => _isInForeground;

  @override
  set isInForeground(bool? value) {
    _isInForeground = value;
  }

//////
  List<BLEDevice>? _devices;
  @override
  List<BLEDevice> get devices => resolver?.devices ?? [];
  @override
  set devices(List<BLEDevice>? value) {
    _devices = value;
  }

  BLEDevice? _car;
  @override
  BLEDevice? get car {
    final currentDevices = devices;
    if (currentDevices != null) {
      return findCar(currentDevices);
    }
    return null;
  }

  @override
  set car(BLEDevice? value) {
    _car = value;
  }

  BLEDevice? _nearestDevice;
  @override
  BLEDevice? get nearestDevice => resolver?.nearestDevice;
  @override
  set nearestDevice(BLEDevice? value) {
    _nearestDevice = value;
  }

//loggerUser
  User? _loggerUser;
  @override
  User? get loggerUser => _loggerUser;
  @override
  set loggerUser(User? value) {
    _loggerUser = value;
  }

  IDataLoggerService get dataLogger => dataloggerService;

  OperationMode? _operationMode;

  @override
  OperationMode? get operationMode => _operationMode;
  @override
  set operationMode(OperationMode? value) {
    _operationMode = value;
  }

  bool? _outOfService = false;

  @override
  bool? get outOfService => _outOfService;

  @override
  set outOfService(bool? value) {
    _outOfService = value;
  }

  bool? _presenceOfLight = true;

  @override
  bool? get presenceOfLight => _presenceOfLight;
  @override
  set presenceOfLight(bool? value) {
    _presenceOfLight = value;
  }

  String? _carFloor = "--";

  @override
  String? get carFloor => _carFloor;

  @override
  set carFloor(String? value) {
    _carFloor = value;
  }

  Direction? _carDirection = Direction.stopped;

  Direction? get carDirection => _carDirection;

  set carDirection(Direction? value) {
    _carDirection = value;
  }

  @override
  TypeMissionStatus? get missionStatus => TypeMissionStatus.MISSION_NO_INIT;

  @override
  set missionStatus(TypeMissionStatus? status) {
    missionStatus = status;
  }

  int? _eta = -1;
  @override
  int? get eta => _eta;
  @override
  set eta(int? value) {
    _eta = value;
  }

  //events
  final StreamController<BLEDevice> _nearestDeviceController =
      StreamController<BLEDevice>.broadcast();
  final StreamController<String> _floorController =
      StreamController<String>.broadcast();
  final StreamController<void> _missionStatusController =
      StreamController<void>.broadcast();
  final StreamController<void> _characteristicUpdatedController =
      StreamController<void>.broadcast();
  final StreamController<void> _deviceDisconnectedController =
      StreamController<void>.broadcast();
  @override
  Stream<BLEDevice> get onNearestDeviceChanged =>
      _nearestDeviceController.stream;
  @override
  Stream<String> get onFloorChanged => _floorController.stream;
  @override
  Stream<void> get onMissionStatusChanged => _missionStatusController.stream;
  @override
  Stream<void> get onCharacteristicUpdated =>
      _characteristicUpdatedController.stream;
  @override
  Stream<void> get onDeviceDisconnected => _deviceDisconnectedController.stream;


  CoreController() {
    authService = GetIt.instance<IAuthService>();
    bleService = GetIt.instance<IBleService>();
    notificationManager = GetIt.instance<INotificationManager>();
    resolver = GetIt.instance<INearestDeviceResolver>();
    audioService = GetIt.instance<IAudioService>();
    dataloggerService = GetIt.instance<IDataLoggerService>();

    notificationManager.notificationReceived.listen((notification) {
      NotificationManager_NotificationReceived;
    });

    bleService.onSampleReceived.listen((sample) {
      BleService_OnSampleReceived(sample);
    });

    bleService.onDeviceDisconnected.listen((device) {
      bleService_OnDeviceDisconnected;
    });

    resolver.onNearestDeviceChanged.listen((nearestDevice) {
      Resolver_NearestDeviceChanged(nearestDevice);
    });

    bleService.timer1msTickk();

    Characteristics.add(FLOOR_CHANGE_CHARACTERISTIC_GUID);
    Characteristics.add(ESP_EXAMPLE_CHARACTERTISTIC_GUID);
    Characteristics.add(MISSION_STATUS_CHARACTERISTIC_GUID);
    Characteristics.add(OUT_OF_SERVICE_CHARACTERISTIC_GUID);
    //Characteristics.add(MOVEMENT_DIRECTION_CAR);

    // Other initialization or event listeners can be added here as needed
  }

  void NotificationManager_NotificationReceived(
      dynamic sender, BuildContext context) async {
    if (await authService.isLoggedAsync()) {
      await Navigator.pushReplacementNamed(context, "/commandPage");
    } else {
      await Navigator.pushReplacementNamed(context, "/loginPage");
    }
  }

  void BleService_OnSampleReceived(BLESample sample) {
    dataloggerService.addSample(sample);
    resolver.addSample(sample);
  }

 void bleService_OnDeviceDisconnected() async {
  try {
        _deviceDisconnectedController.onCancel;
      _deviceDisconnectedController.add(null);
    
    } catch (ex) {
      // if (Preferences.get('DevOptions', false) == true) {
      //   await showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //       title: Text('Alert'),
      //       content: Text('${ex.message}\n${ex.stackTrace}\n${ex.source}'),
      //       actions: [
      //         TextButton(
      //           child: Text('OK'),
      //           onPressed: () => Navigator.pop(context),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   debugPrint('${ex.message}\n${ex.stackTrace}\n${ex.source}');
      // }
    }
  }

  void Resolver_NearestDeviceChanged(BLEDevice device) async {
    if (device == null) {
      return;
    }

    if (ConnessioneInCorso) {
      print("====================================Device is ConnessioneInCorso");
      return;
    }
    print("====================================Device check");
    ConnessioneInCorso = true;
    await connectDeviceAndRead(device);
    if (device != null) {
      emitNotifications(device);
    }

    if (onNearestDeviceChanged != null) {
      _nearestDeviceController.add(device);
    }

    if (operationMode == OperationMode.changeFloorMission) {
      print("OperationMode is changeFloorMission");
      if (bleService.connectedDeviceId.isNotEmpty) {
        await bleService.disconnectToDeviceAsync();
        await stopCharacteristicWatchAsync();
        await bleService.connectToDeviceAsync(device.id);
        await startCharacteristicReadWatchAsync();
      }
    }

    ConnessioneInCorso = false;
  }

  
  void dispose() {
    _nearestDeviceController.close();
    _floorController.close();
    _missionStatusController.close();
    _characteristicUpdatedController.close();
    _deviceDisconnectedController.close();
  }

  set carFloorNum(int? floorNum) {
    // Set the car floor number.
    // Implement your own logic here.
  }

  int get carFloorNum {
    int val;
    try {
      val = int.parse(carFloor ?? '');
    } catch (e) {
      val = 0; // Provide a default value if parsing fails
    }
    return val;
  }

  @override
  Future<void> startScanningAsync() async {
    isStarted = true;
    notificationManager.initialize();
    operationMode = OperationMode.deviceScanning;

    Timer.periodic(Duration(milliseconds: REFRESH_TIMEOUT), (timer) {
      // il refresh in polling viene fatto solo se non ricevo più campioni dal nearest device
      if (nearestDevice != null && !nearestDevice!.isAlive)
        resolver.refreshNearestDevice(DateTime.now());

      if (!isStarted) {
        timer.cancel();
      }
    });

    await bleService.startScanningAsync(SCAN_TIMEOUT);
  }

  @override
  Future<void> stopScanningAsync() async {
    isStarted = false;
    operationMode = OperationMode.idle;
    await bleService.stopScanningAsync();
  }

  @override
  Future<void> changeFloorAsync(List<int> destinationFloor) async {
    try {
      // cambio modalità operativa
      operationMode = OperationMode.changeFloorMission;

      // connessione dispositivo più vicino
      await bleService.connectToDeviceAsync(nearestDevice!.id);

      // invio comando BLE
      await bleService.sendCommandAsync(IBleService.ESP_SERVICE_GUID,
          FLOOR_REQUEST_CHARACTERISTIC_GUID, destinationFloor);

      // avvio monitoraggio "Cambio piano" e "Fine monitoraggio"
      // await startCharacteristicWatchAsync();
    } catch (e) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current.mainPage
      //       .displayAlert("Alert", "Errore invio chiamata", "Ok");
      // } else {
      //   debugPrint("Errore invio chiamata");
      // }
    }
  }

  @override
  Future<void> getCarFloor() async {
    // Get the current floor of the car.
    // Implement your own logic here.
  }

  @override
  Future<void> connectDevice(BLEDevice device) async {
    try {
      print("===============Alias device:===========$device");
      if (bleService.connectedDeviceId != null) {
        if (device == null) {
          return;
        }
        if (bleService.connectedDeviceId.isEmpty) {
          await connectDeviceAndRead(device);
        }
      }
    } catch (ex) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current
      //       .showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
      // } else {
      //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
      // }
    }
  }

  Future<void> connectDeviceAndRead(BLEDevice device) async {
    try {
      if (bleService.connectedDeviceId.toString() == "") {
        if (device != null) {
          await bleService.connectToDeviceAsync(device.id);

          await getPianoCabina();
          await startCharacteristicReadWatchAsync();
        }
        return;
      }
    } catch (ex) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current.showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
      // } else {
      //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
      // }
    }

    try {
      if (bleService.connectedDeviceId.toString() != device.id.toString()) {
        await stopCharacteristicWatchAsync();
        await bleService.disconnectToDeviceAsync();

        await bleService.connectToDeviceAsync(device.id);
        await getPianoCabina();
        await startCharacteristicReadWatchAsync();
        return;
      }
    } catch (ex) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current.showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
      // } else {
      //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
      // }
    }
  }

  // Future<void> getPianoCabina() async {
  //   try {
  //     carFloor = "999";
  //     if (bleService.connectedDeviceId.toString() != "") {
  //       try {
  //         await bleService.getValueFromCharacteristicGuid(
  //             IBleService.FLOOR_SERVICE_GUID, FLOOR_CHANGE_CHARACTERISTIC_GUID);
  //       } catch (e) {
  //         return;
  //         // await App.Current.MainPage.DisplayAlert("Alert", ex.Message + "\r\n" + ex.StackTrace + "\r\n" + ex.Source, "OK");
  //       }
  //       if (bleService.valueFromCharacteristic != null) {
  //         try {
  //           carFloor = ((bleService.valueFromCharacteristic[0] as int) & 0x3F)
  //               .toString();
  //         } catch (e) {
  //           // if (Preferences.get("DevOptions", false) == true) {
  //           //   carFloor = "*****";
  //           //   // Debug.Print("***** Caratteristica non trovata ******");
  //           // }
  //         }
  //       } else {
  //         carFloor = "999";
  //       }
  //     }
  //   } catch (e) {
  //     // if (Preferences.get("DevOptions", false) == true) {
  //     //   await App.current.mainPage.displayAlert(
  //     //       "Alert", "$e\r\n${e.stackTrace}\r\n${e.source}", "OK");
  //     // } else {
  //     //   debug.Print("$e\r\n${e.stackTrace}\r\n${e.source}");
  //     // }
  //   }
  // }

  Future<void> stopCharacteristicWatchAsync() async {
    try {
      // Unsubscribe from characteristic update events
      bleService.onCharacteristicUpdated.listen((event) {});

      await bleService.stopCharacteristicWatchAsync(
          IBleService.ESP_SERVICE_GUID, ESP_EXAMPLE_CHARACTERTISTIC_GUID);
      await bleService.stopCharacteristicWatchAsync(
          IBleService.ESP_SERVICE_GUID, MISSION_STATUS_CHARACTERISTIC_GUID);

      // Stop monitoring out of service and absence of light from the floor
      await bleService.stopCharacteristicWatchAsync(
          IBleService.ESP_SERVICE_GUID, OUT_OF_SERVICE_CHARACTERISTIC_GUID);

      // Added cabin movement
      await bleService.stopCharacteristicWatchAsync(
          IBleService.ESP_SERVICE_GUID, MOVEMENT_DIRECTION_CAR);

      print("*************** Stop watch characteristics ***************");
    } catch (e) {
      // Handle the exception
      // if(Preferences.getBool("DevOptions") == true)
      //   await showDialog(
      //     // Display alert dialog
      //     builder: (context) => AlertDialog(
      //       title: Text("Alert"),
      //       content: Text("${e.toString()}\r\n${e.stackTrace.toString()}\r\n${e.source.toString()}"),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.pop(context),
      //           child: Text("OK"),
      //         ),
      //       ],
      //     ),
      //   );
    }
  }

  bool isFloor(BLEDevice device) {
    return device != null && device.type == BleDeviceType.esp32;
  }

  void emitNotifications(BLEDevice device) {
    if (isFloor(device)) {
      print(
          "==============Coming to emitNotification=====================$device");
      final bool foreground = isInForeground ?? false;

      if (!foreground) {
        final secondsPassed =
            DateTime.now().millisecondsSinceEpoch - tickAttuali;
        final secondsPassedInSeconds = secondsPassed / 1000;
        print("Seconds: $secondsPassedInSeconds");

        if (secondsPassedInSeconds > IntervalloAvvisoVicinoAscensore ||
            PrimaConnessioneDevice) {
          PrimaConnessioneDevice = false;
          Vibration.vibrate();
          // notificationManager.sendNotification(
          //     "Soffia", "Message tells you are near to Elevator");
          audioService.beep();
          Future.delayed(const Duration(milliseconds: 100), () {
          sendMessage();
          });
          tickAttuali = DateTime.now().millisecondsSinceEpoch;
        }
      }
    }
  }

Future<void> sendMessage() async{
  notificationManager.sendNotification(
              "Soffia", "Message tells you are near to Elevator");

}

  Future<void> getPianoCabina() async {
    try {
      carFloor = "999";
      if (bleService.connectedDeviceId.toString() != "") {
        try {
          await bleService.getValueFromCharacteristicGuid(
            IBleService.ESP_SERVICE_GUID,
            ESP_EXAMPLE_CHARACTERTISTIC_GUID,
          );
        } catch (ex) {
          return;
          // await App.current.showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
        }
        if (bleService.valueFromCharacteristic != null) {
          try {
            carFloor =
                ((bleService.valueFromCharacteristic[0]) & 0x3F).toString();
          } catch (ex) {
            // if (Preferences.get("DevOptions", false) == true) {
            //   carFloor = "*****";
            //   // Debug.Print("***** Caratteristica non trovata ******");
            // }
          }
        } else {
          carFloor = "999";
        }
      }
    } catch (ex) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current.showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
      // } else {
      //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
      // }
    }
  }

  Future<void> startCharacteristicReadWatchAsync() async {
    int value;
    try {
      for (final characteristic in Characteristics) {
        value = 0;
        if (nearestDevice != null) {
          if (nearestDevice!.isAlive == true) {
            // await bleService.getValueFromCharacteristicGuid(
            //     IBleService.FLOOR_SERVICE_GUID, characteristic);
            await bleService.getValueFromCharacteristicGuid(
                IBleService.ESP_SERVICE_GUID, characteristic);
          }
        }
        BLECharacteristicEventArgs bl = BLECharacteristicEventArgs(
          value: bleService.valueFromCharacteristic,
          characteristicGuid: characteristic,
        );
        print("La caratteristica $characteristic ha il valore $value");
        if (bl.value != null) {
          bleServiceOnCharacteristicUpdated(this, bl);
        }
      }

      //  bleService.onCharacteristicUpdated += bleServiceOnCharacteristicUpdated;
      //bleService.onCharacteristicUpdated
      //    .listen(bleServiceOnCharacteristicUpdated);
      for (final characteristic in Characteristics) {
        await bleService.startCharacteristicWatchAsync(
            IBleService.ESP_SERVICE_GUID, characteristic);
      }
    } catch (ex) {
      // if (Preferences.get("DevOptions", false) == true) {
      //   await App.current.showAlert(
      //       "Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
      // } else {
      //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
      // }
    }
  }

  void bleServiceOnCharacteristicUpdated(
      Object sender, BLECharacteristicEventArgs e) {
    try {
      switch (e.characteristicGuid) {
        case ESP_EXAMPLE_CHARACTERTISTIC_GUID:
          try {
            carFloor = ((e.value?[0]) ?? 0 & 0x3F).toString();
            if (((e.value?[0]) ?? 0 & 0x40) == 0x40) {
              presenceOfLight = true;
            } else {
              presenceOfLight = false;
            }

            if (((e.value?[1]) ?? 0 & 0x1) == 0x1) {
              if (((e.value?[1]) ?? 0 & 0x02) == 0x02) {
                carDirection = Direction.up;
              } else {
                carDirection = Direction.down;
              }
            } else {
              carDirection = Direction.stopped;
            }
          } catch (ex) {
            // if (Preferences.get("DevOptions", false) == true) {
            //   App.current.showAlert("Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
            // } else {
            //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
            // }
          }
          break;

        case MISSION_STATUS_CHARACTERISTIC_GUID:
          try {
            if (e.value!.length > 2) {
              // missionStatus = e.value[0];
              // eta = e.value[1] * 256 + e.value[2];
            }
            if (onMissionStatusChanged != null) {
              onMissionStatusChanged;
            }
          } catch (ex) {
            // if (Preferences.get("DevOptions", false) == true) {
            //   App.current.showAlert("Alert",
            //       "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
            // } else {
            //   print("${ex.message}\n${ex.stackTrace}\n${ex.source}");
            // }
          }
          break;

        case OUT_OF_SERVICE_CHARACTERISTIC_GUID:
          if (e.value?[0] == 0) {
            outOfService = false;
          } else {
            outOfService = true;
          }
          break;

        case MOVEMENT_DIRECTION_CAR:
          int valore = e!.value?[0] ?? 0;
          if (((e.value?[0] ?? 0) & 0x1) == 0x1) {
            if (((e.value?[0] ?? 0) & 0x02) == 0x02) {
              carDirection = Direction.up;
            } else {
              carDirection = Direction.down;
            }
          } else {
            carDirection = Direction.stopped;
          }
          break;
      }

      if (onCharacteristicUpdated != null) {
        onCharacteristicUpdated;
      }
    } catch (ex) {
      // App.current.showAlert(
      //     "Alert", "${ex.message}\n${ex.stackTrace}\n${ex.source}", "OK");
    }
  }

//new code
  BLEDevice? findCar(List<BLEDevice> devices) {
    BLEDevice? carDevice;

    try {
      carDevice = devices.firstWhere((d) => d.type == BleDeviceType.car);

      bool isNear = carDevice.avgRxPower != null &&
          carDevice.avgRxPower! > MIN_CAR_RX_POWER;

      if (!isNear) {
        carDevice = null;
      }
    } catch (e) {
      carDevice = null;
    }

    return carDevice;
  }
}
