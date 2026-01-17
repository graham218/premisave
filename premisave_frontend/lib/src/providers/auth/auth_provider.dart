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
  final String? redirectUrl;
  final bool shouldRedirectToLogin;
  final DateTime? tokenExpiry;

  AuthState({
    this.token,
    this.role,
    this.currentUser,
    this.isLoading = false,
    this.error,
    this.redirectUrl,
    this.shouldRedirectToLogin = false,
    this.tokenExpiry,
  });

  AuthState copyWith({
    String? token,
    String? role,
    UserModel? currentUser,
    bool? isLoading,
    String? error,
    String? redirectUrl,
    bool? shouldRedirectToLogin,
    DateTime? tokenExpiry,
  }) {
    return AuthState(
      token: token ?? this.token,
      role: role ?? this.role,
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      shouldRedirectToLogin: shouldRedirectToLogin ?? this.shouldRedirectToLogin,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  AuthNotifier() : super(AuthState()) {
    checkAuthStatus();
  }

  // Public method that can be called from main.dart
  Future<void> checkAuthStatus() async {
    try {
      final token = await SecureStorage.getToken();
      final role = await SecureStorage.getRole();
      final expiry = await SecureStorage.getTokenExpiry();

      if (token != null && role != null) {
        // Check if token needs refresh (within 7 days of expiry)
        if (await SecureStorage.shouldRefreshToken()) {
          await _refreshToken();
        } else {
          state = state.copyWith(
              token: token,
              role: role,
              tokenExpiry: expiry
          );
          await loadCurrentUser();
        }
      }
    } catch (e) {
      print('Error checking auth status: $e');
    }
  }

  Future<void> _refreshToken() async {
    final oldToken = await SecureStorage.getToken();
    if (oldToken == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(headers: {'Authorization': 'Bearer $oldToken'}),
      );

      final newToken = response.data['token'] as String;
      await SecureStorage.saveToken(newToken);

      final expiry = await SecureStorage.getTokenExpiry();
      state = state.copyWith(
        token: newToken,
        tokenExpiry: expiry,
        isLoading: false,
      );

      await loadCurrentUser();
    } catch (e) {
      print('Token refresh failed: $e');
      // If refresh fails, clear token and logout
      await _logoutSilently();
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _logoutSilently() async {
    await SecureStorage.clear();
    state = AuthState();
  }

  Future<void> loadCurrentUser() async {
    if (state.token == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      final user = UserModel.fromJson(response.data);
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
      );
    } catch (e) {
      print('Error loading user profile: $e');
      state = state.copyWith(isLoading: false, error: 'Failed to load profile');
    }
  }

  Future<void> signUp(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null, shouldRedirectToLogin: false);
    try {
      final response = await _dio.post('/auth/signup', data: data);
      final authRes = AuthResponse.fromJson(response.data);

      ToastUtils.showSuccessToast('Account created successfully! Please check your email to verify your account.');

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

  Future<bool> verifyEmailToken(String verificationToken) async {
    try {
      print('DEBUG: Calling verification endpoint with token: $verificationToken');

      final response = await _dio.get(
        '/auth/verify/$verificationToken',
        options: Options(responseType: ResponseType.json),
      );

      print('DEBUG: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('DEBUG: Verification successful!');
        ToastUtils.showSuccessToast('Account verified successfully!');
        return true;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } on DioException catch (e) {
      print('DEBUG: DioException: ${e.message}');
      print('DEBUG: Status code: ${e.response?.statusCode}');

      String errorMessage = 'Verification failed';

      if (e.response?.statusCode == 404) {
        errorMessage = 'Invalid or expired verification link';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Account already verified or invalid request';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please try again later.';
      } else if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        } else if (errorData is String) {
          errorMessage = errorData;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('DEBUG: General exception: $e');
      throw Exception('An unexpected error occurred during verification');
    }
  }

  Future<bool> resendActivationEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw Exception('Please enter your email address');
      }

      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
        throw Exception('Please enter a valid email address');
      }

      print('DEBUG: Resending activation email to: $email');

      final response = await _dio.post(
        '/auth/resend-activation',
        data: {'email': email},
        options: Options(responseType: ResponseType.json),
      );

      print('DEBUG: Resend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        ToastUtils.showSuccessToast('Activation email resent! Check your inbox.');
        return true;
      } else {
        throw Exception('Failed to resend activation email');
      }
    } on DioException catch (e) {
      print('DEBUG: Resend DioException: ${e.message}');

      String errorMessage = 'Failed to resend activation email';

      if (e.response?.statusCode == 404) {
        errorMessage = 'No account found with this email';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Account already verified or invalid email';
      } else if (e.response?.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          errorMessage = errorData['message']?.toString() ?? errorMessage;
        }
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('DEBUG: Resend general exception: $e');
      throw Exception('An unexpected error occurred');
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      print('DEBUG: Sending forgot password request for email: $email');

      final response = await _dio.post(
        '/auth/forgot-password',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('DEBUG: Forgot password response: ${response.statusCode}');

      ToastUtils.showSuccessToast('Password reset link sent to your email!');
      state = state.copyWith(isLoading: false);

    } on DioException catch (e) {
      print('DEBUG: Forgot password error: ${e.message}');
      print('DEBUG: Status code: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');

      String errorMessage = 'Failed to send reset email. Please try again.';

      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message']?.toString() ?? errorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'No account found with this email address.';
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    } catch (e) {
      print('DEBUG: Unexpected error: $e');
      ToastUtils.showErrorToast('An unexpected error occurred');
      state = state.copyWith(error: 'An unexpected error occurred', isLoading: false);
    }
  }

  Future<void> confirmResetPassword(String token, String newPassword, String confirmPassword) async {
    if (newPassword != confirmPassword) {
      ToastUtils.showErrorToast('New passwords do not match');
      state = state.copyWith(error: 'New passwords do not match');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      print('DEBUG: Confirming password reset with token: $token');

      final response = await _dio.post(
        '/auth/reset-password/confirm',
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      print('DEBUG: Reset password confirm response: ${response.statusCode}');

      ToastUtils.showSuccessToast('Password has been reset successfully!');
      state = state.copyWith(isLoading: false);

    } on DioException catch (e) {
      print('DEBUG: Reset password confirm error: ${e.message}');
      print('DEBUG: Status code: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');

      String errorMessage = 'Failed to reset password. Please try again.';

      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          errorMessage = data['message']?.toString() ?? errorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
      }

      ToastUtils.showErrorToast(errorMessage);
      state = state.copyWith(error: errorMessage, isLoading: false);
    } catch (e) {
      print('DEBUG: Unexpected error: $e');
      ToastUtils.showErrorToast('An unexpected error occurred');
      state = state.copyWith(error: 'An unexpected error occurred', isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _dio.post('/auth/signin', data: {
        'email': email,
        'password': password,
        'rememberMe': true, // Tell backend to issue long-lived token
      });
      final authRes = AuthResponse.fromJson(response.data);

      // Save with 30-day expiry
      await SecureStorage.saveToken(authRes.token);
      await SecureStorage.saveRole(authRes.role);

      final expiry = await SecureStorage.getTokenExpiry();

      ToastUtils.showSuccessToast('Welcome back!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        tokenExpiry: expiry,
        isLoading: false,
        shouldRedirectToLogin: false,
      );

      await loadCurrentUser();
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
        case 400: return 'Invalid request. Please check your information.';
        case 401: return 'Invalid email or password. Please try again.';
        case 403: return 'Access denied. Please contact support.';
        case 404: return 'Service not found. Please try again later.';
        case 409: return 'Account already exists with this email.';
        case 422: return 'Validation failed. Please check all fields.';
        case 500: return 'Server error. Please try again later.';
        case 503: return 'Service temporarily unavailable. Please try again later.';
        default: return 'Something went wrong. Please try again.';
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

      final expiry = await SecureStorage.getTokenExpiry();

      ToastUtils.showSuccessToast('Signed in with Google successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        tokenExpiry: expiry,
        isLoading: false,
      );

      await loadCurrentUser();
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

      final expiry = await SecureStorage.getTokenExpiry();

      ToastUtils.showSuccessToast('Signed in with Facebook successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        tokenExpiry: expiry,
        isLoading: false,
      );

      await loadCurrentUser();
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

      final expiry = await SecureStorage.getTokenExpiry();

      ToastUtils.showSuccessToast('Signed in with Apple successfully!');

      state = state.copyWith(
        token: authRes.token,
        role: authRes.role,
        redirectUrl: authRes.redirectUrl,
        tokenExpiry: expiry,
        isLoading: false,
      );

      await loadCurrentUser();
    } catch (e) {
      String errorMessage = 'Apple sign-in failed. Please try again.';

      if (e is DioException) {
        errorMessage = _getUserFriendlyErrorMessage(e);
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
        '/profile/change-password',
        data: {
          'currentPassword': oldPassword,
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

      await loadCurrentUser();

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
    try {
      print('Uploading profile picture...');

      // Use XFile.readAsBytes() which works on all platforms
      final bytes = await image.readAsBytes();
      print('Image size: ${bytes.length} bytes');

      // Create multipart file
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final formData = FormData.fromMap({
        'file': multipartFile,
      });

      // Send request
      final response = await _dio.post(
        '/profile/upload-profile-picture',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${state.token}',
          },
        ),
      );

      print('Upload successful! URL: ${response.data}');
      ToastUtils.showSuccessToast('Profile picture updated!');

      // Refresh user data
      await loadCurrentUser();

      return response.data as String;

    } catch (e) {
      print('Upload error: $e');

      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Response: ${e.response?.data}');
      }

      ToastUtils.showErrorToast('Failed to upload image. Please try again.');
      rethrow;
    }
  }

  Future<void> confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(
                color: Colors.blue,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF8B0000), // Dark red
              foregroundColor: Colors.white, // White text
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
      case 'CLIENT': return '/dashboard/client';
      case 'HOME_OWNER': return '/dashboard/home-owner';
      case 'ADMIN': return '/dashboard/admin';
      case 'OPERATIONS': return '/dashboard/operations';
      case 'FINANCE': return '/dashboard/finance';
      case 'SUPPORT': return '/dashboard/support';
      default: return '/dashboard/client';
    }
  }

  // Public method to check token status
  bool isTokenExpired() {
    if (state.tokenExpiry == null) return true;
    return DateTime.now().isAfter(state.tokenExpiry!);
  }

  // Public method to manually refresh token if needed
  Future<void> refreshToken() async {
    await _refreshToken();
  }

  // Debug method to test backend connection
  Future<void> testProfileUpload() async {
    try {
      print('Testing profile picture upload...');
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );
      print('Profile endpoint accessible: ${response.statusCode}');
      print('Profile data: ${response.data}');
    } catch (e) {
      print('Profile endpoint error: $e');
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
        print('Error status: ${e.response?.statusCode}');
      }
    }
  }

  // Method to verify the upload endpoint is working
  Future<void> testUploadEndpoint() async {
    try {
      print('Testing upload endpoint...');
      final response = await _dio.get(
        '/profile/me',
        options: Options(headers: {'Authorization': 'Bearer ${state.token}'}),
      );

      if (response.statusCode == 200) {
        print('Profile endpoint is working');
      } else {
        print('Profile endpoint returned status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error testing endpoint: $e');
    }
  }
}