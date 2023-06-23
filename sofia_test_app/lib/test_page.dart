// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:get_it/get_it.dart';
// import 'package:intl/intl.dart';
// import 'package:sofia_test_app/footer.dart';
// import 'package:sofia_test_app/interfaces/i_core_controller.dart';

// class TestPage extends StatefulWidget {
//   @override
//   _TestPageState createState() => _TestPageState();
// }

// class _TestPageState extends State<TestPage> {
//   late ICoreController coreController;
//   // IFileSystemService fileSystemService;
//   // ILogging logging;
//   int itemCount = 0;

//   @override
//   void initState() {
//     super.initState();
//     initDependencies();
//     startTimer();
//   }

//   void initDependencies() {
//       coreController = GetIt.instance<ICoreController>();
//     // fileSystemService = DependencyService.get<IFileSystemService>();
//     // logging = DependencyService.get<ILogging>();
//   }

//   void startTimer() {
//     Timer.periodic(Duration(milliseconds: 1000), (_) {
//       refreshListView();
//     });
//   }
// void refreshListView() {
//   debugPrint(coreController.devices.toString());
//   debugPrint("============================RefreshListview");
//   debugPrint(coreController.nearestDevice.toString());
//   print("nearest device=========================");
//   if (mounted) {
//   setState(() {
//     if (coreController.devices != null) {
//       itemCount = coreController.devices!.length;
//     } else {
//       itemCount = 0; // or any other appropriate value if devices being null is an exceptional case
//     }
//   });
//   }
// }

//   // void btnDataLoggerStartClicked() {
//   //   coreController.dataLogger.start();
//   //   refreshDataLoggerButtons(true);
//   // }

//   // void btnDataLoggerStopClicked() {
//   //   coreController.dataLogger.stop();
//   //   refreshDataLoggerButtons(false);
//   // }

//   // void btnDataLoggerExportClicked() {
//   //   List<String> records = coreController.dataLogger.toCsv().split("\n");
//   //   for (String record in records) {
//   //     logging.logEvent(AppLogLevel.info, record);
//   //   }
//   // }

//   void refreshDataLoggerButtons(bool isStarted) {
//     setState(() {}); // Notify Flutter to rebuild the UI
//   }

//   void resetConfigurationClicked() {
//     try {
//      // clearPreferences();
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Information"),
//             content: Text("All preferences deleted"),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text("OK"),
//               ),
//             ],
//           );
//         },
//       );
//     } catch (ex) {
//       print(ex);
//     }
//   }

//   // void clearPreferences() {
//   //   Preferences.clear();
//   //   String valore = "";
//   //   Preferences.setString("AppLanguage", "");
//   //   valore = Preferences.getString("AppLanguage") ?? "";

//   //   Preferences.setBool("VisualMessages", true);
//   //   Preferences.setBool("AudioMessages", false);
//   //   Preferences.setBool("TouchCommand", true);
//   //   Preferences.setBool("AudioCommand", false);
//   //   Preferences.setBool("PriorityPresident", false);
//   //   Preferences.setBool("PriorityDisablePeople", false);
//   //   Preferences.setString("PasswordUtente", "");

//   //   Preferences.setBool("PriorityDisablePeople", false);
//   //   Preferences.setBool("IsDisablePeople", false);
//   //   Preferences.setBool("IsPresident", false);
//   // }

//   // void testVoiceClicked() async {
//   //   try {
//   //     String lingua = Preferences.getString("AppLanguage")?.toLowerCase();
//   //     String linguaDevice =
//   //         Localizations.localeOf(context).toLanguageTag().split('-')[0];

//   //     if (lingua == null || lingua.isEmpty) {
//   //       lingua = linguaDevice;
//   //     }

//   //     String nazione = "en";
//   //     switch (lingua) {
//   //       case "italiano":
//   //         nazione = "it";
//   //         break;
//   //     }

//   //     List<dynamic> locales = await FlutterTts.getLocales();
//   //     List<dynamic> filteredLocales =
//   //         locales.where((l) => l['language'] == nazione).toList();
//   //     dynamic locale = filteredLocales.isNotEmpty ? filteredLocales.first : null;

//   //     if (locale != null) {
//   //       FlutterTts flutterTts = FlutterTts();
//   //       await flutterTts.setVolume(0.75);
//   //       await flutterTts.setSpeechRate(1.0);
//   //       await flutterTts.setLanguage(locale['language']);

//   //       switch (nazione) {
//   //         case "it":
//   //           await flutterTts.speak("Ciao mondo");
//   //           break;
//   //         case "en":
//   //           await flutterTts.speak("Hello world");
//   //           break;
//   //         default:
//   //           break;
//   //       }
//   //     }
//   //   } catch (ex) {
//   //     print(ex);
//   //   }
//   // }

//   @override
//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text("Test Page"),
//     ),
//     body: ListView(
//       padding: EdgeInsets.all(16),
//       children: [
//         Text(
//           "Devices:",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 8),
//         if (itemCount > 0)
//           ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: itemCount,
//             itemBuilder: (BuildContext context, int index) {
//               return Text(coreController.devices![index].toString());
//             },
//           )
//         else
//           Text("No devices found"),
//         SizedBox(height: 16),
//         Text(
//           "Timestamp: ${DateFormat('hh:mm:ss').format(DateTime.now())}",
//           style: TextStyle(fontSize: 16),
//         ),
//         SizedBox(height: 8),
//         if (coreController.nearestDevice != null)
//           Text(
//             "Nearest: ${coreController.nearestDevice}",
//             style: TextStyle(fontSize: 16),
//           )
//         else
//           Text("Nearest device not available"),
//         SizedBox(height: 16),
//         ElevatedButton(
//           onPressed: resetConfigurationClicked,
//           child: Text("Reset Configuration"),
//         ),
//       ],
//     ),
//     bottomNavigationBar: FooterWidget(),
//   );
// }

// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sofia_test_app/footer.dart';
import 'package:sofia_test_app/interfaces/i_core_controller.dart';
import 'package:sofia_test_app/models/BLEDevice.dart';
import 'package:sofia_test_app/services/nearest_device_resolver.dart';

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
      bottomNavigationBar: FooterWidget(),
    );
  }
}
