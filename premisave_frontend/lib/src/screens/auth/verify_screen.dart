import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../utils/toast_utils.dart';
import '../public/contact_content.dart';

class VerifyScreen extends StatefulWidget {
  final String? verificationToken;

  const VerifyScreen({super.key, this.verificationToken});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isVerified = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    print('DEBUG: VerifyScreen init with token: ${widget.verificationToken}');

    if (widget.verificationToken != null) {
      _testBackendConnection();
      _verifyToken();
    }
  }

  Future<void> _verifyToken() async {
    if (_isLoading) return;

    print('DEBUG: Starting verification...');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('DEBUG: Calling backend: ${AppConfig.baseUrl}/auth/verify/${widget.verificationToken}');

      final response = await _dio.get(
        '/auth/verify/${widget.verificationToken}',
        options: Options(responseType: ResponseType.plain),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');

      if (response.statusCode == 200) {
        print('DEBUG: Verification successful!');
        ToastUtils.showSuccessToast('Account verified successfully!');
        setState(() {
          _isVerified = true;
          _isLoading = false;
        });

        // Wait 2 seconds then redirect
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          print('DEBUG: Redirecting to login...');
          context.go('/login');
        }
      }
    } on DioException catch (e) {
      print('DEBUG: DioException: ${e.message}');
      print('DEBUG: Status code: ${e.response?.statusCode}');
      print('DEBUG: Response data: ${e.response?.data}');

      String errorMessage = 'Verification failed';

      if (e.response?.statusCode == 404) {
        errorMessage = 'Invalid or expired verification link';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Account already verified';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Cannot connect to server. Please try again later.';
      }

      print('DEBUG: Setting error: $errorMessage');
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });

      ToastUtils.showErrorToast(errorMessage);
    } catch (e) {
      print('DEBUG: General exception: $e');
      setState(() {
        _error = 'An unexpected error occurred';
        _isLoading = false;
      });
      ToastUtils.showErrorToast('An unexpected error occurred');
    }
  }

  Future<void> _testBackendConnection() async {
    print('DEBUG: Testing backend connection to ${AppConfig.baseUrl}');
    try {
      final response = await _dio.get('/auth/test');
      print('DEBUG: Backend is reachable: ${response.statusCode}');
    } catch (e) {
      print('DEBUG: Cannot reach backend: $e');
      // Try with a direct ping
      try {
        final response = await _dio.get('http://localhost:8080');
        print('DEBUG: Direct ping to localhost:8080: ${response.statusCode}');
      } catch (e2) {
        print('DEBUG: Cannot even ping localhost: $e2');
      }
    }
  }

  Future<void> _resendActivation() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ToastUtils.showErrorToast('Please enter your email address');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      ToastUtils.showErrorToast('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _dio.post(
        '/auth/resend-activation/$email',
        options: Options(responseType: ResponseType.plain),
      );
      ToastUtils.showSuccessToast('Activation email resent! Check your inbox.');
    } on DioException catch (e) {
      String errorMessage = 'Failed to resend activation email';
      if (e.response?.statusCode == 404) {
        errorMessage = 'No account found with this email';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Account already verified';
      }
      ToastUtils.showErrorToast(errorMessage);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const SizedBox(
          width: double.maxFinite,
          child: ContactContent(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    print('DEBUG: Building widget. isLoading: $_isLoading, isVerified: $_isVerified, error: $_error');

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFf8f9fa), Color(0xFFe9ecef)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: isLargeScreen ? 600 : double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
                ],
              ),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    // If token is provided, show verification status
    if (widget.verificationToken != null) {
      if (_isLoading) {
        return const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0A2463)),
            SizedBox(height: 20),
            Text('Verifying your account...', style: TextStyle(fontSize: 16)),
          ],
        );
      }

      if (_isVerified) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Account Verified!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            const Text('You can now login to your account', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2463),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Go to Login', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }

      if (_error != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              'Verification Failed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildResendForm(),
          ],
        );
      }
    }

    // Default view (no token or verification not yet started)
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified_user_outlined, color: Color(0xFF0A2463), size: 70),
        const SizedBox(height: 20),
        const Text(
          'Verify Your Email',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A2463)),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your email to resend the verification link',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        _buildResendForm(),
      ],
    );
  }

  Widget _buildResendForm() {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter the email you used to register',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        _isLoading
            ? const CircularProgressIndicator(color: Color(0xFF0A2463))
            : ElevatedButton.icon(
          icon: const Icon(Icons.email, color: Colors.white),
          label: const Text('Resend Activation Email'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0A2463),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _resendActivation,
        ),
        const SizedBox(height: 16),

        OutlinedButton.icon(
          icon: const Icon(Icons.support_agent, color: Color(0xFF0A2463)),
          label: const Text('Contact Support'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            minimumSize: const Size(double.infinity, 48),
            side: const BorderSide(color: Color(0xFF0A2463)),
          ),
          onPressed: _showContactDialog,
        ),
        const SizedBox(height: 16),

        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}