import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyToken = 'token';
  static const _keyEmail = 'email';
  static const _keyPassword = 'password';
  static const _keyUsername = 'username';
  static const _keyRememberMe = 'rememberMe';
  static const _keyTableID = 'tableID';
  static const _keyWaiter = 'waiterID';
  static const _keyRestaurantId = 'restaurantId';
  static const _keyMenuItems = 'menuItems';
  static const _keyProfile = 'profile';

  //Token
  // static Future setToken(String token) async =>
  //     await _storage.write(key: _keyToken, value: token);

  // static Future<String?> getToken() async {
  //   var token = await _storage.read(key: _keyToken);
  //   return token;
  // }

  //setWaiterID
  // static Future setWaiterID(String token) async =>
  //     await _storage.write(key: _keyWaiter, value: token);

  // static Future<String?> getWaiterID() async {
  //   var waiterID = await _storage.read(key: _keyWaiter);
  //   return waiterID;
  // }

  //setRestaurantId
  // static Future setRestaurantId(String token) async =>
  //     await _storage.write(key: _keyRestaurantId, value: token);

  // static Future<String?> getRestaurantId() async {
  //   var restaurantId = await _storage.read(key: _keyRestaurantId);
  //   return restaurantId;
  // }

//Email
  static Future setEmail(String email) async =>
      await _storage.write(key: _keyEmail, value: email);

  static Future<String?> getEmail() async =>
      await _storage.read(key: _keyEmail);

//Username
  static Future setUsername(String username) async =>
      await _storage.write(key: _keyUsername, value: username);

  static Future<String?> getUsername() async =>
      await _storage.read(key: _keyUsername);

  static Future setRememberMe(String rememberMe) async =>
      await _storage.write(key: _keyRememberMe, value: rememberMe);

  static Future<String?> getRememberMe() async =>
      await _storage.read(key: _keyRememberMe);

  //Password
  static Future setPassword(String password) async =>
      await _storage.write(key: _keyPassword, value: password);

  static Future<String?> getPassword() async =>
      await _storage.read(key: _keyPassword);

  static Future<String?> getTableID() async =>
      await _storage.read(key: _keyTableID);

  static Future<void> setTableID(tableID) async =>
      await _storage.write(key: _keyTableID, value: tableID.toString());

  static Future<String?> getProfile() async =>
      await _storage.read(key: _keyProfile);

  static Future<void> setProfile(profile) async =>
      await _storage.write(key: _keyProfile, value: profile.toString());

  //menu storage
  static Future setMenuItem(menuItems) async {
    var tableID = await _storage.read(key: _keyTableID);
    return await _storage.write(
        key: _keyMenuItems + tableID!, value: jsonEncode(menuItems));
  }

  static Future<String?> getMenuItem() async {
    var tableID = await _storage.read(key: _keyTableID);
    if (tableID != null) {
      return await _storage.read(key: _keyMenuItems + tableID);
    } else {
      return null;
    }
  }

  static Future<void> deleteMenu() async {
    var tableID = await _storage.read(key: _keyTableID);
    await _storage.delete(key: _keyMenuItems + tableID!);
  }

  static Future setMenu(menuItems) async {
    return await _storage.write(key: 'menu', value: jsonEncode(menuItems));
  }

  static Future<String?> getMenu() async {
    return await _storage.read(key: 'menu');
  }
}
