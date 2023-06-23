// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get_it/get_it.dart';
// import 'package:sofia_test_app/enums/direction.dart';
// import 'package:sofia_test_app/interfaces/i_core_controller.dart';
// import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';

// class StatusPage extends StatefulWidget {
//   final int currentFloor;
//   final int targetFloor;

//   StatusPage({required this.currentFloor, required this.targetFloor});

//   @override
//   _StatusPageState createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   INearestDeviceResolver? nearestDeviceResolver;

//   bool luceMancante = false;
//   int intervalloMessaggioLuceAssente = 60; // in secondi
//   late int tickAttuali; // memorizza il valore di tick corrente
//   late int secondiPassati;
//   bool primaConnessioneDevice = true;

//   static const int SECONDS_PER_FLOOR = 10;
//   static const int POLLING_TIME = 1;
//   static const int TOP_Y = -100;
//   static const int BOTTOM_Y = 100;

//   Direction? direction;
//   late int currentPosition;
//   late int stepsCount;
//   late int stepHeight;
//   late int eta;

//   ICoreController? coreController;

//   int? currentFloor;
//   int? targetFloor;

//   int? get currentFloorValue => currentFloor;
//   set currentFloorValue(int? value) => currentFloor = value;

//   int? get targetFloorValue => targetFloor;
//   set targetFloorValue(int? value) => targetFloor = value;

//   @override
//   void initState() {
//     super.initState();
//     nearestDeviceResolver = GetIt.instance<INearestDeviceResolver>();
//     coreController = GetIt.instance<ICoreController>();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     stopWatch();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     startMonitoring();
//   }

//   void startMonitoring() async {
//     await Task.run(() {
//       nearestDeviceResolver!.monitoraggioSoloPiano = false;
//       coreController!.onFloorChanged.listen(coreController_OnFloorChanged);
//       coreController!.onMissionStatusChanged
//           .listen(coreController_OnMissionStatusChanged);
//       coreController!.onCharacteristicUpdated
//           .listen(coreController_OnCharacteristicUpdated);
//       setState(() {
//         eta = (widget.currentFloor - widget.targetFloor).abs() *
//             SECONDS_PER_FLOOR;
//         floor1Label.text = coreController!.carDirection == Direction.up
//             ? '${widget.targetFloor}'
//             : '${widget.currentFloor}';
//         floor2Label.text = coreController!.carDirection == Direction.up
//             ? '${widget.currentFloor}'
//             : '${widget.targetFloor}';
//         if (coreController!.carDirection != Direction.stopped) {
//           directionIcon.image = AssetImage(
//               coreController!.carDirection == Direction.up
//                   ? 'assets/images/up.png'
//                   : 'assets/images/down.png');
//         } else {
//           directionIcon.image = null;
//         }
//         elevatorIcon.transformation =
//             Matrix4.translationValues(0, currentPosition.toDouble(), 0);
//         targetLabel.text = 'ETA to floor ${widget.targetFloor}';
//         int minuti = (eta ~/ 60) + 2;
//         String tmp = 'Time Left $minuti ';
//         if (minuti > 1) {
//           tmp += 'Minutes';
//         } else {
//           tmp += 'Minute';
//         }
//         etaLabel.text = tmp;
//       });
//     });

//     visualizzaEventi();
//   }

//   void visualizzaEventi() {
//     try {
//       if (!luceMancante) {
//         if (!coreController!.presenceOfLight) {
//           secondiPassati =
//               ((DateTime.now().microsecondsSinceEpoch - tickAttuali) ~/
//                   Duration.microsecondsPerSecond);
//           log('secondi:');
//           log(secondiPassati.toString());
//           if (secondiPassati > intervalloMessaggioLuceAssente ||
//               primaConnessioneDevice) {
//             primaConnessioneDevice = false;
//             showDialog(
//               context: context,
//               builder: (_) => AlertDialog(
//                 title: const Text('Info'),
//                 content: const Text('Attention: Lack of Light'),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//             );
//             luceMancante = true;
//             tickAttuali = DateTime.now().microsecondsSinceEpoch;
//           }
//         }
//       }

//       if (luceMancante) {
//         if (coreController!.presenceOfLight) {
//           luceMancante = false;
//           setState(() {
//             lackOfLightlabel.visible = false;
//           });
//           log('************ Luce presente !!!! ***********');
//         }
//       }

//       setState(() {
//         if (coreController!.outOfService) {
//           outOfOrder.visible = true;
//         } else {
//           outOfOrder.visible = false;
//         }

//         carFloorLabel.text = coreController!.carFloor;
//         log('CarDirection: ${coreController!.carDirection}');
//         if (coreController!.carDirection != Direction.stopped) {
//           directionIcon.image = AssetImage(
//               coreController!.carDirection == Direction.up
//                   ? 'assets/images/up.png'
//                   : 'assets/images/down.png');
//         } else {
//           directionIcon.image = null;
//         }
//       });
//     } catch (ex, stackTrace) {
//       log('$ex\n$stackTrace');
//     }
//   }

//   void coreController_OnCharacteristicUpdated(dynamic sender, dynamic e) {
//     try {
//       visualizzaEventi();
//     } catch (ex, stackTrace) {
//       log('$ex\n$stackTrace');
//     }
//   }

//   void coreController_OnMissionStatusChanged(dynamic sender, dynamic e) {
//     if (coreController!.missionStatus ==
//         TypeMissionStatus.missionFinished.index) {
//       log('Mission completed');
//       returnToCommandPage();
//     }
//   }

//   void coreController_OnFloorChanged(dynamic sender, String e) {
//     setState(() {
//       carFloorLabel.text = e;
//     });
//   }

//   void stopWatch() {
//     coreController!.onFloorChanged.cancel();
//     coreController!.onMissionStatusChanged.cancel();
//     coreController!.onCharacteristicUpdated.cancel();
//   }

//   void returnToCommandPage() {
//     stopWatch();
//     Navigator.pushReplacementNamed(context, '/commandPage');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Status Page'),
//       ),
//       body: Center(
//         child: Column(
//           children: <Widget>[
//             // Widgets for Status Page
//           ],
//         ),
//       ),
//     );
//   }
// }
