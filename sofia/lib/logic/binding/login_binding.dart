import 'package:get/get.dart';
import 'package:sofia/logic/controller/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    //Get.put(AuthController());
  }
}
