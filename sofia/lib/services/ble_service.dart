import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sofia/enums/ble_device_type.dart';

import 'package:sofia/interfaces/i_ble_service.dart';
import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/models/AdvertisementRecord.dart';
import 'package:sofia/models/BLECharacteristicEventArgs.dart';
import 'package:sofia/models/BLESample.dart';
import 'package:convert/convert.dart';
import 'package:collection/collection.dart';

enum AdvertisementRecordType {
  uuidsIncomplete128Bit,
  uuidsComplete128Bit,
  txPowerLevel
}

class BLEService implements IBleService {
  late ICoreController coreController;
  BluetoothState blStatusOld = BluetoothState.unknown;

  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  List<int> _valueFromCharacteristic = [];
  bool timeoutBle = false;
  bool isScanning = false;

  List<AdvertisementRecordType> RECORDS_TO_DISCOVER = [
    AdvertisementRecordType.uuidsIncomplete128Bit,
    AdvertisementRecordType.uuidsComplete128Bit,
  ];

  String get connectedDeviceId => _connectedDevice?.id.id ?? '';

  List<int> get valueFromCharacteristic => _valueFromCharacteristic;
  StreamController<BLESample> sampleController =
      StreamController<BLESample>.broadcast();

  final _sampleReceivedController = StreamController<BLESample>.broadcast();
  final _scanningEndController = StreamController<void>.broadcast();
  final _deviceConnectedController = StreamController<void>.broadcast();
  final _deviceDisconnectedController = StreamController<void>.broadcast();
  final _characteristicUpdatedController =
      StreamController<BLECharacteristicEventArgs>.broadcast();

  List<BLESample> samples = [];

  @override
  Stream<BLESample> get onSampleReceived => _sampleReceivedController.stream;

  @override
  Stream<void> get onScanningEnd => _scanningEndController.stream;

  @override
  Stream<void> get onDeviceConnected => _deviceConnectedController.stream;

  @override
  Stream<void> get onDeviceDisconnected => _deviceDisconnectedController.stream;

  @override
  Stream<BLECharacteristicEventArgs> get onCharacteristicUpdated =>
      _characteristicUpdatedController.stream;

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  BluetoothDevice? connectedDevice;
  Map<Guid, BluetoothCharacteristic> characteristics = {};

  BLEService() {
    timer1msTickk();
  }

  // BLEService() {
  //   FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  //   flutterBlue.startScan(timeout: Duration(seconds: 10));

  //   flutterBlue.scanResults.listen((List<ScanResult> scanResults) {
  //     // Iterate over the scan results to handle device advertisement
  //     for (ScanResult scanResult in scanResults) {
  //       adapterDeviceAdvertised(
  //           scanResult.device, scanResult.advertisementData);
  //     }
  //   });
  //   // flutterBlue.scanTimeout.listen((timeout) {
  //   //   // Handle scan timeout
  //   //   adapter_ScanTimeoutElapsed();
  //   // });
  //   flutterBlue.connectedDevices.asStream().listen((devices) {
  //     // Handle device connected
  //     adapter_DeviceConnected(devices.first, this);
  //   });

  //   flutterBlue.state.listen((state) {
  //     if (state == BluetoothState.off) {
  //       adapter_DeviceDisconnected();
  //     }
  //   });

  //   // flutterBlue.state.listen((state) {
  //   //   // Handle BLE state changed
  //   //   ble_DeviceStatusChanged(state);
  //   // });
  // }

  void characteristicValueUpdated(e) {
    if (e.characteristic.value.length > 0) {
      /* 
    print('Device: ${this.connectedDeviceId.toString()}');
    print('CharacteristicGuid: ${e.characteristic.id.toString()}');
    print('ServiceGuid: ${e.characteristic.service.id.toString()}');
    print('Value (in HEX): ${e.characteristic.value[0].toRadixString(16)}');
    */

      var eventArgs = BLECharacteristicEventArgs(
        characteristicGuid: e.characteristic.id.toString(),
        serviceGuid: e.characteristic.service.id.toString(),
        value: e.characteristic.value,
      );
      try {
        if (onCharacteristicUpdated != null) {
          _characteristicUpdatedController.stream;
        }
      } catch (e) {
        // Handle the exception if necessary
      }
    }
  }

