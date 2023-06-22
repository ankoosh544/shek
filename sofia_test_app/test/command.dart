import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sofia_test_app/enums/ble_device_type.dart';
import 'package:sofia_test_app/enums/direction.dart';
import 'package:sofia_test_app/enums/operation_mode.dart';
import 'package:sofia_test_app/enums/type_mission_status.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';
import 'package:sofia_test_app/interfaces/i_rides_service.dart';
import 'package:sofia_test_app/models/BLEDevice.dart';
import 'package:sofia_test_app/models/RideSearchParameters.dart';


class CommandPage extends StatefulWidget {
  @override
  _CommandPageState createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  static const int MAX_ATTEMPTS = 3;
  static const String ELEVATOR_ID = 'xyz';

  IRidesService? ridesService;
  ICoreController? coreController;
  INearestDeviceResolver? nearestDeviceResolver;

  String floorFrom = '';
  String floorTo = '';

  bool luceMancante = false;
  int intervalloMessaggioLuceAssente = 60; // in seconds
  int tickAttuali = 0;
  int secondiPassati = 0;
  bool primaConnessioneDevice = true;

  bool  testoLuceVisible = true;

  String floorPrecedente = '';
  int tempoRefresh = 5;
  ProgressDialog? loadingDialog;

  @override
  void initState() {
    super.initState();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
    onAppearing();
  });

    initializer();
  }

