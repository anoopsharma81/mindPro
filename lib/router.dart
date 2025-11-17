import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/reflections/presentation/reflections_list_page.dart';
import 'features/reflections/presentation/reflection_edit_page.dart';
import 'features/cpd/presentation/cpd_list_page.dart';
import 'features/cpd/presentation/cpd_edit_page.dart';
import 'features/cpd/presentation/cpd_import_page.dart';
import 'features/export/export_page.dart';
import 'features/auth/login_page.dart';
import 'features/auth/signup_page.dart';
import 'features/profile/profile_page.dart';
import 'features/settings/settings_page.dart';
import 'features/learning_loops/presentation/learning_loop_page.dart';

GoRouter createRouter() => GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
    
    // Redirect to login if not authenticated and not on auth route
    if (user == null && !isAuthRoute) {
      return '/login';
    }
    
    // Redirect to home if authenticated and on auth route
    if (user != null && isAuthRoute) {
      return '/';
    }
    
    return null;
  },
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    GoRoute(path: '/signup', builder: (c, s) => const SignupPage()),
    
    // Main app routes (require auth)
    GoRoute(path: '/', builder: (c, s) => const DashboardPage()),
    GoRoute(path: '/reflections', builder: (c, s) => const ReflectionsListPage()),
    GoRoute(path: '/reflections/new', builder: (c, s) => const ReflectionEditPage()),
    GoRoute(path: '/reflections/:id', builder: (c, s) => ReflectionEditPage(id: s.pathParameters['id'])),
    GoRoute(
      path: '/reflections/:reflectionId/learning-loop',
      builder: (c, s) => LearningLoopPage(
        reflectionId: s.pathParameters['reflectionId']!,
      ),
    ),
    GoRoute(path: '/cpd', builder: (c, s) => const CpdListPage()),
    GoRoute(path: '/cpd/new', builder: (c, s) => const CpdEditPage()),
    GoRoute(path: '/cpd/import', builder: (c, s) => const CpdImportPage()),
    GoRoute(path: '/cpd/:id', builder: (c, s) => CpdEditPage(id: s.pathParameters['id'])),
    GoRoute(path: '/export', builder: (c, s) => const ExportPage()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfilePage()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsPage()),
  ],
);
