import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/features/startups/bloc/startup_bloc.dart';
import 'package:connect/features/startups/bloc/startup_event.dart';
import 'package:connect/features/startups/screens/startup_dashboard_screen.dart';
import 'package:connect/features/startups/screens/post_opportunity_screen.dart';
import 'package:connect/features/startups/screens/applicants_screen.dart';

class StartupHomeScreen extends StatelessWidget {
  const StartupHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StartupBloc()..add(LoadDashboard()),
      child: const _StartupHomeBody(),
    );
  }
}

class _StartupHomeBody extends StatefulWidget {
  const _StartupHomeBody();

  @override
  State<_StartupHomeBody> createState() => _StartupHomeBodyState();
}

class _StartupHomeBodyState extends State<_StartupHomeBody> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
    if (index == 2) {
      context.read<StartupBloc>().add(LoadApplicants());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      StartupDashboardScreen(
        onNewOpportunity: () => setState(() => _currentIndex = 1),
      ),
      PostOpportunityScreen(
        onPosted: () {
          context.read<StartupBloc>().add(LoadDashboard());
          setState(() => _currentIndex = 0);
        },
      ),
      const ApplicantsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onTabChanged,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box), label: 'Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people), label: 'Applicants'),
        ],
      ),
    );
  }
}
