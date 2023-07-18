import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sofia_app/databases/database.dart';

import 'package:sofia_app/providers/auth_provider.dart';

class LoginProvider with ChangeNotifier {
  String username = '';
  String password = '';
  bool rememberMe = false;

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<void> login(BuildContext context) async {
    // Perform login logic here
    // Get the AppDatabase instance
    final database =
        await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    // Get the UserDao instance
    final userDao = database.userDao;
    // Fetch the user from the database based on the username
    final user = await userDao.getUserByUsername(username);
    if (user != null && user.password == password) {
      Provider.of<AuthProvider>(context, listen: false)
          .login(username, password);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Failed login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Invalid username or password.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }

    // Close the database
    await database.close();
  }

  void forgotPassword() {
    // Perform forgot password logic here
  }

  void registerUser() {
    // Perform user registration logic here
  }
}
