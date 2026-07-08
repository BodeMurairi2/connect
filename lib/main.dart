import 'package:flutter/material.dart';
import 'package:connect/features/auth/screens/register_screen.dart';
import 'package:connect/features/student/screens/student_onboarding_screen.dart';
import 'package:connect/features/startups/screens/startup_onboarding_screen.dart';
import 'package:connect/features/onboarding/screens/role_selection_screen.dart';

void main() {
  runApp(const AnzaConnect());
}

class AnzaConnect extends StatelessWidget {
  const AnzaConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Colors.white),
      home: RoleSelectionScreen(),
    );
  }
}
