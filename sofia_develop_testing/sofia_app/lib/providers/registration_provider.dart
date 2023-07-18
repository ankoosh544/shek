import 'package:flutter/material.dart';

import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/models/user.dart';

class RegistrationProvider with ChangeNotifier {
  final UserDao _userDao;

  RegistrationProvider(this._userDao);

  String email = '';
  String username = '';
  String password = '';

  String emailError = '';
  String usernameError = '';
  String passwordError = '';

  void setEmail(String value) {
    email = value.trim();
    validateEmail();
  }

  void setUsername(String value) {
    username = value.trim();
    validateUsername();
  }

  void setPassword(String value) {
    password = value.trim();
    validatePassword();
  }

  void validateEmail() {
    // Validation logic for email
  }

  void validateUsername() {
    // Validation logic for username
  }

  void validatePassword() {
    // Validation logic for password
  }

  Future<void> registerUser(BuildContext context) async {
    validateEmail();
    validateUsername();
    validatePassword();

    if (emailError == null && usernameError == null && passwordError == null) {
      final user = User(0, email, username, password);
      await _userDao.registerUser(user);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Success'),
          content: Text('User registered successfully'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
