import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../utils/toast_utils.dart';
import '../public/contact_content.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String? verificationToken;

  const VerifyScreen({super.key, this.verificationToken});

  @override
  ConsumerState<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends ConsumerState<VerifyScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isVerified = false;
  String? _error;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to run after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.verificationToken != null && !_isVerifying && !_isVerified) {
        _verifyToken();
      }
    });
  }

  Future<void> _verifyToken() async {
    if (_isVerifying || widget.verificationToken == null) return;

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      print('SCREEN: Starting verification with token: ${widget.verificationToken}');

      final success = await ref.read(authProvider.notifier).verifyEmailToken(widget.verificationToken!);

      if (success) {
        print('SCREEN: Verification successful');
        setState(() {
          _isVerified = true;
          _isVerifying = false;
        });

        // Show success message
        ToastUtils.showSuccessToast('Account verified successfully!');

        // Wait 2 seconds then redirect
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          print('SCREEN: Redirecting to login...');
          context.go('/login');
        }
      } else {
        throw Exception('Verification failed');
      }
    } catch (e) {
      print('SCREEN: Verification error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');

      // Handle specific error messages
      if (errorMessage.contains('Invalid or expired')) {
        errorMessage = 'Invalid or expired verification link';
      } else if (errorMessage.contains('already verified')) {
        errorMessage = 'Account already verified';
      } else if (errorMessage.contains('Connection timeout')) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (errorMessage.contains('Cannot connect')) {
        errorMessage = 'Cannot connect to server. Please try again later.';
      }

      setState(() {
        _error = errorMessage;
        _isVerifying = false;
      });

      // Show error toast
      ToastUtils.showErrorToast(errorMessage);
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

    setState(() => _isResending = true);

    try {
      print('SCREEN: Resending activation email to: $email');

      final success = await ref.read(authProvider.notifier).resendActivationEmail(email);

      if (success) {
        // Clear the text field after successful resend
        _emailController.clear();
      }
    } catch (e) {
      print('SCREEN: Resend error: $e');
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      ToastUtils.showErrorToast(errorMessage);
    } finally {
      setState(() => _isResending = false);
    }
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Contact Support',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const ContactContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _retryVerification() {
    if (widget.verificationToken != null) {
      _verifyToken();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: screenWidth > 600 ? 500 : screenWidth * 0.9,
                    ),
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 20 : 16,
                    ),
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          screenWidth > 600 ? 32 : 20,
                        ),
                        child: _buildContent(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom section
                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      maxWidth: screenWidth > 600 ? 500 : screenWidth * 0.9,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: EdgeInsets.symmetric(
                      horizontal: screenWidth > 600 ? 20 : 16,
                    ),
                    child: _buildBottomSection(screenWidth),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final hasToken = widget.verificationToken != null;

    if (hasToken && _isVerifying) {
      return _buildVerifyingState();
    }

    if (hasToken && _isVerified) {
      return _buildSuccessState();
    }

    if (hasToken && _error != null) {
      return _buildErrorState();
    }

    return _buildResendForm();
  }

  Widget _buildVerifyingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A2463)),
                strokeWidth: 4,
              ),
              Icon(Icons.verified_outlined,
                  color: Colors.blue.shade300, size: 40),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Verifying Your Account',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Please wait while we confirm your email address...',
          style: TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green.shade200, width: 3),
          ),
          child: const Icon(Icons.check_circle,
              color: Colors.green, size: 50),
        ),
        const SizedBox(height: 32),
        const Text(
          'Email Verified!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Colors.green),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Your account has been successfully verified.',
          style: TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'You can now sign in to your account.',
          style: TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Go to Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.shade200, width: 3),
          ),
          child: const Icon(Icons.error_outline,
              color: Colors.red, size: 50),
        ),
        const SizedBox(height: 32),
        const Text(
          'Verification Failed',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
              color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _error ?? 'An error occurred during verification',
          style: const TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Retry button for failed verification
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _retryVerification,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF0A2463)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Color(0xFF0A2463), size: 20),
                SizedBox(width: 10),
                Text('Try Again',
                    style: TextStyle(color: Color(0xFF0A2463), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Show resend form in error state
        _buildResendForm(),
      ],
    );
  }

  Widget _buildResendForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Need a new verification link?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,
              color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Enter your email to receive a new verification link',
          style: TextStyle(color: Colors.black54, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'you@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isResending ? null : _resendActivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _isResending
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_outlined, size: 20),
                SizedBox(width: 10),
                Text('Send New Verification Link',
                    style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Contact Support Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showContactDialog,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Color(0xFF0A2463)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.support_agent_outlined,
                    color: Color(0xFF0A2463), size: 20),
                SizedBox(width: 10),
                Text(
                  'Contact Support',
                  style: TextStyle(
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Back to Login Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 50),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back_ios_new,
                    color: Colors.blue, size: 16),
                SizedBox(width: 10),
                Text(
                  'Back to Login',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}