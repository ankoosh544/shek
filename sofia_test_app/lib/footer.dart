// import 'package:flutter/material.dart';

// class FooterWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.grey[200],
//       padding: const EdgeInsets.symmetric(vertical: 10.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           FooterLink(
//             title: 'Home',
//             onPressed: () {
//               // Navigate to the homepage
//               // Replace `HomePage` with your actual homepage route
//               Navigator.pushNamed(context, '/home');
//             },
//           ),
//           FooterLink(
//             title: 'Test',
//             onPressed: () {
//               // Navigate to the default page
//               // Replace `DefaultPage` with your actual default page route
//               Navigator.pushNamed(context, '/test');
//             },
//           ),
//           FooterLink(
//             title: 'Profile',
//             onPressed: () {
//               // Navigate to the profile page
//               // Replace `ProfilePage` with your actual profile page route
//               Navigator.pushNamed(context, '/profile');
//             },
//           ),
//           FooterLink(
//             title: 'Settings',
//             onPressed: () {
//               // Navigate to the setting page
//               // Replace `SettingPage` with your actual setting page route
//               Navigator.pushNamed(context, '/settings');
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }

// class FooterLink extends StatelessWidget {
//   final String title;
//   final VoidCallback onPressed;

//   const FooterLink({
//     required this.title,
//     required this.onPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: 16.0,
//           color: Colors.blue,
//           decoration: TextDecoration.underline,
//         ),
//       ),
//     );
//   }
// }
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
          FooterButton(
            title: 'Home',
            icon: Icons.home,
            onPressed: () {
              // Navigate to the homepage
              // Replace `HomePage` with your actual homepage route
              Navigator.pushNamed(context, '/home');
            },
          ),
          FooterButton(
            title: 'Profile',
            icon: Icons.person,
            onPressed: () {
              // Navigate to the profile page
              // Replace `ProfilePage` with your actual profile page route
              Navigator.pushNamed(context, '/profile');
            },
          ),
          FooterButton(
            title: 'Settings',
            icon: Icons.settings,
            onPressed: () {
              // Navigate to the settings page
              // Replace `SettingsPage` with your actual settings page route
              Navigator.pushNamed(context, '/settings');
            },
          ),
          FooterButton(
            title: 'Test',
            icon: Icons.code,
            onPressed: () {
              // Navigate to the test page
              // Replace `TestPage` with your actual test page route
              Navigator.pushNamed(context, '/test');
            },
          ),
        ],
      ),
    );
  }
}

class FooterButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const FooterButton({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.blue,
          ),
          SizedBox(height: 4.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
