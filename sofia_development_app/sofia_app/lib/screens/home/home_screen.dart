import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/ble_provider.dart';
import 'package:sofia_app/providers/profile_provider.dart';
import 'package:sofia_app/providers/settings_provider.dart';
import 'package:sofia_app/screens/profile/profile_screen.dart';
import 'package:sofia_app/screens/settings/settings_screen.dart';
import 'package:sofia_app/screens/testing/testing_screen.dart';

import '../../configs/index.dart';
import 'device_connected.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: tabsCount,
      child: Scaffold(
        bottomNavigationBar: Container(
          color: Colors.white,
          child: TabBar(
            tabs: <Widget>[
              _buildTab(
                const Icon(Icons.home_filled),
                titles[0],
              ),
              _buildTab(
                const Icon(Icons.settings),
                titles[1],
              ),
              _buildTab(
                const Icon(Icons.account_circle_rounded),
                titles[2],
              ),
              if (showTestingMenu)
                _buildTab(
                  const Icon(Icons.account_tree),
                  titles[3],
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            const DeviceConnected(),
            ChangeNotifierProvider(
              create: (_) => SettingsProvider(),
              child: const SettingScreen(),
            ),
            ChangeNotifierProvider(
              create: (_) => ProfileProvider(),
              child: const ProfileScreen(),
            ),
            if (showTestingMenu) const TestingScreen(),
          ],
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: context.read<BleProvider>().isScanningStream,
          initialData: context.read<BleProvider>().isScanning,
          builder: (c, snapshot) {
            if (snapshot.data!) {
              return FloatingActionButton.extended(
                onPressed: () => context.read<BleProvider>().stopScan(),
                label: Text(
                  stop,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                icon: const Icon(
                  Icons.stop_circle_outlined,
                  color: Colors.redAccent,
                ),
              );
            } else {
              return FloatingActionButton.extended(
                onPressed: () => context.read<BleProvider>()
                  //..initialScan()
                  ..periodicScan(),
                label: Text(
                  scan,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                icon: const Icon(
                  Icons.search_outlined,
                  color: Colors.blueAccent,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Tab _buildTab(Icon icon, String title) => Tab(
        icon: icon,
        text: title,
        iconMargin: const EdgeInsets.only(bottom: 6.0),
      );
}
