import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sofia/constants/constants.dart';
import 'package:sofia/logic/controller/otp_controller.dart';

import 'package:sofia/widgets/loader.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final TextEditingController emailController;
  OtpController otpController = Get.put(OtpController());
  bool _isButtonActive = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = OtpController().emailController;
    emailController.addListener(() {
      final _isButtonActive = emailController.text.isNotEmpty;
      setState(() {
        this._isButtonActive = _isButtonActive;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

//Email pattern input validation
  String? validateEmail(String? value) {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Enter a valid email address';
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Forgot  password',
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
                        "Enter the email address associated with your",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff706881),
                        ),
                      ),
                      const Text(
                        "account",
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
                            "Email",
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
                          controller: emailController,
                          textInputAction: TextInputAction.done,
                          validator: (value) => validateEmail(value),
                          keyboardType: TextInputType.emailAddress,
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
                              //emailController.clear();
                            });
                            if (_formKey.currentState!.validate()) {
                              otpController
                                  .sendOTP(emailController.text.trim());
                            }
                          }
                        : null,
                    child: const Text(
                      'Get code',
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
