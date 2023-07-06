import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sofia_test_app/enums/ble_device_type.dart';
import 'package:sofia_test_app/enums/direction.dart';
import 'package:sofia_test_app/enums/operation_mode.dart';
import 'package:sofia_test_app/enums/type_mission_status.dart';
import 'package:sofia_test_app/footer.dart';
import 'package:sofia_test_app/interfaces/i_ble_service.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/interfaces/i_nearest_device_service.dart';
import 'package:sofia_test_app/interfaces/i_rides_service.dart';
import 'package:sofia_test_app/models/BLEDevice.dart';
import 'package:sofia_test_app/models/RideSearchParameters.dart';
import 'package:sofia_test_app/status_page.dart';

class CommandPage extends StatefulWidget {
  @override
  _CommandPageState createState() => _CommandPageState();
}

class _CommandPageState extends State<CommandPage> {
  static const int MAX_ATTEMPTS = 3;
  static const String ELEVATOR_ID = 'xyz';

  late IRidesService ridesService;
  late ICoreController coreController;
  late INearestDeviceResolver nearestDeviceResolver;

  late IBleService bleService;

  String floorFrom = '0';
  String floorTo = '';

  bool luceMancante = false;
  int intervalloMessaggioLuceAssente = 60; // in seconds
  int tickAttuali = 0;
  int secondiPassati = 0;
  bool primaConnessioneDevice = true;

  bool testoLuceVisible = true;

  String floorPrecedente = '';
  int tempoRefresh = 5;
  ProgressDialog? loadingDialog;

