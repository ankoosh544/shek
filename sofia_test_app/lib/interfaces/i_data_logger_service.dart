import 'package:sofia_test_app/models/BLESample.dart';

abstract class IDataLoggerService {
  bool get isStarted;

  void start();

  void stop();

  void addSample(BLESample sample);

  String toCsv();
}
