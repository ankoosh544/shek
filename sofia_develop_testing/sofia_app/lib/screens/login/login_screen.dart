import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/providers/login_provider.dart';
import 'package:sofia_app/screens/registration/registration_screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Login Screen'),
        ),
        body: Consumer<LoginProvider>(
          builder: (context, loginProvider, _) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                    ),
                    onChanged: (value) {
                      loginProvider.setUsername(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    onChanged: (value) {
                      loginProvider.setPassword(value);
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: loginProvider.rememberMe,
                        onChanged: (value) {
                          loginProvider.toggleRememberMe(value!);
                        },
                      ),
                      Text('Remember me'),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          loginProvider.forgotPassword();
                        },
                        child: Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      loginProvider.login();
                    },
                    child: Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegistrationScreen(),
                        ),
                      );
                    },
                    child: Text('New User? Register Here'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
