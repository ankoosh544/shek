import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sofia_test_app/command_page.dart';
import 'package:sofia_test_app/interfaces/i_audio_service.dart';
import 'package:sofia_test_app/interfaces/i_auth_service.dart';
import 'package:sofia_test_app/interfaces/i_ble_service.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/interfaces/i_data_logger_service.dart';
import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';
import 'package:sofia_test_app/interfaces/i_notification_manager.dart';
import 'package:sofia_test_app/interfaces/i_rides_service.dart';
import 'package:sofia_test_app/login_page.dart';
import 'package:sofia_test_app/profile_page.dart';
import 'package:sofia_test_app/services/DataLoggerService.dart';
import 'package:sofia_test_app/services/android_notification_manager.dart';
import 'package:sofia_test_app/services/audio_service.dart';
import 'package:sofia_test_app/services/auth_service.dart';
import 'package:sofia_test_app/services/ble_service.dart';
import 'package:sofia_test_app/services/core_controller.dart';
import 'package:sofia_test_app/services/nearest_device_resolver.dart';


import 'package:sofia_test_app/services/ride_service.dart';
import 'package:sofia_test_app/settings_page.dart';
import 'package:sofia_test_app/test_page.dart';

import 'dart:io';

void main() {
  final locator = GetIt.instance;
  locator.registerLazySingleton<IAuthService>(() => AuthService());
  locator
      .registerLazySingleton<INotificationManager>(() => AndroidNotificationManager());
  locator.registerLazySingleton<ICoreController>(() => CoreController());
  locator.registerLazySingleton<IBleService>(() => BLEService());
  locator.registerLazySingleton<INearestDeviceResolver>(
      () => NearestDeviceResolver());

  locator.registerLazySingleton<IDataLoggerService>(() => DataLoggerService());
  locator.registerLazySingleton<IRidesService>(() => RidesService());
  locator.registerLazySingleton<IAudioService>(() => AudioService());

  GetIt.instance.registerLazySingleton<AuthService>(() => AuthService());
  GetIt.instance.registerLazySingleton(() => AndroidNotificationManager());
  GetIt.instance.registerLazySingleton(() => AudioService());
  GetIt.instance.registerLazySingleton<BLEService>(() => BLEService());
  GetIt.instance.registerLazySingleton<CoreController>(() => CoreController());
  GetIt.instance.registerLazySingleton<NearestDeviceResolver>(
      () => NearestDeviceResolver());
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
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
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => LoginPage());
          case '/home':
            return MaterialPageRoute(builder: (_) => CommandPage());
          case '/profile':
            return MaterialPageRoute(builder: (_) => ProfilePage());
          case '/settings':
            return MaterialPageRoute(builder: (_) => SettingsPage());
          case '/test':
            return MaterialPageRoute(builder: (_) => TestPage());
          // default:
          //   return MaterialPageRoute(builder: (_) => UnknownScreen());
        }
      },
      // onUnknownRoute: (RouteSettings settings) {
      //   return MaterialPageRoute(builder: (_) => UnknownScreen());
      // },
    );
  }
}
