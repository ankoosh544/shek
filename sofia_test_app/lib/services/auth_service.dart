

import 'package:sofia_test_app/interfaces/i_auth_service.dart';
import 'package:sofia_test_app/models/user.dart';

class AuthService implements IAuthService {
  String? username;
  String? password;
  bool isPresident = false;
  bool isDisablePeople = false;

  @override
  Future<User> detailsAsync() async {
    var user = User(
      username: username,
      lastName: 'Rossi',
      firstName: 'Mario',
      isPresident: isPresident,
      isDisablePeople: isDisablePeople,
    );

    return user;
  }

  @override
  Future<bool> isLoggedAsync() async {
    return username?.isEmpty == false && username == password;
  }

  @override
  Future<bool> loginAsync(String username, String password) async {
    this.username = username;
    this.password = password;
    isPresident = false;
    isDisablePeople = false;

    if (password == 'President') {
      isPresident = true;
      return true;
    } else if (password == 'People') {
      isDisablePeople = true;
      return true;
    }

    bool isValid = username == password;
    return isValid;
  }

  @override
  Future<bool> logoutAsync() async {
    username = null;
    password = null;
    isPresident = false;
    isDisablePeople = false;
    return true;
  }
}
