import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:sofia/ble/ble_scanner.dart';
import 'package:provider/provider.dart';

import '../ble/ble_logger.dart';
// import '../widgets.dart';
// import 'device_detail/device_detail_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer3<BleScanner, BleScannerState?, BleLogger>(
        builder: (_, bleScanner, bleScannerState, bleLogger, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
          startScanWithFilter: bleScanner.startScanWithFilter, // Add startScanWithFilter here
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
    required this.startScanWithFilter, // Add startScanWithFilter here
    required this.toggleVerboseLogging,
    required this.verboseLogging,
  });

  final BleScannerState scannerState;
  final void Function(List<Uuid>) startScan;
  final VoidCallback stopScan;
  final void Function(bool Function(ScanResult)) startScanWithFilter; // Add startScanWithFilter here
  final VoidCallback toggleVerboseLogging;
  final bool verboseLogging;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  late TextEditingController _uuidController;

  @override
  void initState() {
    super.initState();
    _uuidController = TextEditingController()..addListener(() => setState(() {}));
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

  void _startScanning() {
    final text = _uuidController.text;
    if (text.isEmpty) {
      widget.startScan([]);
    } else {
      final deviceType = 'ESP32';
      final serviceGuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';

      widget.startScanWithFilter((scanResult) {
        final advertisementData = scanResult.advertisementData;
        final deviceTypeData = advertisementData?.deviceTypeData;
        final serviceUuids = advertisementData?.serviceUuids;

        if (deviceTypeData == deviceType && serviceUuids?.contains(serviceGuid) == true) {
          return true;
        }

        return false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Scan fordevices'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text('Service UUID (2, 4, 16 bytes):'),
                  TextField(
                    controller: _uuidController,
                    enabled: !widget.scannerState.scanIsInProgress,
                    decoration: InputDecoration(
                      errorText: _uuidController.text.isEmpty || _isValidUuidInput() ? null : 'Invalid UUID format',
                    ),
                    autocorrect: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        child: const Text('Scan'),
                        onPressed: !widget.scannerState.scanIsInProgress && _isValidUuidInput()
                            ? _startScanning
                            : null,
                      ),
                      ElevatedButton(
                        child: const Text('Stop'),
                        onPressed: widget.scannerState.scanIsInProgress ? widget.stopScan : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: [
                  SwitchListTile(
                    title: const Text("Verbose logging"),
                    value: widget.verboseLogging,
                    onChanged: (_) => setState(widget.toggleVerboseLogging),
                  ),
                  ListTile(
                    title: Text(
                      !widget.scannerState.scanIsInProgress
                          ? 'Enter a UUID above and tap start to begin scanning'
                          : 'Tap a device to connect to it',
                    ),
                    trailing: (widget.scannerState.scanIsInProgress || widget.scannerState.discoveredDevices.isNotEmpty)
                        ? Text(
                            'count: ${widget.scannerState.discoveredDevices.length}',
                          )
                        : null,
                  ),
                  ...widget.scannerState.discoveredDevices
                      .map(
                        (device) => ListTile(
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
                          onTap: () async {
                            widget.stopScan();
                            // await Navigator.push<void>(
                            //   context
                            //   // MaterialPageRoute(
                            //   //   builder: (_) =>
                            //   // ù  DeviceDetailScreen(device: device),
                            //   // ),
                            // );
                          },
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      );
}
