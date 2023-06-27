import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:sofia/interfaces/i_audio_service.dart';
import 'package:sofia/interfaces/i_auth_service.dart';
import 'package:sofia/interfaces/i_ble_service.dart';
import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/interfaces/i_data_logger_service.dart';
import 'package:sofia/interfaces/i_nearest_device_service.dart';
import 'package:sofia/interfaces/i_notification_manager.dart';
import 'package:sofia/interfaces/i_rides_service.dart';


import 'package:sofia/services/DataLoggerService.dart';
import 'package:sofia/services/android_notification_manager.dart';
import 'package:sofia/services/audio_service.dart';
import 'package:sofia/services/auth_service.dart';
import 'package:sofia/services/ble_service.dart';
import 'package:sofia/services/core_controller.dart';
import 'package:sofia/services/nearest_device_resolver.dart';
import 'package:sofia/services/ride_service.dart';


serviceLocatorInit(){
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
  
}