import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:provider/provider.dart';

import '../ble/ble_logger.dart';
import '../widgets.dart';
import 'device_detail/device_detail_screen.dart';
import 'device_detail/device_interaction_tab.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleScanner, BleScannerState?, BleLogger>(
        builder: (_, bleScanner, bleScannerState, bleLogger, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          toggleVerboseLogging: bleLogger.toggleVerboseLogging,
          verboseLogging: bleLogger.verboseLogging,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList({
    required this.scannerState,
    required this.startScan,
    required this.stopScan,
    required this.toggleVerboseLogging,
    required this.verboseLogging,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final VoidCallback toggleVerboseLogging;
  final bool verboseLogging;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  late TextEditingController _uuidController;
  static const FLOOR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a01";
  static const CAR_SERVICE_GUID = "6c962546-6011-4e1b-9d8c-05027adb3a02";
  final serviceUUIDs = [
    Uuid.parse('4fafc201-1fb5-459e-8fcc-c5c9c331914b'), // ESP32
    Uuid.parse(FLOOR_SERVICE_GUID), //FLOOR_SERVICE_GUID
    //Uuid.parse(CAR_SERVICE_GUID), // CAR_SERVICE_GUID
  ];

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController()
      ..addListener(() => setState(() {}));
    // _uuidController.text = "";
    _startScanning().then((value) {
      Future.delayed(Duration(seconds: 4), () {
        print('=================================================');
        print(widget.scannerState.discoveredDevices.length);
        print(widget.scannerState.discoveredDevices.first.name);
        print('========================end=========================');
      });
      // widget.scannerState.discoveredDevices.sort((a, b) => a.rssi.compareTo(b.rssi));
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.stopScan();
    _uuidController.dispose();
    super.dispose();
  }

  bool _isValidUuidInput() {
    final uuidText = _uuidController.text;
    if (uuidText.isEmpty) {
      return true;
    } else {
      try {
        Uuid.parse(uuidText);
        return true;
      } on Exception {
        return false;
      }
    }
  }

  Future<void> _startScanning() async {
    widget.startScan(serviceUUIDs);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan for devices'),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(
                    !widget.scannerState.scanIsInProgress
                        ? 'Enter a UUID above and tap start to begin scanning'
                        : 'Tap a device to connect to it',
                  ),
                  trailing: (widget.scannerState.scanIsInProgress ||
                          widget.scannerState.discoveredDevices.isNotEmpty)
                      ? Text(
                          'count: ${widget.scannerState.discoveredDevices.length}',
                        )
                      : null,
                ),
                ...widget.scannerState.discoveredDevices.map(
                  (device) {
                    print('%%%%%%%%%%%% ${device.toString()}');
                    return ListTile(
                      title: Text(
                        device.name.isNotEmpty ? device.name : "Unnamed",
                      ),
                      subtitle: Text(
                        """
${device.id}
RSSI: ${device.rssi}
${device.connectable}
                          """,
                      ),
                      leading: const BluetoothIcon(),
                      onTap: () async {
                        widget.stopScan();
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DeviceDetailScreen(device: device),
                          ),
                        );
                      },
                    );
                  },
                ).toList(),
              ],
            ),
            if (widget.scannerState.discoveredDevices.isNotEmpty)
              Expanded(
                  child: DeviceInteractionTab(
                device: widget.scannerState.discoveredDevices.first,
              ))
            else
              Container(),
          ],
        ),
      );
}
