import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:rxdart/rxdart.dart';

import '../configs/index.dart';

class BleProvider extends ChangeNotifier {
  final _scanResult = BehaviorSubject<List<ScanResult>>.seeded([]);
  Stream<List<ScanResult>> get scanResult => _scanResult.stream;
  StreamSubscription? _subscription;

  final _bluetoothState =
      BehaviorSubject<BluetoothState>.seeded(BluetoothState.unknown);
  Stream<BluetoothState> get bluetoothStateStream => _bluetoothState.stream;
  BluetoothState get bluetoothState => _bluetoothState.value;

  final _isScanning = BehaviorSubject<bool>.seeded(false);
  Stream<bool> get isScanningStream => _isScanning.stream;
  bool get isScanning => _isScanning.value;

  BleProvider() {
    _getBluetoothState();
    _getScanResults();
  }

  void initialScan() {
    if (!FlutterBluePlus.instance.isScanningNow) {
      startScan();
    }
  }

  void periodicScan() =>
      _subscription = Stream.periodic(const Duration(seconds: 2), (_) => _)
          .listen((_) => startScan());

  void startScan() {
    if (bluetoothState == BluetoothState.on) {
      setIsScanning(true);
      FlutterBluePlus.instance.startScan(
        withServices: isServiceGuid ? serviceGuids : [],
        timeout: const Duration(seconds: 1),
      );
    }
  }

  void stopScan() {
    FlutterBluePlus.instance.stopScan();
    clearSubscription();
    setIsScanning(false);
    _scanResult.add([]);
  }

  void setIsScanning(bool value) => _isScanning.add(value);

  void _getScanResults() =>
      FlutterBluePlus.instance.scanResults.listen((results) => _scanResult
          .add([results, _scanResult.value].expand((x) => x).toSet().toList()));

  void clearSubscription() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    clearSubscription();
    super.dispose();
  }

  void _getBluetoothState() => FlutterBluePlus.instance.state.listen((event) {
        if (event == BluetoothState.on) {
          startScan();
        } else {
          stopScan();
        }
        _bluetoothState.add(event);
      });
}