  bool waitVisible = true;
  bool grigliaFromToVisible = false;
  bool isConnected = false;

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onAppearing();
    });
  }

  Future<void> onAppearing() async {
    //PageService.currentPage = this;
    if (coreController.operationMode == OperationMode.idle) {
      await coreController.stopScanningAsync();
      await coreController.startScanningAsync();
    }

    await refresh();
    try {
      await Future.delayed(Duration.zero, () {
        nearestDeviceResolver.monitoraggioSoloPiano = true;
        if (coreController != null) {
          // Register event listeners
          if (coreController.onNearestDeviceChanged != null) {
            coreController?.onNearestDeviceChanged
                .listen(coreControllerOnNearestDeviceChanged);
          }
          // Check if onNearestDeviceChanged event is available
          if (coreController?.onNearestDeviceChanged != null) {
            // Register event listener
            StreamSubscription<BLEDevice> nearestDeviceSubscription;
            nearestDeviceSubscription =
                coreController!.onNearestDeviceChanged.listen((device) {
              coreControllerOnNearestDeviceChanged(device);
            });
            nearestDeviceSubscription.onData((device) {});

            // Print a message when the event listener is canceled or completed
            nearestDeviceSubscription.onDone(() {
              print(
                  '====onNearestDeviceChanged event listener is canceled or completed====');
            });
          } else {
            print('=====onNearestDeviceChanged event is not available======');
          }
          if (coreController.onDeviceDisconnected != null) {
            print("============DeviceDisconnecred==========================");
            coreController.onDeviceDisconnected
                .listen(coreControllerOnDeviceDisconnected);
          }

          if (coreController.onCharacteristicUpdated != null) {
            coreController.onCharacteristicUpdated
                .listen(coreControllerOnCharacteristicUpdated);
          }

          if (coreController.onMissionStatusChanged != null) {
            coreController.onMissionStatusChanged
                .listen(coreControllerOnMissionStatusChanged);
          }
        } else {
          print('coreController is not initialized');
        }

        // coreController.onNearestDeviceChanged.listen(coreControllerOnNearestDeviceChanged);
        // coreController.onDeviceDisconnected.listen(coreControllerOnDeviceDisconnected);
        // coreController.onCharacteristicUpdated.listen(coreControllerOnCharacteristicUpdated);
        // coreController.onMissionStatusChanged.listen(coreControllerOnMissionStatusChanged);
      });

      Timer.periodic(Duration(seconds: tempoRefresh), (timer) async {
        await refresh();
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
    // nearestDeviceService?.monitorNearestDevice(false);
    coreController.onNearestDeviceChanged.drain();
    coreController.onDeviceDisconnected.drain();
    coreController.onCharacteristicUpdated.drain();
    coreController.onMissionStatusChanged.drain();

    super.dispose();
  }

  void initializer() {
    try {
      coreController = GetIt.instance<ICoreController>();
      ridesService = GetIt.instance<IRidesService>();
      nearestDeviceResolver = GetIt.instance<INearestDeviceResolver>();
      bleService = GetIt.instance<IBleService>();
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

  void coreControllerOnMissionStatusChanged(void _) async {
    print("Check===========");
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

    Timer.periodic(Duration(seconds: tempoRefresh), (timer) async {
      await refresh();
    });
  }

// Event handler for onNearestDeviceChanged
  void coreControllerOnNearestDeviceChanged(BLEDevice device) async {
    await refresh();
    // Handle the event here
    print('Nearest device changed: $device');
  }

  void coreControllerOnDeviceDisconnected(void _) async {
    print("Coming to disconnected Eventhandler");
    await refresh();
  }

  void coreControllerOnCharacteristicUpdated(void _) async {
    await refresh();
  }

  Future<void> refresh() async {
    print("============CommandPage===RefreshFunction====");
    // print(coreController.nearestDevice);
    // print(coreController.devices);
    String targetFloor = '';
    if (coreController.devices?.isEmpty ?? false) {
      if (mounted) {
        setState(() {
          isConnected = false;

          // wait.isVisible = true;
          // GrigliaFromTo.isVisible = false;
        });
      }
      return;
    }

    if (coreController.nearestDevice != null) {
      targetFloor =
          await getTargetFloorAsync(coreController.nearestDevice!.alias);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (coreController.outOfService == true) {
              // Wait.isVisible = false;
              // GrigliaFromTo.isVisible = true;

              // Debug.Print("************ Fuori servizio !!!! ***********");
              // this.coreController.Get_Piano_Cabina();
              const TestoErrore = "ElevatorOutOfOrder";

              if (coreController.carDirection == Direction.up) {
                // PosizioneCabina.text = String.format(
                //     Res.AppResources.LocationCabinBetween,
                //     coreController.carFloor,
                //     (coreController.carFloorNum + 1).toString());
                final PosizioneCabina = "Location of Cabin going Up";
              } else if (coreController.carDirection == Direction.down) {
                // PosizioneCabina = String.format(
                //     Res.AppResources.LocationCabinBetween,
                //     coreController.carFloor,
                //     (coreController.carFloorNum - 1).toString());
                final PosizioneCabina = "Location of Cabin going Down";
              } else if (coreController.carDirection == Direction.stopped) {
                // PosizioneCabina.text =
                //     Res.AppResources.LocationCabin + " " + coreController!.carFloor;
                final PosizioneCabina = "Location of Cabin Stopped";
              }

              const testoErrore = true;
              final PosizioneCabinaIsVisible = true;
            } else {
              // TestoErrore.isVisible = false;
              // PosizioneCabinaIsVisible = false;
            }
          });
        }
      });
    }

    if (luceMancante == false) {
      if (coreController.presenceOfLight == false) {
        final secondiPassati = DateTime.now()
            .difference(
                DateTime.fromMillisecondsSinceEpoch(tickAttuali * 10000))
            .inSeconds;

        // Debug.print('secondi:');
        // Debug.print(secondiPassati.toString());
        if (secondiPassati > intervalloMessaggioLuceAssente ||
            primaConnessioneDevice == true) {
          primaConnessioneDevice = false;
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            setState(() {
              testoLuceVisible = true;
            });
          });
          // setState(() {
          //   testoLuceVisible = true;
          // });
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
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          setState(() {
            testoLuceVisible = false;
          });
        });
        // Debug.print('************ Luce presente !!!! ***********');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("******************************$coreController");
      print(coreController.nearestDevice);
      if (mounted) {
        setState(() {
          print(coreController.nearestDevice);
          print("corecontroller of nearestDevice");

          if (isFloor(coreController.nearestDevice)) {
            print(
                "==========If Nearest Device Found===============================================");
            const waitVisible = false;
            const grigliaFromToVisible = true;

            if (coreController?.nearestDevice?.alias != floorPrecedente) {
              if (Platform.isIOS) {
                const confirmButtonVisible = true;
              }
              setState(() {
                isConnected = true;
              });
              final welcomeLabelText =
                  'Welcome ${coreController?.loggerUser?.username}';
              const fromFloorText = "Enter  From Floor Test";
              const toFloorText = "Enter To Floor Test";
              final currentFloorLabelText =
                  coreController?.nearestDevice?.alias;
              final confirmButtonEnabled = true;
              final floorSelectorEntryEnabled = true;
              final floorSelectorEntryText = targetFloor;
              // this.floorSelectorEntry.requestFocus();
              floorPrecedente = coreController!.nearestDevice!.alias;
            } else {
              const floorSelectorEntryEnabled = true;
              // this.floorSelectorEntry.requestFocus();
              const confirmButtonEnabled = true;
            }
          } else {
            print(
                "==============================Else Nearest Device Not Found=======================================");
            waitVisible = true;
            grigliaFromToVisible = false;
          }
        });
      }
    });
  }

  bool isFloor(BLEDevice? device) {
    print(
        "*************************************IsFloor Device****************************************");
    print(device);
    print(isConnected);
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
    coreController.onNearestDeviceChanged
        .listen(coreControllerOnNearestDeviceChanged);
    coreController.onDeviceDisconnected
        .listen(coreControllerOnDeviceDisconnected);
    coreController.onCharacteristicUpdated
        .listen(coreControllerOnCharacteristicUpdated);
    coreController.onMissionStatusChanged
        .listen(coreControllerOnMissionStatusChanged);

    // if (floorSelectorEntry.text.isEmpty) {
    //   return;
    // }

    // if (!isValid(floorSelectorEntry.text)) {
    //   // if (loadingDialog != null) {
    //   //   await loadingDialog.dismiss();
    //   // }
    //   // await showDialog(
    //   //   context: context,
    //   //   builder: (_) => AlertDialog(
    //   //     title: Text('Info'),
    //   //     content: Text('Select a different destination'),
    //   //     actions: [
    //   //       TextButton(
    //   //         onPressed: () => Navigator.pop(context),
    //   //         child: Text('Ok'),
    //   //       ),
    //   //     ],
    //   //   ),
    //   // );
    //   coreController?.onNearestDeviceChanged
    //       .listen(coreController_OnNearestDeviceChanged);
    //   coreController?.onDeviceDisconnected
    //       .listen(coreController_OnDeviceDisconne
    //
    //
    //
    // cted);
    //   coreController?.onCharacteristicUpdated
    //       .listen(coreController_OnCharacteristicUpdated);
    //   coreController?.onMissionStatusChanged
    //       .listen(coreController_OnMissionStatusChanged);
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

  void _statusPage() {
    print("===============coming to StatusPage====================");
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusPage(),
      ),
    );
  }
  // void disconnected()async{
  //  // await bleService.disconnectToDeviceAsync();

  //   isConnected =false;

  // }
  // void reconnect(){
  //   bleService.startScanningAsync(-1);

  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isConnected
                      ? Text(
                          'Hello ${coreController.loggerUser?.username} Happy to see you again.\n Same destination ?',
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          'Elevator is Not Connected.',
                          style: TextStyle(fontSize: 18),
                        ),
                  //       ElevatedButton(onPressed: disconnected, child: Text("Disconnect"),),
                  // SizedBox(height: 20),
                  //   ElevatedButton(onPressed: reconnect, child: Text("ReConnect"),),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: TextEditingController(
                                text: '1'), // Set the default value here
                            decoration: InputDecoration(
                              labelText: 'From',
                            ),
                            enabled:
                                false, // Set enabled to false to make it non-editable
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: toController,
                            decoration: InputDecoration(
                              labelText: 'To',
                            ),
                            enabled:
                                isConnected, // Set enabled to your desired condition
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isConnected ? () => _statusPage : null,
                    child: Text('Confirm'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          FooterWidget(), // Add the FooterWidget here without any arguments
    );
  }
}