  void adapterDeviceAdvertised(
      BluetoothDevice device, AdvertisementData advertisementData) async {
    if (advertisementData == null ||
        !hasRecords(advertisementData, RECORDS_TO_DISCOVER)) {
      return;
    }
    timeoutBle = false;
    // Generate a new sample
    var sample = BLESample(
      deviceId: device.id.toString(),
      alias: getAlias(device),
      deviceType: getDeviceType(device, advertisementData),
      timestamp: DateTime.now(),
      txPower: getTxPower(advertisementData),
      rxPower: await getRxPower(device),
    );

    // Call the OnSampleReceived callback if it's not null
    if (onSampleReceived != null) {
      onSampleReceived.listen((event) {
        _sampleReceivedController.add(sample);
      });
    }
  }

  void adapter_DeviceConnected(devices, dynamic e) {
    print(devices);
    print("=========Devices===========");
    if (onDeviceConnected != null) {
      print("======DEvice is connected======");
      print(onDeviceConnected);
      onDeviceConnected.isBroadcast;
    }
    print("=====No Device is Connected Null");
  }

  void adapter_DeviceDisconnected() {
    if (onDeviceDisconnected != null) {
      _deviceDisconnectedController.add(null);
    }
  }

  @override
  void timer1msTickk() {
    Timer.periodic(Duration(seconds: 5), (timer) {
      Future<void>.delayed(Duration(milliseconds: 1), () async {
        if (timeoutBle) {
          await stopScanningAsync();
          await startScanningAsync(-1);
          // if (Preferences.getBool("DevOptions") == true) {
          //   //Vibration.vibrate();
          //   if (Platform.isAndroid) {
          //     // Platform-specific code for Android
          //   }
          // }
        } else {
          timeoutBle = true;
        }
      });
    });
  }

  Future<void> startScanningAsync(int scanTimeout) async {
    if (isScanning) {
      return; // Return or perform necessary actions if already scanning
    }

    try {
      isScanning = true; // Set scanning flag to true
      flutterBlue.scan(
        timeout: Duration(seconds: 10),
        withServices: [
          // Guid(IBleService.FLOOR_SERVICE_GUID),
          Guid(IBleService.CAR_SERVICE_GUID),
          Guid(IBleService.ESP_SERVICE_GUID)
        ],
      ).listen(
        (scanResult) {
          if (scanResult.device.name.isNotEmpty) {
            var sample = BLESample(
              deviceId: scanResult.device.id.id,
              alias: scanResult.device.name,
              deviceType: getDeviceType(
                  scanResult.device, scanResult.advertisementData),
              timestamp: DateTime.now(),
              txPower: scanResult.advertisementData.txPowerLevel!.toDouble(),
              rxPower: scanResult.rssi.toDouble(),
            );
            print(sample);
            print("================================");
            samples.add(sample);
            _sampleReceivedController.add(sample);
          }
        },
        onDone: () {
          isScanning = false; // Set scanning flag to false when scan ends
          _scanningEndController.add(null);
        },
      );
    } catch (e) {
      isScanning = false; // Set scanning flag to false in case of errors
      print('Failed to start scanning: $e');
    }
  }

  @override
  Future<void> stopScanningAsync() async {
    if (isScanning) {
      try {
        await flutterBlue.stopScan();
      } catch (e) {
        print('Failed to stop scanning: $e');
      } finally {
        isScanning =
            false; // Set scanning flag to false regardless of the outcome
      }
    }
  }

