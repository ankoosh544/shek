import 'package:flutter/material.dart';
import 'package:sofia/constants/constants.dart';
// import 'package:sofia/logic/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:sofia/logic/controller/auth_controller.dart';
import 'package:sofia/logic/controller/login_controller.dart';
import 'package:sofia/pages/command_page.dart';
import 'package:sofia/pages/profile_page.dart';
//import 'package:sofia/logic/controller/profile_controller.dart';
// import 'package:waiter_app/views/pages/order/order_history_page.dart';
// import 'package:waiter_app/views/pages/order/take_order_page.dart';
// import 'package:waiter_app/views/pages/profile/profile_page.dart';

// ignore: must_be_immutable
class CustomDrawer extends GetView {
  int indexClicked;
  CustomDrawer({Key? key, required this.indexClicked}) : super(key: key);
  final authController = Get.put(AuthController());
  // final loginController = Get.put(LoginController());
  // final profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: 80,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1),
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage(Images.appLogo),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                SizedBox(
                  width: ScreenSize(context).mainWidth / 2.5,
                  child: Text(
                    "Ankoosh",
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 3,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(
            icon: Icons.home,
            text: 'Home',
            indexNumber: 1,
            onTap: () {
              Get.off(() => CommandPage());
              indexClicked = 1;
              (context as Element).markNeedsBuild();
            },
          ),
          _drawerItem(
            icon: Icons.account_circle_outlined,
            text: 'Profile',
            indexNumber: 2,
            onTap: () {
              Get.off(() => ProfilePage());
              indexClicked = 2;
              (context as Element).markNeedsBuild();
            },
          ),
          _drawerItem(
            icon: Icons.settings,
            text: 'Settings',
            indexNumber: 3,
            onTap: () {
              indexClicked = 3;
              //  Get.off(() => SettingsPage());
              (context as Element).markNeedsBuild();
            },
          ),
          _drawerItem(
            icon: Icons.contact_emergency,
            text: 'Emergency Contacts',
            indexNumber: 4,
            onTap: () {
              indexClicked = 4;
              //     Get.off(() => EmergencyContactsPage());
              (context as Element).markNeedsBuild();
            },
          ),
          _drawerItem(
            icon: Icons.logout,
            text: 'Log out',
            indexNumber: 5,
            onTap: () {
              authController.doLogout();
              (context as Element).markNeedsBuild();
            },
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
      {required IconData icon,
      required String text,
      required int indexNumber,
      required GestureTapCallback onTap}) {
    return ListTile(
      selected: indexClicked == indexNumber,
      selectedTileColor: AppColor.secoundaryColor,
      title: Row(
        children: [
          Icon(
            icon,
            color: indexClicked == indexNumber
                ? Colors.white
                : AppColor.secoundaryColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: indexClicked == indexNumber
                    ? Colors.grey
                    : AppColor.secoundaryColor,
              ),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
