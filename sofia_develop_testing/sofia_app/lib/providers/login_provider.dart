import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  void login() {
    // Perform login logic here
  }

  void forgotPassword() {
    // Perform forgot password logic here
  }

  void registerUser() {
    print("Coming to Provider");
    // Perform user registration logic here
  }
}