import 'package:flutter/material.dart';
import 'package:connect/features/startups/screens/applicants_screen.dart';
import 'package:connect/features/student/screens/feed_screen.dart';
import 'package:connect/features/student/screens/opportunity_detail_screen.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/student/screens/apply_screen.dart';

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
      home: ApplyScreen(opportunity: feedOpportunities[0]),
    );
  }
}
