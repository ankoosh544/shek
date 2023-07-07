import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sofia/ble/ble_device_connector.dart';
import 'package:sofia/ble/ble_scanner.dart';

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

  late BleDeviceConnector bleDeviceConnector;
  late BleScanner bleScanner;


  @override
  void initState() {
    bleDeviceConnector =BleDeviceConnector(ble: _ble, logMessage:(message) {
      
    },);
    bleScanner =BleScanner(ble: _ble, logMessage:(message) {
      
    },);
    // TODO: implement initState
    super.initState();
  
  }

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
              onPressed: _isScanning ? null : startScan,
            ),
            // ElevatedButton(
            //   child: Text('Connect'),
            //   onPressed: _isScanning ? null : _connectToDevice,
            // ),
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

void startScan() async{
  bleScanner.startScan([Uuid.parse(serviceGuid)]);
  bleScanner.state.listen((event) async {
    print( event.discoveredDevices.length);
   
    print(event.toString());
  //   if(!event.scanIsInProgress){
  //  final device = event.discoveredDevices.firstWhere((element) => element.serviceUuids.first.toString() == serviceGuid);
  // await  bleDeviceConnector.connect(device.id);
  //  bleDeviceConnector.state.where((event) => event.deviceId == device.id).listen((event) {
  //   print('Psk : ${device.name}: ${event.connectionState.toString()}'); 
  //   });
  //   }else{
  //     print('Psk scanning');
  //   }
  });
  
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
          //_connectToDevice(device.id);
          bleDeviceConnector.connect(device.id);
          _devices.add(device.name);
        });
      } catch (e) {
        print('Error while scanning: $e');
      }
    } else {}
  }

  // void _connectToDevice(String deviceId) {
   
  //    _ble.connectToDevice(
  //     id: deviceId,
  //     connectionTimeout: const Duration(seconds: 2),
  //   )
  //       .listen((connectionStateUpdate) {
  //         print(connectionStateUpdate.connectionState.toString());
  //   }, onError: (Object error) {
  //     print(error.toString());
  //     // Handle a possible error
  //   });
    
  // }

  void _disconnectFromDevice() {
    
    
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
