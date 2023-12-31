import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sofia/logic/binding/login_binding.dart';
import 'package:sofia/pages/command_page.dart';
import 'package:sofia/pages/login_page.dart';
import 'package:sofia/pages/profile_page.dart';
import 'package:sofia/pages/settings_page.dart';
import 'package:sofia/pages/test_page.dart';
import 'package:sofia/utils/service_locator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  serviceLocatorInit();

  if (Platform.isAndroid) {
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request().then((status) {
      runApp(const MyApp());
    });
  } else {
    runApp(const MyApp());
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      getPages: [
        GetPage(name: "/", page: () => LogInPage(), binding: LoginBinding()),
        GetPage(name: "/CommandPage", page: () => CommandPage()),
        GetPage(name: "/Profile", page: () => ProfilePage()),
        GetPage(name: "/Test", page: () => TestPage()),
        GetPage(name: "/ProfilePage", page: () => ProfilePage()),
        GetPage(name: "/CommandPage", page: () => CommandPage()),
        GetPage(name: "/TestPage", page: () => TestPage()),
        GetPage(name: "/SettingsPage", page: () => const SettingsPage()),
      ],
    );
  }
}
