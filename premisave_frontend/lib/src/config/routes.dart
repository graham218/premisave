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
    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getRole();
    final isAuthenticated = token != null;

    final publicRoutes = [
      '/',
      '/splash',
      '/login',
      '/signup',
      '/forgot-password',
      '/reset-password',
      '/verify',
      '/verify/:token',
    ];

    final currentLocation = state.uri.path;

    if (isAuthenticated && publicRoutes.contains(currentLocation)) {
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

    final privateRoutes = [
      '/dashboard/client',
      '/dashboard/home-owner',
      '/dashboard/admin',
      '/dashboard/operations',
      '/dashboard/finance',
      '/dashboard/support',
      '/profile',
    ];

    if (!isAuthenticated && privateRoutes.contains(currentLocation)) {
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
    GoRoute(
      path: '/verify',
      builder: (_, __) => const VerifyScreen(),
    ),
    GoRoute(
      path: '/verify/:token',
      builder: (_, state) {
        final token = state.pathParameters['token'];
        return VerifyScreen(verificationToken: token);
      },
    ),
    GoRoute(path: '/dashboard/client', builder: (_, __) => const ClientDashboard()),
    GoRoute(path: '/dashboard/home-owner', builder: (_, __) => const HomeOwnerDashboard()),
    GoRoute(path: '/dashboard/admin', builder: (_, __) => const AdminDashboard()),
    GoRoute(path: '/dashboard/operations', builder: (_, __) => const OperationsDashboard()),
    GoRoute(path: '/dashboard/finance', builder: (_, __) => const FinanceDashboard()),
    GoRoute(path: '/dashboard/support', builder: (_, __) => const SupportDashboard()),
    GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
  ],
);