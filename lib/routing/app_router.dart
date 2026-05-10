// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/student_registration_screen.dart';
import '../screens/auth/alumni_registration_screen.dart';
import '../screens/auth/admin_registration_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/alumni/alumni_list_screen.dart';
import '../screens/alumni/alumni_profile_screen.dart';
import '../screens/qa/qa_screen.dart';
import '../screens/roadmap/roadmap_screen.dart';
import '../screens/placement/placement_reality_screen.dart';
import '../screens/skill_package/skill_package_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/gamification/badges_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/shell/student_shell.dart';
import '../screens/shell/alumni_shell.dart';
import '../screens/shell/admin_shell.dart';
import '../screens/alumni_dashboard/alumni_home_screen.dart';
import '../screens/alumni_dashboard/student_questions_screen.dart';
import '../screens/admin/admin_overview_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/messages/messaging_screen.dart';
import '../providers/app_providers.dart';

// Routes that do NOT require login
const _publicRoutes = [
  '/splash',
  '/onboarding',
  '/login',
  '/register-student',
  '/register-alumni',
  '/register-admin'
];

/// A Notifier that only fires when the login/logout status changes
/// (not when roadmap progress or other profile fields change).
/// This prevents GoRouter from re-running redirect on every auth state change.
class _AuthChangeNotifier extends ChangeNotifier {
  bool _isLoggedIn;
  UserRole? _role;

  _AuthChangeNotifier(this._isLoggedIn, this._role);

  void update(bool isLoggedIn, UserRole? role) {
    // Only notify if login status or role actually changed
    if (_isLoggedIn != isLoggedIn || _role != role) {
      _isLoggedIn = isLoggedIn;
      _role = role;
      notifyListeners();
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final initialAuth = ref.read(authProvider);
  final authNotifier = _AuthChangeNotifier(
    initialAuth.isLoggedIn,
    initialAuth.role,
  );

  // Only notify when login state or role changes — NOT when roadmap data changes
  ref.listen<AuthState>(authProvider, (prev, next) {
    authNotifier.update(next.isLoggedIn, next.role);
  });

  final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isLoggedIn;
      final hasSeenOnboarding = ref.read(hasSeenOnboardingProvider);
      final isPublic =
          _publicRoutes.any((r) => state.matchedLocation.startsWith(r));

      // 1. If not logged in and not on a public route → go to login
      if (!isLoggedIn && !isPublic) return '/login';

      // 2. If on onboarding but already seen it
      if (state.matchedLocation == '/onboarding' && hasSeenOnboarding) {
        return isLoggedIn ? null : '/login';
      }

      // 3. If logged in and still on a public landing page → push to dashboard
      if (isLoggedIn && isPublic) {
        if (authState.role == UserRole.student) return '/home';
        if (authState.role == UserRole.alumni) return '/alumni-home';
        if (authState.role == UserRole.admin) return '/admin-home';
      }

      // 4. Already on a valid private page — do nothing
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(
          path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
          path: '/register-student',
          builder: (_, __) => const StudentRegistrationScreen()),
      GoRoute(
          path: '/register-alumni',
          builder: (_, __) => const AlumniRegistrationScreen()),
      GoRoute(
          path: '/register-admin',
          builder: (_, __) => const AdminRegistrationScreen()),

      // ─── Student Shell ──────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => StudentShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(
              path: '/alumni', builder: (_, __) => const AlumniListScreen()),
          GoRoute(path: '/qa', builder: (_, __) => const QAScreen()),
          GoRoute(path: '/roadmap', builder: (_, __) => const RoadmapScreen()),
          GoRoute(path: '/badges', builder: (_, __) => const BadgesScreen()),
        ],
      ),

      // ─── Alumni Shell ───────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AlumniShell(child: child),
        routes: [
          GoRoute(
              path: '/alumni-home',
              builder: (_, __) => const AlumniHomeScreen()),
          GoRoute(
              path: '/alumni-questions',
              builder: (_, __) => const StudentQuestionsScreen()),
          GoRoute(
              path: '/alumni-profile',
              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ─── Admin Shell ────────────────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
              path: '/admin-home',
              builder: (_, __) => const AdminOverviewScreen()),
          GoRoute(
              path: '/admin-users',
              builder: (_, __) => const AdminUsersScreen()),
          GoRoute(
              path: '/admin-profile',
              builder: (_, __) => const ProfileScreen()),
        ],
      ),

      // ─── Sub-screens ────────────────────────────────────────────────────
      GoRoute(
        path: '/alumni/:id',
        builder: (context, state) {
          final alumniId = state.pathParameters['id']!;
          return AlumniProfileScreen(alumniId: alumniId);
        },
      ),
      GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
      GoRoute(
          path: '/placement',
          builder: (_, __) => const PlacementRealityScreen()),
      GoRoute(
          path: '/skill-package',
          builder: (_, __) => const SkillPackageScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(
          path: '/messages',
          builder: (_, __) => const MessagingListScreen()),
    ],
  );

  return router;
});
