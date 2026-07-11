import 'package:flutter/material.dart';
import 'package:connect/features/startups/screens/startup_dashboard_screen.dart';
import 'package:connect/features/startups/screens/post_opportunity_screen.dart';
import 'package:connect/features/startups/screens/applicants_screen.dart';

class StartupHomeScreen extends StatefulWidget {
  const StartupHomeScreen({super.key});

  @override
  State<StartupHomeScreen> createState() => _StartupHomeScreenState();
}

class _StartupHomeScreenState extends State<StartupHomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    StartupDashboardScreen(onNewOpportunity: () => setState(() => _currentIndex = 1)),
    PostOpportunityScreen(onPosted: () => setState(() => _currentIndex = 0)),
    const ApplicantsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Applicants'),
        ],
      ),
    );
  }
}
