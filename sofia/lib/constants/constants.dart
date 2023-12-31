import 'package:flutter/cupertino.dart';

class AppColor {
  static const Color primaryColor = Color(0xffEE1D48);
  static const Color secoundaryColor = Color.fromRGBO(36, 29, 238, 1);
}

class Images {
  static String get appLogo => 'assets/images/app_logo.png';
  static String get splashLogo => 'assets/images/splash_logo.png';
  static String get food => 'assets/images/food.png';
  static String get food1 => 'assets/images/food1.png';
  static String get profile => 'assets/images/profile.png';
  static String get profile2 => 'assets/images/profile2.png';
  static String get editPic => 'assets/images/editPic.png';
}

class ScreenSize {
  BuildContext context;
  ScreenSize(this.context);
  double get mainHeight => MediaQuery.of(context).size.height;
  double get mainWidth => MediaQuery.of(context).size.width;
  double get block => mainWidth / 100;
}
