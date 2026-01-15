import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/app_config.dart';
import '../../models/auth/auth_response.dart';
import '../../models/auth/user_model.dart';
import '../../services/secure_storage.dart';
import '../../utils/toast_utils.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final String? token;
  final String? role;
  final UserModel? currentUser;
  final bool isLoading;
  final String? error;
  final List<UserModel> searchedUsers;
  final String? redirectUrl;
  final bool shouldRedirectToLogin;

  AuthState({
    this.token,
    this.role,
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.searchedUsers = const [],
    this.redirectUrl,
    this.shouldRedirectToLogin = false,
  });

  AuthState copyWith({
    String? token,
    String? role,
    UserModel? currentUser,
    bool? isLoading,
    String? error,
    List<UserModel>? searchedUsers,
    String? redirectUrl,
    bool? shouldRedirectToLogin,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchedUsers: searchedUsers ?? this.searchedUsers,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      shouldRedirectToLogin: shouldRedirectToLogin ?? this.shouldRedirectToLogin,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await SecureStorage.getToken();
    final role = await SecureStorage.getRole();
    if (token != null && role != null) {
      state = state.copyWith(token: token, role: role);
    }
  }

  Future<void> signUp(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null, shouldRedirectToLogin: false);
    try {
      final response = await _dio.post('/auth/signup', data: data);
      final authRes = AuthResponse.fromJson(response.data);

      // Don't save token/role for signup - user needs to login
      ToastUtils.showSuccessToast('Account created successfully! Please check your email to verify your account.');

      // Set flag to redirect to login page
      state = state.copyWith(
        isLoading: false,
        shouldRedirectToLogin: true,
      );
    } catch (e) {
      String errorMessage = 'Failed to create account. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/signin', data: {'email': email, 'password': password});
      final authRes = AuthResponse.fromJson(response.data);
      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      ToastUtils.showSuccessToast('Welcome back!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
        shouldRedirectToLogin: false,
      );
    } catch (e) {
      String errorMessage = 'Login failed. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);

        if (e.response?.statusCode == 401) {
          errorMessage = 'Invalid email or password. Please try again.';
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  String _getUserFriendlyErrorMessage(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;

      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString();
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }

      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your information.';
        case 401:
          return 'Invalid email or password. Please try again.';
        case 403:
          return 'Access denied. Please contact support.';
        case 404:
          return 'Service not found. Please try again later.';
        case 409:
          return 'Account already exists with this email.';
        case 422:
          return 'Validation failed. Please check all fields.';
        case 500:
          return 'Server error. Please try again later.';
        case 503:
          return 'Service temporarily unavailable. Please try again later.';
        default:
          return 'Something went wrong. Please try again.';
      }
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Network error. Please check your connection.';
    }

    return 'An unexpected error occurred. Please try again.';
  }

  Future<void> googleSignIn(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        ToastUtils.showErrorToast('Failed to get Google credentials');
        state = state.copyWith(isLoading: false, error: 'Failed to get ID token');
        return;
      }

      final response = await _dio.post('/auth/social/google', data: {'token': idToken});
      final authRes = AuthResponse.fromJson(response.data);

      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      ToastUtils.showSuccessToast('Signed in with Google successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Google sign-in failed. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> facebookSignIn(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final String accessToken = result.accessToken!.tokenString;

      final response = await _dio.post('/auth/social/facebook', data: {'token': accessToken});
      final authRes = AuthResponse.fromJson(response.data);

      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      ToastUtils.showSuccessToast('Signed in with Facebook successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Facebook sign-in failed. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> appleSignIn(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? idToken = credential.identityToken;

      if (idToken == null) {
        ToastUtils.showErrorToast('Apple sign-in failed. Please try again.');
        state = state.copyWith(isLoading: false, error: 'Apple ID token is null');
        return;
      }

      final response = await _dio.post('/auth/social/apple', data: {'token': idToken});
      final authRes = AuthResponse.fromJson(response.data);

      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      ToastUtils.showSuccessToast('Signed in with Apple successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      String errorMessage = 'Apple sign-in failed. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/auth/reset-password', data: {'email': email});
      ToastUtils.showSuccessToast('Password reset link sent to your email!');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to send reset email. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);

        if (e.response?.statusCode == 404) {
          errorMessage = 'No account found with this email address.';
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      ToastUtils.showErrorToast('New passwords do not match');
      state = state.copyWith(error: 'New passwords do not match');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post(
        '/auth/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      ToastUtils.showSuccessToast('Password changed successfully!');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to change password. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);

        if (e.response?.statusCode == 401) {
          errorMessage = 'Current password is incorrect.';
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.put(
        '/profile/update',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      ToastUtils.showSuccessToast('Profile updated successfully!');
      state = state.copyWith(isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to update profile. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<String> uploadProfilePicture(XFile image) async {
    state = state.copyWith(isLoading: true);
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path),
      });

      final response = await _dio.post(
        '/profile/upload-pic',
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      ToastUtils.showSuccessToast('Profile picture updated!');
      state = state.copyWith(isLoading: false);
      return response.data as String;
    } catch (e) {
      String errorMessage = 'Failed to upload image. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
      rethrow;
    }
  }

  Future<void> searchUsers(String query) async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.post(
        '/admin/users/search',
        data: {'query': query},
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      final List<UserModel> users = (response.data as List)
          .map((json) => UserModel.fromJson(json))
          .toList();

      state = state.copyWith(searchedUsers: users, isLoading: false);
    } catch (e) {
      String errorMessage = 'Failed to search users. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> adminAction(String action, String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.put(
        '/admin/users/$action/$userId',
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      String actionMessage = action == 'activate' ? 'User activated' :
      action == 'deactivate' ? 'User deactivated' :
      action == 'delete' ? 'User deleted' : 'Action completed';

      ToastUtils.showSuccessToast('$actionMessage successfully!');
      state = state.copyWith(isLoading: false);
      await searchUsers(''); // Refresh list
    } catch (e) {
      String errorMessage = 'Failed to perform action. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    }
  }

  Future<void> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorage.clear();
      state = AuthState();
      ToastUtils.showInfoToast('Logged out successfully');
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  String getDashboardRoute() {
    switch (state.role?.toUpperCase()) {
      case 'CLIENT':
        return '/dashboard/client';
      case 'HOME_OWNER':
        return '/dashboard/home-owner';
      case 'ADMIN':
        return '/dashboard/admin';
      case 'OPERATIONS':
        return '/dashboard/operations';
      case 'FINANCE':
        return '/dashboard/finance';
      case 'SUPPORT':
        return '/dashboard/support';
      default:
        return '/dashboard/client';
    }
  }
}