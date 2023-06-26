import 'package:sofia/models/User.dart';
import 'package:sofia/interfaces/i_auth_service.dart';
import 'package:sofia/models/User.dart';

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
    await Future.delayed(Duration(
        seconds: 2)); // Simulating a delay for the authentication process

    if (password == 'President') {
      return true;
    } else if (password == 'People') {
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
