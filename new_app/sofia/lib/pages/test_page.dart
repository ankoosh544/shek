

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';



// import 'package:sofia/models/BLEDevice.dart';


// class TestPage extends StatefulWidget {
//   @override
//   _TestPageState createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
  
//   // late NearestDeviceResolver nearestDeviceResolver;
//   int itemCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     initDependencies();
//     startTimer();
//   }

//   void initDependencies() {
//     //coreController = GetIt.instance<ICoreController>();
//     //nearestDeviceResolver = GetIt.instance<NearestDeviceResolver>();
//   }

//   void startTimer() {
//     Timer.periodic(Duration(milliseconds: 1000), (_) {
//      // refreshListView();
//     });
//   }

//   // void refreshListView() {
//   //   debugPrint(coreController.devices.toString());
//   //   debugPrint("============================RefreshListview");
//   //   debugPrint(coreController.nearestDevice.toString());

//   //   if (mounted) {
//   //     setState(() {
//   //       if (coreController.devices != null) {
//   //         itemCount = coreController.devices!.length;
//   //       } else {
//   //         itemCount = 0;
//   //       }
//   //     });
//   //   }
//   // }

//   // void resetConfigurationClicked() {
//   //   try {
//   //     showDialog(
//   //       context: context,
//   //       builder: (BuildContext context) {
//   //         return AlertDialog(
//   //           title: Text("Information"),
//   //           content: Text("All preferences deleted"),
//   //           actions: [
//   //             TextButton(
//   //               onPressed: () => Navigator.pop(context),
//   //               child: Text("OK"),
//   //             ),
//   //           ],
//   //         );
//   //       },
//   //     );
//   //   } catch (ex) {
//   //     print(ex);
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test Page"),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(16),
//         children: []
          
         
//       ),
   
//     );
//   }
// }