  @override
  Future<void> connectToDeviceAsync(String deviceId) async {
    try {
      final flutterBluePlus = FlutterBluePlus.instance;

      if (connectedDevice == null ||
          connectedDevice?.state != BluetoothDeviceState.connected) {
        try {
          if (!isScanning) {
            isScanning = true;
            flutterBlue.startScan(timeout: Duration(seconds: 5));
          }

          final scanResult = await flutterBlue.scanResults.firstWhere(
              (results) => results
                  .any((result) => result.device.id.toString() == deviceId));
          flutterBlue.stopScan();
          print(scanResult);
          print("======================ScanResult===============");
          isScanning = false;

          final device = scanResult
              .firstWhere((result) => result.device.id.toString() == deviceId)
              .device;
          await device.connect(
              autoConnect: true, timeout: Duration(seconds: 10));

          connectedDevice = device;
          print(connectedDevice);
        } catch (ex) {
          // Handle connection error
          // await showDialog(
          //   context: App.currentContext,
          //   builder: (context) => AlertDialog(
          //     title: Text('Alert on ConnectToDeviceAsync $deviceId'),
          //     content: Text('$ex\r\n${ex.stackTrace}\r\n${ex.source}'),
          //     actions: [
          //       TextButton(
          //         onPressed: () => Navigator.pop(context),
          //         child: Text('OK'),
          //       ),
          //     ],
          //   ),
          // );
        }

        print(connectedDevice?.id.toString());
      }
    } catch (ex) {
      // Handle exceptions
      // if (Preferences.getBool('DevOptions', false) == true) {
      //   await showDialog(
      //     context: App.currentContext,
      //     builder: (context) => AlertDialog(
      //       title: Text('Alert'),
      //       content: Text('$ex\r\n${ex.stackTrace}\r\n${ex.source}'),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.pop(context),
      //           child: Text('OK'),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   print('$ex\r\n${ex.stackTrace}\r\n${ex.source}');
      // }
    }
  }
  // Future<void> connectToDeviceAsync(String deviceId) async {
  //   print(
  //       "==========================================comming to connectToDeviceAsync=======================================================================================");
  //   try {
  //     final devices = await FlutterBluePlus.instance.connectedDevices;
  //     print("==============devices==================$devices");
  //     final device = devices.firstWhere((d) => d.id.id == deviceId, orElse: () {
  //       print('No device found with ID $deviceId');
  //       throw Exception('No device found with ID $deviceId');
  //     });
  //     await connectToDevice(device);
  //   } catch (e) {
  //     print('Failed to connect to device: $e');
  //   }
  // }

// Future<void> connectToDeviceAsync(String deviceId) async {
//   try {
//     if (connectedDevice == null || connectedDevice!.state != BluetoothDeviceState.connected) {
//       try {
//         await flutterBlue.startScan(timeout: Duration(seconds: 4));
//         final devices = await flutterBlue.connectedDevices;
//         final device = devices.firstWhere((d) => d.id.toString() == deviceId, orElse: () {
//           print('No device found with ID $deviceId');
//           throw Exception('No device found with ID $deviceId');
//         });

//         if (device != null) {
//           connectedDevice = device;
//         } else {
//           await flutterBlue.stopScan();
//           final scanResults = await flutterBlue.scanResults.toList();
//           print(scanResults);
//           // final scannedDevice = scanResults
//           //     .map((result) => result.device)
//           //     .firstWhere((d) => d.id.toString() == deviceId, orElse: () => null);

//           // if (scannedDevice != null) {
//           //   connectedDevice = scannedDevice;
//           // }
//         }
//       } catch (ex) {
//         // await showDialog(
//         //   context: App.currentContext,
//         //   builder: (context) => AlertDialog(
//         //     title: Text('Alert on ConnectToDeviceAsync $deviceId'),
//         //     content: Text('$ex\r\n${ex.stackTrace}\r\n${ex.source}'),
//         //     actions: [
//         //       TextButton(
//         //         onPressed: () => Navigator.pop(context),
//         //         child: Text('OK'),
//         //       ),
//         //     ],
//         //   ),
//         // );
//       }

//       if (connectedDevice != null) {
//         print(connectedDevice!.id.toString());
//       }
//     }
//   } catch (ex) {
//     // if (Preferences.getBool('DevOptions', false) == true) {
//     //   await showDialog(
//     //     context: App.currentContext,
//     //     builder: (context) => AlertDialog(
//     //       title: Text('Alert'),
//     //       content: Text('$ex\r\n${ex.stackTrace}\r\n${ex.source}'),
//     //       actions: [
//     //         TextButton(
//     //           onPressed: () => Navigator.pop(context),
//     //           child: Text('OK'),
//     //         ),
//     //       ],
//     //     ),
//     //   );
//     // } else {
//     //   print('$ex\r\n${ex.stackTrace}\r\n${ex.source}');
//     // }
//   }
// }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(autoConnect: true);
      _connectedDevice = device;
      print('===============Device is Connected======== $_connectedDevice');
      print("=============Sucess connected====================");
      await discoverServices();
      _deviceConnectedController.add(null);
    } catch (e) {
      print('Failed to connect to device: $e');
      print("===============Failed==================");
    }
  }

  @override
  Future<void> disconnectToDeviceAsync() async {
    print(
        "============================Coming to disconnection =====================================");
    try {
      await disconnectFromDevice();
    } catch (e) {
      print('Failed to disconnect from device: $e');
      print("============failed to disconnect=====================");
    }
  }

  Future<void> disconnectFromDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
      _services.clear();
      _valueFromCharacteristic.clear();
      _deviceDisconnectedController.add(null);
    }
  }

  @override
  Future<void> startCharacteristicWatchAsync(
      String serviceGuid, String characteristicGuid) async {
    final service = _services.firstWhere(
        (s) => s.uuid.toString() == serviceGuid,
        orElse: () => throw Exception('Service not found'));
    if (service != null) {
      await subscribeToCharacteristic(service, characteristicGuid);
    }
  }

  Future<void> subscribeToCharacteristic(
      BluetoothService service, String characteristicGuid) async {
    final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicGuid,
        orElse: () => throw Exception('Characteristic not found'));

    if (characteristic != null) {
      await characteristic.setNotifyValue(true);
      characteristic.value.listen((value) {
        final args = BLECharacteristicEventArgs();
        _characteristicUpdatedController.add(args);
      });
    }
  }

  // @override
  // Future<void> stopCharacteristicWatchAsync(
  //     String serviceGuid, String characteristicGuid) async {
  //   final service = _services.firstWhere(
  //       (s) => s.uuid.toString() == serviceGuid,
  //       orElse: () => throw Exception('Service not found'));
  //   print("=============Service not found===================");
  //   if (service != null) {
  //     await unsubscribeFromCharacteristic(service, characteristicGuid);
  //   }
  // }
  Future<void> stopCharacteristicWatchAsync(
      String serviceGuid, String characteristicGuid) async {
    var characteristic = this.characteristics[characteristicGuid];

    if (characteristic != null) {
      this.characteristics.remove(characteristicGuid);
      characteristic.value.listen((_) {
        characteristicValueUpdated(this);
      }).cancel(); // Stop listening to characteristic updates
      await characteristic
          .setNotifyValue(false); // Stop notifications from the characteristic
    }
  }

  Future<void> unsubscribeFromCharacteristic(
      BluetoothService service, String characteristicGuid) async {
    final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicGuid,
        orElse: () => throw Exception('Characteristic not found'));
    print("=============Characteristic not found===================");

    if (characteristic != null) {
      await characteristic.setNotifyValue(false);
    }
  }

  @override
  Future<void> sendCommandAsync(
      String serviceGuid, String characteristicGuid, List<int> message) async {
    final service = _services.firstWhere(
        (s) => s.uuid.toString() == serviceGuid,
        orElse: () => throw Exception('Service not found'));
    print("=============Service not found===================");

    if (service != null) {
      await writeCharacteristic(service, characteristicGuid, message);
    }
  }

  Future<void> writeCharacteristic(BluetoothService service,
      String characteristicUuid, List<int> value) async {
    final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicUuid,
        orElse: () => throw Exception('Characteristic not found'));
    print("=============Characteristic not found===================");

    if (characteristic != null) {
      await characteristic.write(value, withoutResponse: true);
    }
  }

  @override
  Future<void> getValueFromCharacteristicGuid(
      String serviceGuid, String characteristicGuid) async {
    final service = _services.firstWhere(
        (s) => s.uuid.toString() == serviceGuid,
        orElse: () => throw Exception('Service not found'));
    if (service != null) {
      await readCharacteristic(service, characteristicGuid);
    }
  }

  Future<void> readCharacteristic(
      BluetoothService service, String characteristicUuid) async {
    final characteristic = service.characteristics.firstWhere(
        (c) => c.uuid.toString() == characteristicUuid,
        orElse: () => throw Exception('Characteristic not found'));

    if (characteristic != null) {
      final value = await characteristic.read();
      _valueFromCharacteristic = value;
    }
  }

  Stream<BluetoothDevice> getDeviceStream() {
    return FlutterBluePlus.instance.scanResults
        .map((results) => results.map((r) => r.device).toList())
        .expand((devices) => devices);
  }

  Future<void> discoverServices() async {
    if (_connectedDevice != null) {
      try {
        _services = await _connectedDevice!.discoverServices();
      } catch (e) {
        print('Failed to discover services: $e');
      }
    }
  }

  @override
  void dispose() {
    _sampleReceivedController.close();
    _scanningEndController.close();
    _deviceConnectedController.close();
    _deviceDisconnectedController.close();
    _characteristicUpdatedController.close();
  }

  //////////////////////////////////////////

  bool hasRecords(AdvertisementData advertisementData,
      List<AdvertisementRecordType> recordTypes) {
    for (var recordType in recordTypes) {
      var record = advertisementData.manufacturerData[recordType];
      if (record == null) {
        return false;
      }
    }
    return true;
  }

  String getAlias(BluetoothDevice device) {
    // Retrieve and return the alias of the device
    return device.name;
  }

  BleDeviceType getDeviceType(
    BluetoothDevice device,
    AdvertisementData advertisementData,
  ) {
    var manufacturerData = advertisementData.manufacturerData;
    if (manufacturerData.containsKey(0xFF)) {
      var manufacturerDataValue = manufacturerData[0xFF]!;
      var floorServiceByteArray = hex.decode(IBleService.ESP_SERVICE_GUID);
      if (ListEquality().equals(manufacturerDataValue, floorServiceByteArray)) {
        return BleDeviceType.esp32;
      }
    }

    return BleDeviceType.esp32;
  }
  // BleDeviceType getDeviceType(
  //     BluetoothDevice device, AdvertisementData advertisementData) {
  //   print("coming to get deviceType");
  //   var record = getRecord(
  //     advertisementData,
  //   );

  //   if (record == null) {
  //     record = getRecord(advertisementData,
  //         AdvertisementRecordType.uuidsComplete128Bit as int);
  //   }

  //   if (record == null || record.data == null) {
  //     return BleDeviceType.esp32;
  //   }

  //   var floorServiceByteArray = hex.decode(IBleService.ESP_SERVICE_GUID);
  //   return ListEquality().equals(record.data!, floorServiceByteArray)
  //       ? BleDeviceType.esp32
  //       : BleDeviceType.car;
  // }

  AdvertisementRecord? getRecord(
      AdvertisementData advertisementData, int recordType) {
    for (var entry in advertisementData.manufacturerData.entries) {
      if (entry.key == recordType) {
        return AdvertisementRecord(type: recordType, data: entry.value);
      }
    }

    for (var entry in advertisementData.serviceData.entries) {
      if (entry.key == recordType.toString()) {
        return AdvertisementRecord(type: recordType, data: entry.value);
      }
    }

    return null;
  }

// Future<BleDeviceType> getDeviceType(BluetoothDevice device) async {
//   final services = await device.discoverServices();

//   var record = services.firstWhere(
//     (service) =>
//         service.uuid == BluetoothService.floorServiceUUID ||
//         service.uuid == BluetoothService.floorServiceUUIDComplete,
//     orElse: () => null,
//   );

//   if (record == null || record.data == null) {
//     return BLEDeviceType.Floor;
//   }

//   final floorServiceByteArray =
//       Guid.parse(IBLEService.FLOOR_SERVICE_GUID).toByteArray();

//   return record.data.last == floorServiceByteArray.last
//       ? BLEDeviceType.Floor
//       : BLEDeviceType.Car;
// }

  double? getTxPower(AdvertisementData advertisementData) {
    var txPowerLevel = advertisementData.txPowerLevel;
    if (txPowerLevel != null) {
      return txPowerLevel.toDouble();
    }

    return null;
  }

  Future<double?> getRxPower(BluetoothDevice device) async {
    var rssi = await device.readRssi();
    if (rssi != null) {
      return rssi.toDouble();
    }
  }
}
