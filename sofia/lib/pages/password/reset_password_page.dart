// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:sofia/constants/constants.dart';
import 'package:sofia/logic/controller/otp_controller.dart';
import 'package:get/get.dart';

import 'package:sofia/widgets/loader.dart';

class ResetPasswordPage extends StatefulWidget {
  String email;
  ResetPasswordPage({Key? key, required this.email}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final TextEditingController passwordController;
  OtpController otpController = Get.put(OtpController());

  bool _isButtonActive = false;
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    passwordController.addListener(() {
      final _isButtonActive = passwordController.text.isNotEmpty;
      setState(() {
        this._isButtonActive = _isButtonActive;
      });
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Reset  password',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColor.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 18,
                      ),
                      const Text(
                        "Set the new password for your account so you can",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff706881),
                        ),
                      ),
                      const Text(
                        "login and access all the features.",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff706881),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: const [
                          Text(
                            "New password",
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
                          controller: passwordController,
                          textInputAction: TextInputAction.done,
                          obscureText: _isObscure,
                          validator: (value) {},
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: AppColor.primaryColor,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(
                              top: 0,
                              left: 15,
                            ),
                            suffixIcon: IconButton(
                              color: AppColor.primaryColor,
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
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: AppColor.primaryColor,
                      onSurface: AppColor.primaryColor, // background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // <-- Radius
                      ),
                    ),
                    onPressed: _isButtonActive
                        ? () {
                            setState(() {
                              _isButtonActive = false;
                            });
                            if (_formKey.currentState!.validate()) {
                              otpController.resetPassword(
                                  widget.email, passwordController.text.trim());
                            } else {}
                          }
                        : null,
                    child: const Text(
                      'Reset password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    GetBuilder<OtpController>(
                      init: otpController,
                      builder: (loader) {
                        return loader.isLoading
                            ? Positioned(
                                child: Container(
                                    height: ScreenSize(context).mainHeight,
                                    width: ScreenSize(context).mainWidth,
                                    color: Colors.white60,
                                    child: const Center(child: Loader())),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
