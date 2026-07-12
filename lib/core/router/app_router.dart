import 'package:go_router/go_router.dart';
import 'package:connect/features/auth/screens/login_screen.dart';
import 'package:connect/features/auth/screens/register_screen.dart';
import 'package:connect/features/auth/screens/role_selection_screen.dart';
import 'package:connect/features/onboarding/screens/student_onboarding_screen.dart';
import 'package:connect/features/onboarding/screens/startup_onboarding_screen.dart';
import 'package:connect/features/student/screens/student_home_screens.dart';
import 'package:connect/features/student/screens/opportunity_detail_screen.dart';
import 'package:connect/features/student/screens/apply_screen.dart';
import 'package:connect/features/student/data/feed_data.dart';
import 'package:connect/features/startups/screens/startup_home_screen.dart';
import 'package:connect/features/admin/screens/admin_dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/role-selection',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding/student',
      builder: (context, state) => const StudentOnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding/startup',
      builder: (context, state) => const StartupOnboardingScreen(),
    ),
    GoRoute(
      path: '/student',
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: '/student/opportunity',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is FeedOpportunity) {
          return OpportunityDetailScreen(opportunity: extra);
        }
        final map = extra as Map;
        return OpportunityDetailScreen(
          opportunity: map['opportunity'] as FeedOpportunity,
          applicationData: map['applicationData'] as Map<String, dynamic>?,
        );
      },
    ),
    GoRoute(
      path: '/student/opportunity/apply',
      builder: (context, state) => ApplyScreen(
        opportunity: state.extra as FeedOpportunity,
      ),
    ),
    GoRoute(
      path: '/startup',
      builder: (context, state) => const StartupHomeScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
  ],
);
