import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_it/get_it.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:sofia/enums/ble_device_type.dart';
import 'package:sofia/enums/direction.dart';
import 'package:sofia/enums/operation_mode.dart';
import 'package:sofia/enums/type_mission_status.dart';
import 'package:sofia/interfaces/i_ble_service.dart';
import 'package:sofia/interfaces/i_core_controller.dart';
import 'package:sofia/interfaces/i_nearest_device_service.dart';
import 'package:sofia/interfaces/i_rides_service.dart';
import 'package:sofia/models/BLEDevice.dart';
import 'package:sofia/models/RideSearchParameters.dart';

class CommandController extends GetxController {
  bool isLoading = false;
  static const int MAX_ATTEMPTS = 3;
  static const String ELEVATOR_ID = 'xyz';

  late IRidesService ridesService;
  late ICoreController coreController;
  late INearestDeviceResolver nearestDeviceResolver;
  late IBleService bleService;

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
  //new
  bool isConnected = false;
  bool outOfServiceError = false;
  String floorFrom = '0';
  String floorTo = '';

  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  StreamSubscription<dynamic>? nearestDeviceSubscription;
  StreamSubscription<dynamic>? deviceDisconnectedSubscription;
  StreamSubscription<dynamic>? characteristicUpdatedSubscription;
  StreamSubscription<dynamic>? missionStatusChangedSubscription;

  @override
  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future init() async {
    coreController = GetIt.instance<ICoreController>();
    ridesService = GetIt.instance<IRidesService>();
    nearestDeviceResolver = GetIt.instance<INearestDeviceResolver>();
    bleService = GetIt.instance<IBleService>();

    nearestDeviceSubscription = coreController.onNearestDeviceChanged
        .listen(coreControllerOnNearestDeviceChanged);
    deviceDisconnectedSubscription = coreController.onDeviceDisconnected
        .listen(coreControllerOnDeviceDisconnected);
    characteristicUpdatedSubscription = coreController.onCharacteristicUpdated
        .listen(coreControllerOnCharacteristicUpdated);
    missionStatusChangedSubscription = coreController.onMissionStatusChanged
        .listen(coreControllerOnMissionStatusChanged);
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
            nearestDeviceSubscription.onDone(() {});
          }

          if (coreController.onDeviceDisconnected != null) {
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
    } catch (ex) {}
  }

  Future<void> refresh() async {
    print("============CommandPage===RefreshFunction====");
    // print(coreController.nearestDevice);
    // print(coreController.devices);
    String targetFloor = '';
    if (coreController.devices?.isEmpty ?? false) {
      isConnected = false;
      // wait.isVisible = true;
      // GrigliaFromTo.isVisible = false;
      return;
    }

    if (coreController.nearestDevice != null) {
      targetFloor =
          await getTargetFloorAsync(coreController.nearestDevice!.alias);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (coreController.outOfService == true) {
          // Wait.isVisible = false;
          // GrigliaFromTo.isVisible = true;

          if (coreController.carDirection == Direction.up) {
            final PosizioneCabina = "Location of Cabin going Up";
          } else if (coreController.carDirection == Direction.down) {
            final PosizioneCabina = "Location of Cabin going Down";
          } else if (coreController.carDirection == Direction.stopped) {
            final PosizioneCabina = "Location of Cabin Stopped";
          }

          outOfServiceError = true;
          final PosizioneCabinaIsVisible = true;
        } else {
          outOfServiceError = false;
          // TestoErrore.isVisible = false;
          // PosizioneCabinaIsVisible = false;
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
            testoLuceVisible = true;
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
          testoLuceVisible = false;
        });
        // Debug.print('************ Luce presente !!!! ***********');
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (isFloor(coreController.nearestDevice)) {
        waitVisible = false;
        grigliaFromToVisible = true;

        if (coreController?.nearestDevice?.alias != floorPrecedente) {
          if (Platform.isIOS) {
            const confirmButtonVisible = true;
          }
          isConnected = true;
          final welcomeLabelText =
              'Welcome ${coreController?.loggerUser?.username}';
          const fromFloorText = "Enter  From Floor Test";
          const toFloorText = "Enter To Floor Test";
          final currentFloorLabelText = coreController?.nearestDevice?.alias;
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
        waitVisible = true;
        grigliaFromToVisible = false;
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

  void coreControllerOnNearestDeviceChanged(BLEDevice device) async {
    await refresh();
  }

  void coreControllerOnDeviceDisconnected(void _) async {
    print("Coming to disconnected Eventhandler");
    await refresh();
  }

  void coreControllerOnCharacteristicUpdated(void _) async {
    await refresh();
  }

  void coreControllerOnMissionStatusChanged(void _) async {
    try {
      if (loadingDialog != null) {
        await loadingDialog!.hide();
      }
      if (this.coreController!.missionStatus ==
          TypeMissionStatus.MISSION_QUEUED.index) {
        if (floorTo != "") {
          // Navigator.pushNamed(
          //   context,
          //   '/StatusPage?currentFloor=$floorFrom&targetFloor=$floorTo',
          // );
          floorTo = "";
        }
      }
    } catch (ex) {}
  }

}
