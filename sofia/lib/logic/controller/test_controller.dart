import 'dart:async';
import 'dart:ffi';

import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/models/BLEDevice.dart';

class TestController extends GetxController {
  late ICoreController coreController;
  BLEDevice? nearestDevice;

  int itemCount = 0;

  @override
  void onInit() {
    coreController = GetIt.instance<ICoreController>();
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: 500), (_) {
      refreshListView();
    });
  }

  void refreshListView() {
    if (coreController.devices != null && coreController.devices!.isNotEmpty) {
      // Find the nearest device
      nearestDevice = coreController
          .devices![0]; // Assuming the first device is the nearest one

      // You can modify the logic here to find the actual nearest device
      // For example, you could iterate through coreController.devices and compare distances to determine the nearest device.
      // Remember to update the assignment accordingly.

      itemCount = coreController.devices!.length;
    } else {
      nearestDevice = null;
      itemCount = 0;
    }
  }
}
