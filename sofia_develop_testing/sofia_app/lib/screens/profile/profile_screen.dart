import 'package:flutter/material.dart';

import '../../configs/index.dart';
import '../../widgets/index.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: SofiaAppBar(
        title: tabProfile,
      ),
      body: Text('Profile'),
    );
  }
}
