import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sofia/logic/controller/command_controller.dart';
import 'package:sofia/widgets/custom_drawer.dart';

class CommandPage extends StatelessWidget {
  CommandPage({Key? key}) : super(key: key);
  final CommandController loginController = Get.put(CommandController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      drawer: CustomDrawer(
        indexClicked: 1,
      ),
      body: const Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }
}
