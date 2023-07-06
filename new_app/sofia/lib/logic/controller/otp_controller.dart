import 'package:email_auth/email_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:sofia/services/otp_service.dart';
import 'package:sofia/pages/login_page.dart';
import 'package:sofia/pages/password/reset_password_page.dart';
import 'package:sofia/pages/password/verify_email_page.dart';

class OtpController extends GetxController {
  late EmailAuth emailAuth;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  // send otp
  void sendOTP(email) async {
    isLoading = true;
    update();
    var otp = await OtpService.otpSend(email: email);
    if (otp != null) {
      // Check if OTP is not null
      isLoading = false;
      update();
      Get.off(() => VerifyEmailPage(email: email));
    } else {
      isLoading = false;
      update();
    }
  }

  // validate otp
  void verifyOTP(otpCode, email) async {
    isLoading = true;
    update();
    var otp = await OtpService.otpVerify(
        otp: otpCode, enteredOtp: otpCode); // Provide enteredOtp argument
    if (otp) {
      isLoading = false;
      update();
      Get.off(() => ResetPasswordPage(email: email));
    } else {
      isLoading = false;
      update();
    }
  }

  void resetPassword(email, password) async {
    isLoading = true;
    update();
    var reset =
        await OtpService.resetPassword(email: email, password: password);
    if (reset) {
      isLoading = false;
      update();
      Get.off(() => LogInPage());
    } else {
      isLoading = false;
      update();
    }
  }
}