Future<void> onAppearing() async {
  //PageService.currentPage = this;
  if (coreController?.operationMode == OperationMode.idle) {
    await coreController?.stopScanningAsync();
    await coreController?.startScanningAsync();
  }
  refresh();

  try {
    await Future.delayed(Duration.zero, () {
  nearestDeviceResolver?.monitoraggioSoloPiano = true;
  coreController?.onNearestDeviceChanged.listen((device) {
    coreController_OnNearestDeviceChanged;
  });
  coreController?.onDeviceDisconnected.listen((device) {
    coreController_OnDeviceDisconnected;
  });
  coreController?.onCharacteristicUpdated.listen((device) {
    coreController_OnCharacteristicUpdated;
  });
  coreController?.onMissionStatusChanged.listen((device) {
    coreController_OnMissionStatusChanged;
  });
});

    Timer.periodic(Duration(seconds: tempoRefresh), (timer) {
      refresh();
    });
  } catch (ex) {
    // if (Preferences.get('DevOptions', false) == true) {
    //   await showDialog(
    //     context: context,
    //     builder: (context) => AlertDialog(
    //       title: Text('Alert'),
    //       content: Text(ex.toString() + '\r\n' + StackTrace.current.toString() + '\r\n' + ex.source.toString()),
    //       actions: [
    //         TextButton(
    //           child: Text('OK'),
    //           onPressed: () => Navigator.of(context).pop(),
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
    //   debugPrint(ex.toString() + '\r\n' + StackTrace.current.toString() + '\r\n' + ex.source.toString());
    // }
  }
}
  @override
  void dispose() {
    // coreController!.onNearestDeviceChanged!.cancel();
    // coreController!.onDeviceDisconnected!.cancel();
    // coreController!.onCharacteristicUpdated!.cancel();
    // coreController!.onMissionStatusChanged!.cancel();
    super.dispose();
  }

  void initializer() {
    try {
      coreController = GetIt.instance<ICoreController>();
     // ridesService = GetIt.instance<IRidesService>();
      nearestDeviceResolver = GetIt.instance<INearestDeviceResolver>();
    } catch (ex) {
      // if (Preferences.getBool('DevOptions', defaultValue: false) == true) {
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text('Alert'),
      //       content: Text(
      //           '${ex.toString()}\n${ex.stackTrace.toString()}\n${ex.source.toString()}'),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           child: Text('OK'),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   debugPrint(
      //       '${ex.toString()}\n${ex.stackTrace.toString()}\n${ex.source.toString()}');
      // }
    }
  }

  void coreController_OnMissionStatusChanged(dynamic sender, e) async {
    try {
      if (loadingDialog != null) {
        await loadingDialog!.hide();
      }

      if (this.coreController!.missionStatus ==
          TypeMissionStatus.MISSION_QUEUED.index) {
        if (floorTo != "") {
          Navigator.pushNamed(
            context,
            '/StatusPage?currentFloor=$floorFrom&targetFloor=$floorTo',
          );

          floorTo = "";
        }
      }
    } catch (ex) {
      // if (Preferences.getBool('DevOptions', defaultValue: false) == true) {
      //   await showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text('Alert'),
      //       content: Text('${ex.toString()}\n${ex.stackTrace.toString()}\n${ex.source.toString()}'),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.pop(context);
      //           },
      //           child: Text('OK'),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   debugPrint('${ex.toString()}\n${ex.stackTrace.toString()}\n${ex.source.toString()}');
      // }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nearestDeviceResolver!.monitoraggioSoloPiano = true;

    Timer.periodic(Duration(seconds: tempoRefresh), (timer) {
      refresh();
    });
  }

void coreController_OnNearestDeviceChanged(dynamic sender, BLEDevice device) {
  refresh();
}

  void coreController_OnDeviceDisconnected(sender, e) {
    refresh();
  }

  void coreController_OnCharacteristicUpdated(sender, e) {
    refresh();
  }

  void refresh() async {
  String targetFloor = '';

  if (coreController == null || coreController?.devices == null || coreController!.devices!.isEmpty) {
  setState(() {
   final waitVisible = true;
   final grigliaFromToVisible = false;
    // this.currentFloorLabel.text = '';
    // this.confirmButton.isEnabled = false;
    // this.floorSelectorEntry.isEnabled = false;
  });
  return;
}


  if (coreController!.nearestDevice != null) {
    targetFloor = await getTargetFloorAsync(coreController!.nearestDevice!.alias);

    setState(() {
      if (coreController!.outOfService == true) {
       final waitVisible = false;
       final grigliaFromToVisible = true;
        // Debug.print('************ Fuori servizio !!!! ***********');
        // this.coreController.Get_Piano_Cabina();
       // testoErroreText = Res.appResources.elevatorOutOfOrder;
        if (coreController?.carDirection == Direction.up) {
          // posizioneCabinaText =
          //     '${Res.appResources.locationCabinBetween}${coreController.carFloor} ${(coreController.carFloorNum + 1).toString()}';
        } else if (coreController?.carDirection == Direction.down) {
          // posizioneCabinaText =
          //     '${Res.appResources.locationCabinBetween}${coreController.carFloor} ${(coreController.carFloorNum - 1).toString()}';
        } else if (coreController?.carDirection == Direction.stopped) {
          // posizioneCabinaText = '${Res.appResources.locationCabin} ${coreController.carFloor}';
        }
      const  testoErroreVisible = true;
      const  posizioneCabinaVisible = true;
      } else {
     const   testoErroreVisible = false;
      const  posizioneCabinaVisible = false;
      }
    });
  }

  if (luceMancante == false) {
    if (coreController?.presenceOfLight == false) {
     final secondiPassati = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(tickAttuali * 10000)).inSeconds;

      // Debug.print('secondi:');
      // Debug.print(secondiPassati.toString());
      if (secondiPassati > intervalloMessaggioLuceAssente || primaConnessioneDevice == true) {
        primaConnessioneDevice = false;
        setState(() {
        final  testoLuceVisible = true;
        });
        // await showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: Text('Info'),
        //     content: Text(Res.appResources.attentionLackOfLight),
        //     actions: [
        //       TextButton(
        //         child: Text('Ok'),
        //         onPressed: () => Navigator.of(context).pop(),
        //       ),
        //     ],
        //   ),
        // );
        // Debug.print('************ Luce mancante !!!! ***********');
        luceMancante = true;
       tickAttuali = DateTime.now().millisecondsSinceEpoch ~/ 10000;
      }
    }
  }

  if (luceMancante == true) {
    if (coreController?.presenceOfLight == true) {
      luceMancante = false;
      setState(() {
        testoLuceVisible = false;
      });
      // Debug.print('************ Luce presente !!!! ***********');
    }
  }

  setState(() {
    if (isFloor(coreController?.nearestDevice)) {
    const  waitVisible = false;
    const  grigliaFromToVisible = true;

      if (coreController?.nearestDevice?.alias != floorPrecedente) {
        if (Platform.isIOS) {
        const  confirmButtonVisible = true;
        }
      final  welcomeLabelText = 'Welcome ${coreController?.loggerUser?.username}';
      const  fromFloorText = "Enter  From Floor Test";
      const  toFloorText = "Enter To Floor Test";
      final  currentFloorLabelText = coreController?.nearestDevice?.alias;
      final  confirmButtonEnabled = true;
      final  floorSelectorEntryEnabled = true;
      final  floorSelectorEntryText = targetFloor;
        // this.floorSelectorEntry.requestFocus();
        floorPrecedente = coreController!.nearestDevice!.alias;
      } else {
      const  floorSelectorEntryEnabled = true;
        // this.floorSelectorEntry.requestFocus();
      const  confirmButtonEnabled = true;
      }
    } else {
    final  waitVisible = true;
    final  grigliaFromToVisible = false;
    }
  });
}


  bool isFloor(BLEDevice? device) {
    return device != null && device.type == BleDeviceType.esp32;
  }

  Future<String> getTargetFloorAsync(String startingFloor) async {
    var lastRides = await ridesService!.searchAsync(RideSearchParameters(
      length: MAX_ATTEMPTS,
      elevatorId: ELEVATOR_ID,
      startingFloor: startingFloor,
      username: coreController?.loggerUser?.username ?? '',
    ));

    var floors = lastRides.map((r) => r.targetFloor).toList();
    var targetFloor =
        floors.length == MAX_ATTEMPTS && floors.toSet().length == 1
            ? floors.first
            : '';

    return targetFloor.toString();
  }

  Future<void> changeFloorAsync() async {
    bool chiamataEseguita = true;
    // coreController!.onNearestDeviceChanged
    //     .listen(coreControllerOnNearestDeviceChanged);
    // coreController.onDeviceDisconnected
    //     .listen(coreControllerOnDeviceDisconnected);
    // coreController.onCharacteristicUpdated
    //     .listen(coreControllerOnCharacteristicUpdated);
    // coreController.onMissionStatusChanged
    //     .listen(coreControllerOnMissionStatusChanged);

    // if (floorSelectorEntry.text.isEmpty) {
    //   return;
    // }

    // if (!isValid(floorSelectorEntry.text)) {
    //   if (loadingDialog != null) {
    //     await loadingDialog.dismiss();
    //   }
    //   await showDialog(
    //     context: context,
    //     builder: (_) => AlertDialog(
    //       title: Text('Info'),
    //       content: Text('Select a different destination'),
    //       actions: [
    //         TextButton(
    //           onPressed: () => Navigator.pop(context),
    //           child: Text('Ok'),
    //         ),
    //       ],
    //     ),
    //   );
    //   coreController.onNearestDeviceChanged
    //       .listen(coreControllerOnNearestDeviceChanged);
    //   coreController.onDeviceDisconnected
    //       .listen(coreControllerOnDeviceDisconnected);
    //   coreController.onCharacteristicUpdated
    //       .listen(coreControllerOnCharacteristicUpdated);
    //   coreController.onMissionStatusChanged
    //       .listen(coreControllerOnMissionStatusChanged);
    //   return;
    // }

    if (loadingDialog != null) {
      await loadingDialog!.hide();
    }

    //loadingDialog = ProgressDialog(BuildContext);

    try {
      await Future(() async {
        try {
          int priorita = 0;

          bool p = false;
          // p = Preferences.getBool('PriorityPresident') ?? false;
          if (p) {
            priorita += 0x1;
          }
          // p = Preferences.getBool('PriorityDisablePeople') ?? false;
          if (p) {
            priorita += 0x2;
          }

          List<int> pianoPriorita = [
            //  int.parse(floorSelectorEntry.text),
            priorita,
          ];

          //  floorFrom = currentFloorLabel.text;
          // floorTo = floorSelectorEntry.text;

          //   await coreController.changeFloorAsync(pianoPriorita);
        } catch (e) {
          // if (Preferences.getBool('DevOptions') == true) {
          //   chiamataEseguita = false;
          // } else {
          //   chiamataEseguita = false;
          // }
        }

        // try {
        //   final entity = Ride(
        //     elevatorId: ELEVATOR_ID,
        //     start: DateTime.now(),
        //     startingFloor: floorFrom,
        //     targetFloor: floorTo,
        //     username: coreController?.loggerUser != null
        //         ? coreController?.loggerUser!.username
        //         : '',
        //   );
        //   await ridesService?.addAsync(entity);
        // } catch (e) {
        // if (Preferences.getBool('DevOptions') == true) {
        //   showDialog(
        //     context: context,
        //     builder: (_) => AlertDialog(
        //       title: Text('Error'),
        //       content: Text('Cannot save call'),
        //       actions: [
        //         TextButton(
        //           onPressed: () => Navigator.pop(context),
        //           child: Text('Ok'),
        //         ),
        //       ],
        //     ),
        //   );
        // }
        //}
      });

      if (loadingDialog != null) {
        await loadingDialog?.hide();
      }

      await Navigator.pushNamed(
        context,
        '/StatusPage',
        arguments: {
          'currentFloor': coreController?.nearestDevice?.alias,
          //  'targetFloor': floorSelectorEntry.text,
        },
      );
    } catch (exc) {
      try {
        if (loadingDialog != null) {
          await loadingDialog?.hide();
        }
      } catch (e) {}

      // if (Preferences.getBool('DevOptions') == true) {
      //   showDialog(
      //     context: context,
      //     builder: (_) => AlertDialog(
      //       title: Text('Error'),
      //       content: Text('${exc.message}: errore sulla chiamata piano'),
      //       actions: [
      //         TextButton(
      //           onPressed: () => Navigator.pop(context),
      //           child: Text('Ok'),
      //         ),
      //       ],
      //     ),
      //   );
      // } else {
      //   debugPrint('${exc.message}: errore sulla chiamata piano');
      // }

      chiamataEseguita = false;
    }
  //chiamataEseguita => Call made
    if (!chiamataEseguita) {
      // coreController?.onNearestDeviceChanged
      //     .listen(coreController_OnNearestDeviceChanged);
      // coreController?.onDeviceDisconnected
      //     .listen(coreController_OnDeviceDisconnected);
      // coreController?.onCharacteristicUpdated
      //     .listen(coreController_OnCharacteristicUpdated);
      // coreController?.onMissionStatusChanged
      //     .listen(coreController_OnMissionStatusChanged);
    }
  }

  void onFloorSelectorCompleted() async {
    await changeFloorAsync();
  }

  void onConfirmButtonClicked() async {
    await changeFloorAsync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 50,
                          child: Container(
                            child: Text('Wait Connection'),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 40, 0, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(
                            child: Text('From Floor'),
                          ),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(
                            child: Text('To Floor'),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(
                            child: Text('Current Floor'),
                          ),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(
                            child: TextField(
                              enabled: false,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(40, 20, 40, 20),
                      child: ElevatedButton(
                        onPressed: () => onConfirmButtonClicked(),
                        child: Text('Confirm'),
                      ),
                    ),
                    // Container(
                    //   child: Text(
                    //     'Attention: Lack of Light',
                    //     style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 20,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 100, 0, 0),
              //   child: Column(
              //     children: [
              //       Text(
              //         'Error Text 1',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 20,
              //         ),
              //       ),
              //       Text(
              //         'Cabin Position',
              //         style: TextStyle(
              //           fontWeight: FontWeight.bold,
              //           fontSize: 20,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
