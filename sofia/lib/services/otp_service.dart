import 'dart:convert';
import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';

class OtpService {
  static otpSend({required email}) {
    // Generate a random 4-digit OTP
    var otp = generateOtp();

    Fluttertoast.showToast(
      msg: 'OTP sent: $otp', // Display the generated OTP
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP_RIGHT,
    );

    return otp;
  }

  static otpVerify({required otp, required String enteredOtp}) {
    if (otp == enteredOtp) {
      Fluttertoast.showToast(
        msg: 'OTP verification successful',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
      );
      return true;
    } else {
      Fluttertoast.showToast(
        msg: 'OTP verification failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP_RIGHT,
      );
      return false;
    }
  }

  static resetPassword({required email, required password}) {
    // Reset password logic here

    Fluttertoast.showToast(
      msg: 'Password reset successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP_RIGHT,
    );
    return true;
  }

  static String generateOtp() {
    // Generate a random 4-digit OTP
    var otp = '';
    var random = Random();
    for (var i = 0; i < 4; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }
}
