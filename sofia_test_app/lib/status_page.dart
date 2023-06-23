// import 'package:flutter/material.dart';
// import 'package:get_it/get_it.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sofia_test_app/enums/direction.dart';
// import 'package:sofia_test_app/enums/type_mission_status.dart';
// import 'package:sofia_test_app/interfaces/i_core_controller.dart';
// import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';

// class StatusPage extends StatefulWidget {
//   @override
//   _StatusPageState createState() => _StatusPageState();
// }

// class _StatusPageState extends State<StatusPage> {
//   int? currentFloor;
//   int? targetFloor;

//   int? get currentFloorValue => currentFloor;
//   set currentFloorValue(int? value) => currentFloor = value;

//   int? get targetFloorValue => targetFloor;
//   set targetFloorValue(int? value) => targetFloor = value;

//   bool luceMancante = false;
//   int intervalloMessaggioLuceAssente = 60; // in seconds
//   int tickAttuali = 0;
//   int secondiPassati = 0;
//   bool primaConnessioneDevice = true;

//   // Constants
//   static const int secondsPerFloor = 10;
//   static const int pollingTime = 1;
//   static const int topY = -100;
//   static const int bottomY = 100;

//   // Fields
//   Direction? direction;
//   int? currentPosition;
//   int? stepsCount;
//   int? stepHeight;
//   int? eta;

//   ICoreController? coreController;
//   INearestDeviceResolver? nearestDeviceResolver;

//   @override
//   void initState() {
//     super.initState();
//     nearestDeviceResolver = GetIt.instance<INearestDeviceResolver>();
//     coreController = GetIt.instance<ICoreController>();
//     setupPage();
//   }

//   void setupPage() async {
//     await Future.delayed(Duration.zero, () {
//       setState(() {
//         nearestDeviceResolver!.monitoraggioSoloPiano = false;

//         coreController.onFloorChanged.listen((event) {
//           coreController_OnFloorChanged(event);
//         });

//         coreController.onMissionStatusChanged.listen((event) {
//           coreController_OnMissionStatusChanged(event);
//         });

//         coreController.onCharacteristicUpdated.listen((event) {
//           coreController_OnCharacteristicUpdated(event);
//         });

//         eta = (currentFloor - targetFloor).abs() * SECONDS_PER_FLOOR;

//         floor1Label.text = coreController.carDirection == Direction.up
//             ? '$targetFloor'
//             : '$currentFloor';
//         floor2Label.text = coreController.carDirection == Direction.up
//             ? '$currentFloor'
//             : '$targetFloor';

//         if (coreController.carDirection != Direction.stopped) {
//           directionIcon.source =
//               direction == Direction.up ? 'up.png' : 'down.png';
//         } else {
//           directionIcon.source = null;
//         }

//         elevatorIcon.translationY = currentPosition;
//         targetLabel.text = 'ETA to floor $targetFloor';
//         int minuti = (eta ~/ 60) + 2;
//         String tmp = '${Res.appResources['TimeLeft']} $minuti ';

//         if (minuti > 1) {
//           tmp += '${Res.appResources['Minuts']}';
//         } else {
//           tmp += '${Res.appResources['Minut']}';
//         }

//         etaLabel.text = tmp;
//       });
//     });

//     visulizzaEventi();
//   }

//   void visulizzaEventi() {
//     try {
//       if (!luceMancante) {
//         if (!coreController.presenceOfLight) {
//           secondiPassati =
//               ((DateTime.now().microsecondsSinceEpoch - tickAttuali) ~/
//                   1000000);
//           debugPrint('secondi:');
//           debugPrint(secondiPassati.toString());
//           if (secondiPassati > intervalloMessaggioLuceAssente ||
//               primaConnessioneDevice) {
//             primaConnessioneDevice = false;
//             setState(() {
//               //await showDialog(...)
//               lackOfLightlabel.isVisible = true;
//             });

//             debugPrint('************ Luce mancante !!!! ***********');
//             luceMancante = true;
//             tickAttuali = DateTime.now().microsecondsSinceEpoch;
//           }
//         }
//       }

//       if (luceMancante) {
//         if (coreController.presenceOfLight) {
//           luceMancante = false;
//           setState(() {
//             lackOfLightlabel.isVisible = false;
//           });
//           debugPrint('************ Luce presente !!!! ***********');
//         }
//       }

//       setState(() {
//         if (coreController.outOfService) {
//           OutOfOrder.isVisible = true;
//         } else {
//           OutOfOrder.isVisible = false;
//         }

//         carFloorLabel.text = coreController.carFloor;

//         debugPrint('CarDirection: ${coreController.carDirection}');
//         if (coreController.carDirection != Direction.stopped) {
//           directionIcon.source = coreController.carDirection == Direction.up
//               ? 'up.png'
//               : 'down.png';
//         } else {
//           directionIcon.source = null;
//         }
//       });
//     } catch (e) {
//       if (Preferences.getBool('DevOptions') ?? false) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Alert'),
//             content: Text('$e\n${e.stackTrace}\n${e.source}'),
//             actions: <Widget>[
//               TextButton(
//                 child: Text('OK'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//         );
//       } else {
//         debugPrint('$e\n${e.stackTrace}\n${e.source}');
//       }
//     }
//   }

