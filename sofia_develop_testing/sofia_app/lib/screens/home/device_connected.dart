import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/configs/index.dart';
import 'package:sofia_app/providers/index.dart';

class DeviceConnected extends StatelessWidget {
  const DeviceConnected({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(tabHome),
        notificationPredicate: (notification) => notification.depth == 1,
        scrolledUnderElevation: 4.0,
        shadowColor: Theme.of(context).shadowColor,
        elevation: 1,
      ),
      body: Column(
        children: [
          Text(
            'Welcome User {}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          StreamBuilder<List<BluetoothDevice>>(
            stream: context.read<BleProvider>().connectedDeviceStream,
            initialData: const [],
            builder: (c, snapshot) {
              return Column(
                children: snapshot.data!.map((device) {
                  log('Connected Device : ${device.toString()}');
                  return ListTile(
                    title: Text(device.name),
                    subtitle: Text(device.id.toString()),
                    trailing: StreamBuilder<BluetoothDeviceState>(
                      stream: device.state,
                      initialData: BluetoothDeviceState.disconnected,
                      builder: (c, snapshot) {
                        if (snapshot.data == BluetoothDeviceState.connected) {
                          return const ElevatedButton(
                            onPressed: null,
                            child: Text('Connected'),
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
        ],
      ),
    );
  }
}
