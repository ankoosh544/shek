import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum AppLogLevel {
  info,
  debug,
  warning,
  error,
}

abstract class AppState {
  AppLogLevel getAppLogLevel();
  String getInstallId();
}

class Logging {
  final AppState _appState;

  Logging(this._appState);

  void logEvent(AppLogLevel level, String message,
      [Map<String, String>? properties]) {
    if (_appState.getAppLogLevel().index <= level.index &&
        !_isRunningOnTestCloud() &&
        !_isEmulatorOrSimulator()) {
      Map<String, String> eventProperties = properties ?? {};
      eventProperties['InstallId'] = _appState.getInstallId();
      // FirebaseAnalytics()
      //     .logEvent(name: level.toString(), parameters: eventProperties);
    }
  }

  bool _isEmulatorOrSimulator() {
    return (const bool.fromEnvironment('dart.vm.product',
            defaultValue: false)) ||
        (const bool.fromEnvironment('flutter.test', defaultValue: false));
  }

  bool _isRunningOnTestCloud() {
    const String testCloudEnv = 'XAMARIN_TEST_CLOUD';
    return const bool.fromEnvironment(testCloudEnv, defaultValue: false);
  }
}
