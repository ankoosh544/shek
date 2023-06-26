import 'package:flutter/material.dart';
import 'package:sofia/constants/constants.dart';
import 'package:get/get.dart';
import 'package:sofia/logic/controller/login_controller.dart';
import 'package:sofia/pages/password/forgot_password_page.dart';
// import 'package:waiter_app/views/pages/password/forgot_password_page.dart';

import 'package:sofia/widgets/loader.dart';

class LogInPage extends StatelessWidget {
  LogInPage({Key? key}) : super(key: key);
  final LoginController loginController = Get.put(LoginController());

  static bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        height: 100,
                        width: 320,
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.r(10),
                          image: DecorationImage(
                            image: AssetImage(Images.appLogo),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    const Text(
                      "Welcome to  Sofia",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    const Text(
                      "Login to Continue",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Form(
                      // key: loginController.loginFormKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "Username",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              Text(
                                "*",
                                style: TextStyle(color: AppColor.primaryColor),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            height: 68,
                            child: TextFormField(
                              controller: loginController.usernameController,
                              textInputAction: TextInputAction.done,
                              onSaved: (value) {
                                loginController.username = value!;
                              },
                              validator: (value) {
                                if (loginController
                                    .usernameController.text.isEmpty) {
                                  return "This field can't be empty";
                                } else {
                                  return loginController
                                      .validateUsername(value!);
                                }
                              },
                              keyboardType: TextInputType.text,
                              cursorColor: AppColor.primaryColor,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  top: 0,
                                  left: 15,
                                ),
                                fillColor: const Color(0xffF2CDD4),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: Color(0xffF2CDD4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: const [
                              Text(
                                "Password",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              Text(
                                "*",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 31, 74, 27)),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          SizedBox(
                            height: 68,
                            child: TextFormField(
                              controller: loginController.passwordController,
                              textInputAction: TextInputAction.done,
                              obscureText: _isObscure,
                              onSaved: (value) {
                                loginController.password = value!;
                              },
                              validator: (value) {
                                if (loginController
                                    .passwordController.text.isEmpty) {
                                  return "This field can't be empty";
                                } else {
                                  return loginController
                                      .validatePassword(value!);
                                }
                              },
                              keyboardType: TextInputType.text,
                              cursorColor: AppColor.primaryColor,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  top: 0,
                                  left: 15,
                                ),
                                suffixIcon: IconButton(
                                  color: AppColor.secoundaryColor,
                                  icon: Icon(_isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    _isObscure = !_isObscure;
                                    (context as Element).markNeedsBuild();
                                  },
                                ),
                                fillColor: const Color(0xffF2CDD4),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.secoundaryColor,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: AppColor.primaryColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                  borderSide: const BorderSide(
                                    width: 1,
                                    color: Color(0xffF2CDD4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.secoundaryColor, // background
                          onPrimary: Colors.white, // foreground
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // <-- Radius
                          ),
                        ),
                        onPressed: () {
                          loginController.doLogin();
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    TextButton(
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColor.primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => const ForgotPasswordPage());
                      },
                    ),
                    GetBuilder<LoginController>(
                      init: loginController,
                      builder: (loader) {
                        return loader.isLoading
                            ? Container(
                                height: ScreenSize(context).mainHeight,
                                width: ScreenSize(context).mainWidth,
                                color: Colors.white60,
                                child: const Center(child: Loader()))
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
