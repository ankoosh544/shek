import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sofia_test_app/footer.dart';
import 'package:sofia_test_app/interfaces/i_auth_service.dart';
import 'package:sofia_test_app/login_page.dart';
import 'package:sofia_test_app/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authService = GetIt.instance.get<IAuthService>();

  String? username = '';

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    User user = await authService.detailsAsync();
    setState(() {
      username = user.username;
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('PasswordUtente', '');
    await authService.logoutAsync();
    // Navigate to the LoginPage
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }


 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Profile'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Username: $username',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: logout,
            child: Text('Logout'),
          ),
        ],
      ),
    ),
    bottomNavigationBar: FooterWidget(), // Add the FooterWidget here without any arguments
  );
}

}