//   void coreController_OnCharacteristicUpdated(EventArgs event) {
//     visulizzaEventi();
//   }

//   void coreController_OnMissionStatusChanged(EventArgs event) {
//     if (coreController.missionStatus == TypeMissionStatus.missionFinished) {
//       debugPrint('Mission completed');
//       returnToCommandPage();
//     }
//   }

//   void coreController_OnFloorChanged(String e) {
//     setState(() {
//       carFloorLabel.text = e;
//     });
//   }

//   void returnToCommandPage() {
//     stopWatch();
//     // await Navigator.pushNamed(context, '/CommandPage');
//     Navigator.pop(context);
//   }

//   void stopWatch() {
//     try {
//       coreController.onFloorChanged.cancel();
//       coreController.onMissionStatusChanged.cancel();
//       coreController.onCharacteristicUpdated.cancel();
//     } catch (e) {
//       // Handle cancellation exception
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // Add your UI widgets here
//         );
//   }
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sofia_test_app/enums/direction.dart';
import 'package:sofia_test_app/enums/type_mission_status.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  INearestDeviceResolver? nearestDeviceResolver;

  bool luceMancante = false;
  int intervalloMessaggioLuceAssente = 60; // in seconds
  int tickAttuali = 0;
  int secondiPassati = 0;
  bool primaConnessioneDevice = true;

  // Constants
  static const int secondsPerFloor = 10;
  static const int pollingTime = 1;
  static const int topY = -100;
  static const int bottomY = 100;

  // Fields
  Direction? direction;
  int? currentPosition;
  int? stepsCount;
  int? stepHeight;
  int? eta;
  ICoreController? coreController;

  // Properties
  int? currentFloor;
  int? targetFloor;

  @override
  void initState() {
    super.initState();
    INearestDeviceResolver nearestDeviceResolver;
    ICoreController coreController;
  }

  @override
  void dispose() {
    super.dispose();
    // StopWatch();
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // Extract floorFrom and floorTo parameters
    final floorFrom = args?['currentFloor'];
    final floorTo = args?['targetFloor'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Status Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Floor: $currentFloor',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Target Floor: $targetFloor',
              style: TextStyle(fontSize: 20),
            ),
            ElevatedButton(
              onPressed: ReturnToCommandPage,
              child: Text('Return to Command Page'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> VisulizzaEventi() async {
    try {
      if (!luceMancante) {
        // if (!coreController!.presenceOfLight) {
        secondiPassati =
            ((DateTime.now().microsecondsSinceEpoch - tickAttuali) /
                    Duration.microsecondsPerSecond)
                .toInt();
        if (secondiPassati > intervalloMessaggioLuceAssente ||
            primaConnessioneDevice) {
          primaConnessioneDevice = false;
          setState(() {
            // this.lackOfLightlabel = true;
          });
          luceMancante = true;
          tickAttuali = DateTime.now().microsecondsSinceEpoch;
        }
        // }
      }

      if (luceMancante) {
        // if (coreController!.presenceOfLight) {
        luceMancante = false;
        setState(() {
          //  this.lackOfLightlabel = false;
        });
        //}
      }

      // setState(() {
      //   if (coreController!.outOfService) {
      //     OutOfOrder.IsVisible = true;
      //   } else {
      //     OutOfOrder.IsVisible = false;
      //   }

      //   carFloorLabel.Text = coreController!.carFloor;
      //   if (coreController!.carDirection != Direction.stopped) {
      //     this.directionIcon.Source =
      //         coreController!.carDirection == Direction.up
      //             ? "up.png"
      //             : "down.png";
      //   } else {
      //     this.direct ionIcon.Source = null;
      //   }
      // });
    } catch (ex) {
      print(ex);
    }
  }

  void CoreController_OnCharacteristicUpdated(sender, args) {
    try {
      VisulizzaEventi();
    } catch (ex) {
      print(ex);
    }
  }

  void CoreController_OnMissionStatusChanged(sender, args) {
    if (coreController!.missionStatus == TypeMissionStatus.MISSION_FINISHED) {
      print("Mission completed");
      ReturnToCommandPage();
    }
  }

  void CoreController_OnFloorChanged(sender, e) {
    setState(() {
      // this.carFloorLabel.Text = e;
    });
  }

  void ToolbarItem_Clicked(sender, e) {
    ReturnToCommandPage();
  }

  void ReturnToCommandPage() {
    // StopWatch();
    Navigator.pop(context);
  }

  // void StopWatch() {
  //   coreController.onFloorChanged -= CoreController_OnFloorChanged;
  //   coreController.onMissionStatusChanged -=
  //       CoreController_OnMissionStatusChanged;
  //   coreController.onCharacteristicUpdated -=
  //       CoreController_OnCharacteristicUpdated;
  // }
}
