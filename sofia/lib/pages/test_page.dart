import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/logic/controller/test_controller.dart';
import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/services/nearest_device_resolver.dart';
import 'package:sofia/widgets/custom_drawer.dart';

class TestPage extends StatelessWidget {
  final TestController testController = Get.put(TestController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'TestPage',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      drawer: CustomDrawer(
        indexClicked: 1,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Devices:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (testController.itemCount > 0)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: testController.itemCount,
              itemBuilder: (BuildContext context, int index) {
                return Text(
                    testController.coreController.devices![index].toString());
              },
            )
          else
            Text("No devices found"),
          SizedBox(height: 16),
          Text(
            "Timestamp: ${DateFormat('hh:mm:ss').format(DateTime.now())}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            "Nearest is: ${testController.coreController.nearestDevice ?? 'Not available'}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
