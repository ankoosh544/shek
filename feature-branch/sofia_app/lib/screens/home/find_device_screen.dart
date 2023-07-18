import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/ble_provider.dart';

import '../../configs/index.dart';
import '../../widgets/index.dart';
import 'bluetooth_off_screen.dart';
import 'device_screen.dart';

class FindDevicesScreen extends StatelessWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SofiaAppBar(
        title: tabHome,
      ),
      body: StreamBuilder<BluetoothState>(
        stream: context.read<BleProvider>().bluetoothStateStream,
        initialData: context.read<BleProvider>().bluetoothState,
        builder: (c, snapshot) {
          final state = snapshot.data;
          if (state == BluetoothState.on) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      scannedDevices,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Divider(
                      thickness: 2,
                      color: Colors.lightBlue,
                    ),
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: Stream.periodic(const Duration(seconds: 2))
                          .asyncMap(
                              (_) => FlutterBluePlus.instance.connectedDevices),
                      initialData: const [],
                      builder: (c, snapshot) {
                        return Column(
                          children: snapshot.data!.map((device) {
                            log('Psk : ${device.toString()}');
                            return ListTile(
                              title: Text(device.name),
                              subtitle: Text(device.id.toString()),
                              trailing: StreamBuilder<BluetoothDeviceState>(
                                stream: device.state,
                                initialData: BluetoothDeviceState.disconnected,
                                builder: (c, snapshot) {
                                  if (snapshot.data ==
                                      BluetoothDeviceState.connected) {
                                    return ElevatedButton(
                                      child: const Text('OPEN'),
                                      onPressed: () =>
                                          Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DeviceScreen(device: device),
                                        ),
                                      ),
                                    );
                                  }
                                  return Text(snapshot.data.toString());
                                },
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    StreamBuilder<List<ScanResult>>(
                      stream: context.read<BleProvider>().scanResult,
                      initialData: const [],
                      builder: (c, snapshot) {
                        return snapshot.hasData && snapshot.data!.isNotEmpty
                            ? Column(
                                children: snapshot.data!.map(
                                  (result) {
                                    log('Sofia : ${result.toString()}');
                                    return ScanResultTile(
                                      result: result,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            result.device.connect();
                                            return DeviceScreen(
                                                device: result.device);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ).toList(),
                              )
                            : Column(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        .26,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Please start scanning the devices',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall,
                                    ),
                                  ),
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          return BluetoothOffScreen(state: state);
        },
      ),
    );
  }
}
