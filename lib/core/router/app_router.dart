import 'package:go_router/go_router.dart';
import 'package:connect/features/student/screens/student_home_screens.dart';
import 'package:connect/features/startups/screens/startup_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/student',
  routes: [
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentHomeScreen(),
    ),

    GoRoute(
      path: '/startup',
      builder: (context, state) => StartupDashboardScreen(),
    ),
  ],
);
