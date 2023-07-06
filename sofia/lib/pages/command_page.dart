import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sofia/logic/controller/command_controller.dart';
import 'package:sofia/widgets/custom_drawer.dart';

class CommandPage extends StatelessWidget {
  CommandPage({Key? key}) : super(key: key);
  final CommandController commandController = Get.put(CommandController());

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
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 8),
         child: Column(
                
                children: [
                  commandController.isConnected
                      ? Text(
                          'Hello ${commandController.coreController.loggerUser?.username} Happy to see you again.\n Same destination ?',
                          style: TextStyle(fontSize: 18),
                        )
                      : Text(
                          'Elevator is Not Connected.',
                          style: TextStyle(fontSize: 18),
                        ),
                 
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: TextEditingController(
                                text: '1'), // Set the default value here
                            decoration: InputDecoration(
                              labelText: 'From',
                            ),
                            enabled:
                                false, // Set enabled to false to make it non-editable
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: commandController.toController,
                            decoration: InputDecoration(
                              labelText: 'To',
                            ),
                            enabled:
                                commandController.isConnected, // Set enabled to your desired condition
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: commandController.isConnected ? () => commandController : null,
                    child: Text('Confirm'),
                  ),
                ],
              ),
      ),
    );
  }
}
