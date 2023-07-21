import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sofia_app/dao/user_dao.dart';
import 'package:sofia_app/providers/registration_provider.dart';

class RegistrationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistrationProvider(Provider.of<UserDao>(context, listen: false)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Registration Screen'),
        ),
        body: Consumer<RegistrationProvider>(
          builder: (context, registrationProvider, _) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: registrationProvider.emailError,
                    ),
                    onChanged: (value) {
                      registrationProvider.setEmail(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: registrationProvider.usernameError,
                    ),
                    onChanged: (value) {
                      registrationProvider.setUsername(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: registrationProvider.passwordError,
                    ),
                    onChanged: (value) {
                      registrationProvider.setPassword(value);
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => registrationProvider.registerUser(context),
                    child: Text('Register'),
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