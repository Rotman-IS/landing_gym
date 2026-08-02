import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/landing_screen.dart';

void main() {
  runApp(const LandingGymApp());
}

class LandingGymApp extends StatelessWidget {
  const LandingGymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iron Gym',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LandingScreen(),
    );
  }
}
