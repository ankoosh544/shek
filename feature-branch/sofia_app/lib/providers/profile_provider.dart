import 'package:flutter/material.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/models/user.dart';
import 'package:sofia_app/providers/auth_provider.dart';

class ProfileProvider extends ChangeNotifier {
  User? user;
  UserDao _userDao;
  AuthProvider _authProvider;
  bool _isDataLoaded = false;

  ProfileProvider(this._userDao, this._authProvider) {
    loadUserData();
  }

  bool get isDataLoaded => _isDataLoaded;

  Future<void> loadUserData() async {
    final loggedUsername = _authProvider.loggedInUsername;

    if (loggedUsername != null) {
      user = await _userDao.getUserByUsername(loggedUsername);
      print("*****************===Profile=====$user");
    }

    _isDataLoaded = true;
    notifyListeners();
  }
}
