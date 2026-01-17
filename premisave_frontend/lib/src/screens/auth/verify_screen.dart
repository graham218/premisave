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

        ToastUtils.showSuccessToast('Account verified successfully!');

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
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isWideScreen ? 1000 : 400),
            margin: const EdgeInsets.all(16),
            child: isWideScreen ? _buildWideLayout() : _buildMobileLayout(),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 600,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.blue[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(Icons.real_estate_agent, size: 60, color: Colors.white),
                          const SizedBox(height: 20),
                          Text(
                            "Email Verification",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Verify your email to access your real estate investment dashboard.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureRow("Secure account access"),
                          const SizedBox(height: 10),
                          _buildFeatureRow("Real-time notifications"),
                          const SizedBox(height: 10),
                          _buildFeatureRow("Investment tracking"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildContactButton(),
                  ],
                ),
              ),
            ),
            Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(-5, 0),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[50]!, Colors.blue[50]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.real_estate_agent, size: 50, color: Colors.green[700]),
                    const SizedBox(height: 10),
                    Text(
                      "Email Verification",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Verify your account",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: Colors.white.withOpacity(0.9), size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
        ),
      ],
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
            color: Colors.green[50],
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                strokeWidth: 4,
              ),
              Icon(Icons.verified_outlined, color: Colors.green[400], size: 40),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Verifying Your Account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.green[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Please wait while we confirm your email address...',
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
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
            color: Colors.green[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.green[200]!, width: 3),
          ),
          child: Icon(Icons.check_circle, color: Colors.green[600], size: 50),
        ),
        const SizedBox(height: 32),
        Text(
          'Email Verified!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Your account has been successfully verified.',
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'You can now sign in to your account.',
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Go to Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildBackToLoginButton(),
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
            color: Colors.red[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red[200]!, width: 3),
          ),
          child: Icon(Icons.error_outline, color: Colors.red[600], size: 50),
        ),
        const SizedBox(height: 32),
        Text(
          'Verification Failed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _error ?? 'An error occurred during verification',
          style: TextStyle(color: Colors.grey[700], fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _retryVerification,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.green[600]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh, color: Colors.green[600], size: 20),
                const SizedBox(width: 10),
                Text('Try Again', style: TextStyle(color: Colors.green[600], fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        Text(
          'Need a new verification link?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.green[800],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email to receive a new verification link',
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'you@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isResending ? null : _resendActivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
            ),
            child: _isResending
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.send_outlined, size: 20),
                const SizedBox(width: 10),
                Text('Send New Verification Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildBackToLoginButton(),
      ],
    );
  }

  Widget _buildContactButton() {
    return OutlinedButton.icon(
      onPressed: _showContactDialog,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.support_agent_outlined),
      label: const Text('Contact Support'),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => context.go('/login'),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back_ios_new, color: Colors.green[600], size: 16),
            const SizedBox(width: 10),
            Text(
              'Back to Login',
              style: TextStyle(color: Colors.green[600], fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}