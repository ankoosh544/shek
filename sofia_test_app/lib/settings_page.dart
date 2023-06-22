import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sofia_test_app/footer.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool abilitoCambioLingua = false;
  List<String> selezioneNazioneItems = ['English', 'Italiano', 'Spanish'];
  String selectedLanguage = 'English';
  bool switchVisualMessages = true;
  bool switchAudioMessages = false;
  bool switchTouchCommand = true;
  bool switchAudioCommand = false;
  bool switchPriorityPresident = false;
  bool switchPriorityDisablePeople = false;
  bool debugAlert = false;

  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    checkTypeUser();
    initSharedPreferences();
  }

  void initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    loadSavedPreferences();
  }

  void checkTypeUser() {
    // Perform your user type checking here
    setState(() {
      switchPriorityPresident = true; // Example value
      switchPriorityDisablePeople = true; // Example value
    });
  }

  void loadSavedPreferences() {
    setState(() {
      switchVisualMessages = _prefs.getBool('VisualMessages') ?? true;
      switchAudioMessages = _prefs.getBool('AudioMessages') ?? false;
      switchTouchCommand = _prefs.getBool('TouchCommand') ?? true;
      switchAudioCommand = _prefs.getBool('AudioCommand') ?? false;
      switchPriorityPresident = _prefs.getBool('PriorityPresident') ?? false;
      switchPriorityDisablePeople =
          _prefs.getBool('PriorityDisablePeople') ?? false;
      debugAlert = _prefs.getBool('DevOptions') ?? false;
      selectedLanguage = _prefs.getString('Language') ?? 'English';
    });
  }

  void savePreference(String key, dynamic value) {
    _prefs.setBool(key, value);
  }

  void selezioneNazioneSelectedIndexChanged(String? selectedItem) {
    try {
      if (!abilitoCambioLingua) return;
      if (selectedLanguage == selectedItem) return;
      setState(() {
        selectedLanguage = selectedItem!;
      });
      Locale? locale;
      switch (selectedItem) {
        case 'English':
          locale = null; // Default system language
          break;
        case 'Italiano':
          locale = const Locale('it');
          break;
        case 'Spanish':
          locale = const Locale('es');
          break;
        default:
          break;
      }
      // Set the new locale
      // if (locale != null) {
      //   SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //     systemNavigationBarColor: Colors.white,
      //     systemNavigationBarIconBrightness: Brightness.dark,
      //   ));
      //   runApp(MaterialApp(
      //     locale: locale,
      //     localizationsDelegates: [
      //       GlobalMaterialLocalizations.delegate,
      //       GlobalWidgetsLocalizations.delegate,
      //       GlobalCupertinoLocalizations.delegate,
      //     ],
      //     supportedLocales: [
      //       const Locale(''),
      //       const Locale('it'),
      //       const Locale('es'),
      //     ],
      //     home: AppShell(),
      //   ));
      // }

      savePreference('Language', selectedLanguage);
    } catch (e) {
      throw e;
    }
  }

  Future<void> onExportButtonClicked() async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      await Future.delayed(Duration.zero, () async {
        final internalDirectory = await getApplicationDocumentsDirectory();
        final internalFile = File('${internalDirectory.path}/database.db');
        // Call the method to export the database
        // DependencyService.get<IFileSystemService>().exportDb(internalFile.path);
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Info'),
              content: Text('Database export succeeded'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Attenzione'),
            content: Text('Insufficient permissions to access download folder'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScreen(
      selectedLanguage: selectedLanguage,
      onLanguageChanged: selezioneNazioneSelectedIndexChanged,
      switchVisualMessages: switchVisualMessages,
      onVisualMessagesChanged: (value) {
        setState(() {
          switchVisualMessages = value;
        });
        savePreference('VisualMessages', value);
      },
      switchAudioMessages: switchAudioMessages,
      onAudioMessagesChanged: (value) {
        setState(() {
          switchAudioMessages = value;
        });
        savePreference('AudioMessages', value);
      },
      switchTouchCommand: switchTouchCommand,
      onTouchCommandChanged: (value) {
        setState(() {
          switchTouchCommand = value;
        });
        savePreference('TouchCommand', value);
      },
      switchAudioCommand: switchAudioCommand,
      onAudioCommandChanged: (value) {
        setState(() {
          switchAudioCommand = value;
        });
        savePreference('AudioCommand', value);
      },
      switchPriorityPresident: switchPriorityPresident,
      onPriorityPresidentChanged: (value) {
        setState(() {
          switchPriorityPresident = value;
        });
        savePreference('PriorityPresident', value);
      },
      switchPriorityDisablePeople: switchPriorityDisablePeople,
      onPriorityDisablePeopleChanged: (value) {
        setState(() {
          switchPriorityDisablePeople = value;
        });
        savePreference('PriorityDisablePeople', value);
      },
      debugAlert: debugAlert,
      onDebugAlertChanged: (value) {
        setState(() {
          debugAlert = value;
        });
        savePreference('DevOptions', value);
      },
      onExportButtonClicked: onExportButtonClicked,
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;
  final bool switchVisualMessages;
  final ValueChanged<bool> onVisualMessagesChanged;
  final bool switchAudioMessages;
  final ValueChanged<bool> onAudioMessagesChanged;
  final bool switchTouchCommand;
  final ValueChanged<bool> onTouchCommandChanged;
  final bool switchAudioCommand;
  final ValueChanged<bool> onAudioCommandChanged;
  final bool switchPriorityPresident;
  final ValueChanged<bool> onPriorityPresidentChanged;
  final bool switchPriorityDisablePeople;
  final ValueChanged<bool> onPriorityDisablePeopleChanged;
  final bool debugAlert;
  final ValueChanged<bool> onDebugAlertChanged;
  final VoidCallback onExportButtonClicked;

  SettingsScreen({
    required this.selectedLanguage,
    required this.onLanguageChanged,
    required this.switchVisualMessages,
    required this.onVisualMessagesChanged,
    required this.switchAudioMessages,
    required this.onAudioMessagesChanged,
    required this.switchTouchCommand,
    required this.onTouchCommandChanged,
    required this.switchAudioCommand,
    required this.onAudioCommandChanged,
    required this.switchPriorityPresident,
    required this.onPriorityPresidentChanged,
    required this.switchPriorityDisablePeople,
    required this.onPriorityDisablePeopleChanged,
    required this.debugAlert,
    required this.onDebugAlertChanged,
    required this.onExportButtonClicked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Messages from Smartphone',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: Text('Visual')),
                    Switch(
                      value: switchVisualMessages,
                      onChanged: onVisualMessagesChanged,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Audio')),
                    Switch(
                      value: switchAudioMessages,
                      onChanged: onAudioMessagesChanged,
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Text(
                  'Command to Smartphone',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: Text('Screen Touch')),
                    Switch(
                      value: switchTouchCommand,
                      onChanged: onTouchCommandChanged,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Audio')),
                    Switch(
                      value: switchAudioCommand,
                      onChanged: onAudioCommandChanged,
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Text(
                  'Priority',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: Text('President')),
                    Switch(
                      value: switchPriorityPresident,
                      onChanged: onPriorityPresidentChanged,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text('Disable People')),
                    Switch(
                      value: switchPriorityDisablePeople,
                      onChanged: onPriorityDisablePeopleChanged,
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Text(
                  'Language',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: selectedLanguage,
                  onChanged: onLanguageChanged,
                  items: [
                    DropdownMenuItem<String>(
                      value: 'English',
                      child: Text('English'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Italiano',
                      child: Text('Italiano'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Spanish',
                      child: Text('Spanish'),
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                Text(
                  'Dev Opt',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: Text('Debug Alert')),
                    Switch(
                      value: debugAlert,
                      onChanged: onDebugAlertChanged,
                    ),
                  ],
                ),
                SizedBox(height: 32.0),
                ElevatedButton(
                  onPressed: onExportButtonClicked,
                  child: Text('Export Database'),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          FooterWidget(), // Add the FooterWidget here without any arguments
    );
  }
}
