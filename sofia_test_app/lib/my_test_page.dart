import 'package:flutter/material.dart';
import 'package:sofia_test_app/footer.dart';

class MyTestPage extends StatelessWidget {
  const MyTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MY Page"),
      ),
      bottomNavigationBar: FooterWidget(),
    );
  }
}
