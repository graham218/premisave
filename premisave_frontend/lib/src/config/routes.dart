import 'package:go_router/go_router.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/verify_screen.dart';
import '../screens/dashboard/admin/admin_dashboard.dart';
import '../screens/dashboard/client/client_dashboard.dart';
import '../screens/dashboard/finance/finance_dashboard.dart';
import '../screens/dashboard/home-owner/home_owner_dashboard.dart';
import '../screens/dashboard/operartions/operations_dashboard.dart';
import '../screens/dashboard/support/support_dashboard.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/splash_screen.dart';
import '../services/secure_storage.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    // Get auth state from storage directly
    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getRole();
    final isAuthenticated = token != null;

    // Define public routes
    final publicRoutes = [
      '/',
      '/splash',
      '/login',
      '/signup',
      '/forgot-password',
      '/reset-password',
      '/verify',
    ];

    // Use uri.path to get the current path
    final currentLocation = state.uri.path;

    // If authenticated and trying to access public route
    if (isAuthenticated && publicRoutes.contains(currentLocation)) {
      // Redirect to appropriate dashboard
      switch (role?.toUpperCase()) {
        case 'CLIENT': return '/dashboard/client';
        case 'HOME_OWNER': return '/dashboard/home-owner';
        case 'ADMIN': return '/dashboard/admin';
        case 'OPERATIONS': return '/dashboard/operations';
        case 'FINANCE': return '/dashboard/finance';
        case 'SUPPORT': return '/dashboard/support';
        default: return '/dashboard/client';
      }
    }

    // Define private routes
    final privateRoutes = [
      '/dashboard/client',
      '/dashboard/home-owner',
      '/dashboard/admin',
      '/dashboard/operations',
      '/dashboard/finance',
      '/dashboard/support',
      '/profile',
    ];

    // If not authenticated and trying to access private route
    if (!isAuthenticated && privateRoutes.contains(currentLocation)) {
      return '/login';
    }

    return null;
  },
  routes: [
    // Root route
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),

    // All other routes
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
    GoRoute(path: '/verify', builder: (_, __) => const VerifyScreen()),
    GoRoute(path: '/dashboard/client', builder: (_, __) => const ClientDashboard()),
    GoRoute(path: '/dashboard/home-owner', builder: (_, __) => const HomeOwnerDashboard()),
    GoRoute(path: '/dashboard/admin', builder: (_, __) => const AdminDashboard()),
    GoRoute(path: '/dashboard/operations', builder: (_, __) => const OperationsDashboard()),
    GoRoute(path: '/dashboard/finance', builder: (_, __) => const FinanceDashboard()),
    GoRoute(path: '/dashboard/support', builder: (_, __) => const SupportDashboard()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);