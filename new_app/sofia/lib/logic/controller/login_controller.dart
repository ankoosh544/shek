import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sofia/pages/command_page.dart';
import 'package:sofia/pages/home_page.dart';
import 'package:sofia/services/auth_service.dart';

import 'package:sofia/storage/user_secure_storage.dart';

class LoginController extends GetxController {
  bool isLoading = false;
  final loginFormKey = GlobalKey<FormState>();
  late TextEditingController usernameController, passwordController;

  String username = '', password = '';
  bool rememberPassword = false;


  @override
  void onInit() {
    usernameController =
        TextEditingController(); // Initialize usernameController
    passwordController = TextEditingController();
    init();
    super.onInit();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future init() async {
    usernameController.text = username;
  }

  String? validateEmail(String value) {
    if (!GetUtils.isEmail(value)) {
      return "Email Incorrect! Try Again...";
    } else {
      return null;
    }
  }

  String? validateUsername(String value) {
    if (!GetUtils.isUsername(value)) {
      return "UserName is Incorrect! Try Again...";
    } else {
      return null;
    }
  }

  String? validatePassword(String value) {
    if (value.length <= 2) {
      return "Password Incorrect! Try Again...";
    } else {
      return null;
    }
  }

  doLogin() async {
    bool isValidate = loginFormKey.currentState?.validate() ?? true;
    if (isValidate) {
      isLoading = true;
      update();
      try {
        AuthService authService = AuthService();
        var data = await authService.loginAsync(
            usernameController.text, passwordController.text);
        print("======================================$data");
        if (data != null && rememberPassword) {
          UserSecureStorage.setRememberMe(passwordController.text);
        }

        if (data != null) {
          isLoading = false;
          UserSecureStorage.setUsername(usernameController.text);
          UserSecureStorage.setPassword(passwordController.text);

          loginFormKey.currentState?.save();
          update();
          Get.off(() => HomePage());
        } else {
          isLoading = false;
          update();
        }
      } finally {
        isLoading = false;
      }
    }
  }
}
