import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePageTest extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePageTest> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  final String serviceGuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  bool _isScanning = false;
  final _devices = [];
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Scan'),
              onPressed: _isScanning ? null : _startScan,
            ),
            ElevatedButton(
              child: Text('Connect'),
              onPressed: _isScanning ? null : _connectToDevice,
            ),
            ElevatedButton(
              child: Text('Disconnect'),
              onPressed: _isScanning ? null : _disconnectFromDevice,
            ),
            ElevatedButton(
              child: Text('Reconnect'),
              onPressed: _isScanning ? null : _reconnectToDevice,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startScan() async {
    bool goForIt = false;
    if (Platform.isAndroid) {
      PermissionStatus locationPermission = await Permission.location.request();
      PermissionStatus finePermission =
          await Permission.locationWhenInUse.request();
      // TODO user feedback on no location
      if (locationPermission == PermissionStatus.granted &&
          finePermission == PermissionStatus.granted) {
        goForIt = true;
      }
    } else if (Platform.isIOS) {
      goForIt = true;
    }

    if (goForIt) {
      setState(() {
        _isScanning = true;
      });

      try {
        final Uuid serviceUuid = Uuid.parse(serviceGuid);
        _scanSubscription =
            _ble.scanForDevices(withServices: [serviceUuid]).listen((device) {
          // Handle discovered devices here
          print('Discovered device: ${device.name} (${device.id})');
          _connectToDevice(device.id);
          _devices.add(device.name);
        });
      } catch (e) {
        print('Error while scanning: $e');
      }
    } else {}
  }

  void _connectToDevice(_deviceId) {
    // _ble.connectToDevice(
    //   id: _deviceId,
    //   servicesWithCharacteristicsToDiscover: {serviceGuid},
    //   connectionTimeout: const Duration(seconds: 2),
    // )
    //     .listen((connectionState) {
    //   if (connectionState.connectionState == DeviceConnectionState.connected) {
    //     send the data
    //     final characteristic = QualifiedCharacteristic(serviceId: serviceUuid,
    //     characteristicId: charId1, deviceId: deviceId);

    //      var response = await flutterReactiveBle.writeCharacteristicWithResponse(characteristic, value: [0x00]);
    //   }
    // }, onError: (Object error) {
    //   // Handle a possible error
    // });
    final deviceConnection = _ble.connectToDevice(
      id: _deviceId,
      connectionTimeout: const Duration(seconds: 2),
    );

    await for (final connectionState in deviceConnection) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        final characteristic = QualifiedCharacteristic(
          serviceId: serviceUuid,
          characteristicId: characteristicId,
          deviceId: _deviceId,
        );

        await _ble.writeCharacteristicWithResponse(
          characteristic,
          value: [0x00],
        );

        break; // Connected and data sent, exit the loop
      }
    }
  }

  void _disconnectFromDevice() {
    // Add your logic to disconnect from the ESP32 device here
  }

  void _reconnectToDevice() {
    // Add your logic to reconnect to the ESP32 device here
  }

  @override
  void dispose() {
    _scanSubscription
        ?.cancel(); // Cancel the scan subscription when the widget is disposed
    super.dispose();
  }
}
