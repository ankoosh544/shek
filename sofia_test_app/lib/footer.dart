import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          FooterLink(
            title: 'Home',
            onPressed: () {
              // Navigate to the homepage
              // Replace `HomePage` with your actual homepage route
              Navigator.pushNamed(context, '/home');
            },
          ),
          FooterLink(
            title: 'Test',
            onPressed: () {
              // Navigate to the default page
              // Replace `DefaultPage` with your actual default page route
              Navigator.pushNamed(context, '/test');
            },
          ),
          FooterLink(
            title: 'Profile',
            onPressed: () {
              // Navigate to the profile page
              // Replace `ProfilePage` with your actual profile page route
              Navigator.pushNamed(context, '/profile');
            },
          ),
          FooterLink(
            title: 'Settings',
            onPressed: () {
              // Navigate to the setting page
              // Replace `SettingPage` with your actual setting page route
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}

class FooterLink extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const FooterLink({
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
