import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:image_picker/image_picker.dart';
import '../config/app_config.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';
import '../services/secure_storage.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());

class AuthState {
  final String? token;
  final String? role;
  final UserModel? currentUser;
  final bool isLoading;
  final String? error;
  final List<UserModel> searchedUsers;
  final String? redirectUrl;

  AuthState({
    this.token,
    this.role,
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.searchedUsers = const [],
    this.redirectUrl,
  });

  AuthState copyWith({
    String? token,
    String? role,
    UserModel? currentUser,
    bool? isLoading,
    String? error,
    List<UserModel>? searchedUsers,
    String? redirectUrl,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchedUsers: searchedUsers ?? this.searchedUsers,
      redirectUrl: redirectUrl ?? this.redirectUrl,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  // Correct way for google_sign_in ^7.1.1 - scopes in constructor
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/signup', data: data);
      final authRes = AuthResponse.fromJson(response.data);
      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);
      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/signin', data: {'email': email, 'password': password});
      final authRes = AuthResponse.fromJson(response.data);
      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);
      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // signIn() is available on the instance
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        state = state.copyWith(isLoading: false, error: 'Failed to get ID token');
        return;
      }

      final response = await _dio.post('/auth/social/google', data: {'token': idToken});
      final authRes = AuthResponse.fromJson(response.data);

      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
        state = state.copyWith(isLoading: false, error: 'Apple ID token is null');
        return;
      }

      final response = await _dio.post('/auth/social/apple', data: {'token': idToken});
      final authRes = AuthResponse.fromJson(response.data);

      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _dio.post('/auth/reset-password', data: {'email': email});
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
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
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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

      state = state.copyWith(isLoading: false);
      return response.data as String;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> adminAction(String action, String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      await _dio.put(
        '/admin/users/$action/$userId',
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );
      state = state.copyWith(isLoading: false);
      await searchUsers(''); // Refresh list
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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