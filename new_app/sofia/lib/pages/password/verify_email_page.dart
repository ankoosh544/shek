// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sofia/constants/constants.dart';
import 'package:sofia/logic/controller/otp_controller.dart';
import 'package:get/get.dart';
import 'package:sofia/widgets/loader.dart';

class VerifyEmailPage extends StatefulWidget {
  String email;
  VerifyEmailPage({Key? key, required this.email}) : super(key: key);

  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late final TextEditingController codeController;
  OtpController otpController = Get.put(OtpController());
  bool _isButtonActive = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    codeController = OtpController().codeController;
    codeController.addListener(() {
      final _isButtonActive = codeController.text.isNotEmpty;
      setState(() {
        this._isButtonActive = _isButtonActive;
      });
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  //OTP pattern input validation
  String? validateOTP(String? value) {
    String pattern = "[0-9]";

    RegExp regex = RegExp(pattern);
    if (value == null || value.isEmpty || !regex.hasMatch(value)) {
      return 'Enter digit only';
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
            'Verify  email',
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
                        "A text massage with a 6-digit verification code was",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xff706881),
                        ),
                      ),
                      const Text(
                        "just sent to your email.",
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
                            "Enter code",
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
                          controller: codeController,
                          textInputAction: TextInputAction.done,
                          validator: (value) => validateOTP(value),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          keyboardType: TextInputType.number,
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
                        height: 12,
                      ),
                      SizedBox(
                        height: 35,
                        width: 120,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: .8,
                            primary: const Color(0xffFFECEF),
                            onPrimary: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(5), // <-- Radius
                            ),
                          ),
                          child: const Text(
                            'Resend code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          onPressed: () {
                            otpController.sendOTP(widget.email);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 24,
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
                              //codeController.clear();
                            });
                            if (_formKey.currentState!.validate()) {
                              otpController.verifyOTP(
                                  codeController.text.trim(), widget.email);
                            } else {}
                          }
                        : null,
                    child: const Text(
                      'Verify',
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
