import 'package:flutter/material.dart';

import 'package:sofia_app/databases/database.dart';
import 'package:sofia_app/models/user.dart';

class RegistrationProvider with ChangeNotifier {
  String _email = '';
  String _username = '';
  String _password = '';

  String get emailError => _validateEmail(_email);
  String get usernameError => _validateUsername(_username);
  String get passwordError => _validatePassword(_password);

  void setEmail(String email) {
    _email = email;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<void> registerUser(BuildContext context) async {
    print("==============$context");
    // Validate user input
    if (emailError.isNotEmpty ||
        usernameError.isNotEmpty ||
        passwordError.isNotEmpty) {
      return;
    }

    // Create User object
    final user = User(null, _email, _username, _password);

    // Get the AppDatabase instance
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    // Get the UserDao instance
    final userDao = database.userDao;

    // Insert the user into the database
    await userDao.insertUser(user);

    final allUsers = await userDao.getAllUsers;
    print(allUsers);

    // Close the database
    await database.close();

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registration Successful'),
        content: Text('Your registration was successful.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Navigate to the login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (route) => false,
              );
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  String _validateEmail(String value) {
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!_isValidEmail(value)) {
      return 'Invalid email format';
    }
    return '';
  }

  String _validateUsername(String value) {
    if (value.isEmpty) {
      return 'Username is required';
    }
    return '';
  }

  String _validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }
    return '';
  }

  bool _isValidEmail(String email) {
    final emailRegex = r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$';
    final regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }
}
