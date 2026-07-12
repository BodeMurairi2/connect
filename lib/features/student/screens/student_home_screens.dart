import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connect/features/student/bloc/feed_bloc.dart';
import 'package:connect/features/student/bloc/feed_event.dart';
import 'package:connect/features/student/screens/feed_screen.dart';
import 'package:connect/features/student/screens/search_screens.dart';
import 'package:connect/features/student/screens/bookmark_screen.dart';
import 'package:connect/features/student/screens/my_applications_screen.dart';
import 'package:connect/features/student/screens/student_profile_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FeedBloc(),
      child: const _StudentHomeBody(),
    );
  }
}

class _StudentHomeBody extends StatefulWidget {
  const _StudentHomeBody();

  @override
  State<_StudentHomeBody> createState() => _StudentHomeBodyState();
}

class _StudentHomeBodyState extends State<_StudentHomeBody> {
  int _currentIndex = 0;
  StreamSubscription<User?>? _authSub;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      FeedScreen(onSeeAll: () => setState(() => _currentIndex = 1)),
      const SearchScreens(),
      const BookmarkScreen(),
      const MyApplicationsScreen(),
      const StudentProfileScreen(),
    ];
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null && mounted) {
        context.read<FeedBloc>().add(LoadFeed(user.uid));
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.work_outline), label: 'Applications'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
