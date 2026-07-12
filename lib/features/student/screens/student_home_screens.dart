import 'package:flutter/material.dart';
import 'package:connect/features/student/screens/feed_screen.dart';
import 'package:connect/features/student/screens/search_screens.dart';
import 'package:connect/features/student/screens/bookmark_screen.dart';
import 'package:connect/features/student/screens/my_applications_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    SearchScreens(),
    BookmarkScreen(),
    MyApplicationsScreen(),
  ];

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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Bookmarks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Applications',
          ),
        ],
      ),
    );
  }
}
