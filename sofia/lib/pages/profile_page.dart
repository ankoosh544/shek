import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sofia/constants/constants.dart';

import 'package:get/get.dart';
import 'package:sofia/widgets/custom_drawer.dart';
import 'package:sofia/storage/user_secure_storage.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);
  final String password = '******';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      drawer: CustomDrawer(
        indexClicked: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40),
        child: SizedBox(
          height: ScreenSize(context).mainHeight / 2.2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        width: 80,
                        height: 60,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 1),
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(Images.appLogo),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    '',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xff160040),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Phone',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff706881),
                ),
              ),
              Text(
                UserSecureStorage.getUsername().toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff160040),
                ),
              ),
              const Text(
                'Username',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff706881),
                ),
              ),
              Text(
                UserSecureStorage.getEmail().toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff160040),
                ),
              ),
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xff706881),
                ),
              ),
              Text(
                password,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff160040),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 42,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    primary: Colors.grey,
                    onSurface: AppColor.secoundaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to the Edit Profile page
                    // Get.to(() => UpdateProfilePage(
                    //   name: 'profileController.name',
                    //   phone: 'profileController.phone',
                    //   email: 'profileController.email',
                    // ));
                  },
                  child: const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
