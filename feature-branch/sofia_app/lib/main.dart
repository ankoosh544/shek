// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/databases/database.dart';
import 'package:sofia_app/providers/ble_provider.dart';

import 'package:sofia_app/screens/registration/registration_screen.dart';
import 'package:sofia_app/providers/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';

void main() async {
  if (Platform.isAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    await [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request();
  }

  final database =
      await $FloorAppDatabase.databaseBuilder('database.db').build();
  final userDao = database.userDao;

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<UserDao>.value(value: userDao),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const SofiaApp(),
    ),
  );
}

class SofiaApp extends StatefulWidget {
  const SofiaApp({Key? key}) : super(key: key);

  @override
  State<SofiaApp> createState() => _SofiaAppState();
  static void setLocale(BuildContext context, Locale newLocale) {
    _SofiaAppState? state = context.findAncestorStateOfType<_SofiaAppState>();
    state?.setLocale(newLocale);
  }
}

class _SofiaAppState extends State<SofiaApp> {
  Locale? _locale;

  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('it'), // Italian
        Locale('es'), // Spanish
      ],
      locale: _locale,
      routes: {
        // '/': (context) => Consumer2<UserDao, AuthProvider>(
        //   builder: (context, userDao, authProvider, _) => ChangeNotifierProvider(
        //     create: (_) => BleProvider()
        //       ..initialScan()
        //       ..periodicScan(),
        //     child: LoginScreen(userDao: userDao, authProvider: authProvider),
        //   ),
        // ),
        '/': (context) => Consumer2<UserDao, AuthProvider>(
              builder: (context, userDao, authProvider, _) =>
                  LoginScreen(userDao: userDao, authProvider: authProvider),
            ),
        '/register': (context) => Consumer<UserDao>(
              builder: (context, userDao, _) =>
                  RegistrationScreen(userDao: userDao),
            ),
        // '/home': (context) => Consumer2<UserDao, AuthProvider>(
        //   builder: (context, userDao, authProvider, _) => ChangeNotifierProvider(
        //     create: (_) => BleProvider()
        //       ..initialScan()
        //       ..periodicScan(),
        //     child: HomeScreen(userDao: userDao, authProvider: authProvider),
        //   ),
        // ),
        '/home': (context) => ChangeNotifierProvider(
              create: (_) => BleProvider()
                ..initialScan()
                ..periodicScan(),
              child: Consumer2<UserDao, AuthProvider>(
                builder: (context, userDao, authProvider, _) =>
                    HomeScreen(userDao: userDao, authProvider: authProvider),
              ),
            )
      },
    );
  }
}
