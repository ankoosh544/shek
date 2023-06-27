

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';


import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/services/nearest_device_resolver.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late ICoreController coreController;
  // late NearestDeviceResolver nearestDeviceResolver;
  int itemCount = 0;

  @override
  void initState() {
    super.initState();
    initDependencies();
    startTimer();
  }

  void initDependencies() {
    coreController = GetIt.instance<ICoreController>();
    //nearestDeviceResolver = GetIt.instance<NearestDeviceResolver>();
  }

  void startTimer() {
    Timer.periodic(Duration(milliseconds: 1000), (_) {
      refreshListView();
    });
  }

  void refreshListView() {
    debugPrint(coreController.devices.toString());
    debugPrint("============================RefreshListview");
    debugPrint(coreController.nearestDevice.toString());

    if (mounted) {
      setState(() {
        if (coreController.devices != null) {
          itemCount = coreController.devices!.length;
        } else {
          itemCount = 0;
        }
      });
    }
  }

  void resetConfigurationClicked() {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Information"),
            content: Text("All preferences deleted"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (ex) {
      print(ex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test Page"),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "Devices:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          if (itemCount > 0)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (BuildContext context, int index) {
                return Text(coreController.devices![index].toString());
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
            "Nearest is: ${coreController.nearestDevice.toString() ?? 'Not available'}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: resetConfigurationClicked,
            child: Text("Reset Configuration"),
          ),
        ],
      ),
   
    );
  }
}
