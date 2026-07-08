import 'package:flutter/material.dart';
import 'package:connect/features/startups/screens/startup_dashboard_screen.dart';
import 'package:connect/features/startups/screens/post_opportunity_screen.dart';

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
      home: PostOpportunityScreen(),
    );
  }
}
