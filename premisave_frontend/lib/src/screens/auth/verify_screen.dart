import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.verificationToken != null) {
      _verifyToken();
    }
  }

  Future<void> _verifyToken() async {
    if (_isVerifying) return;

    setState(() => _isVerifying = true);
    try {
      await ref.read(authProvider.notifier).verifyEmailToken(widget.verificationToken!);
      setState(() {
        _isVerified = true;
        _isVerifying = false;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/login');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isVerifying = false;
      });
    }
  }

  Future<void> _resendActivation() async {
    await ref.read(authProvider.notifier).resendActivationEmail(_emailController.text.trim());
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
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
                        child: _buildContent(authState, isLoading),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bottom section with consistent button sizes
                  if (widget.verificationToken == null || _error != null)
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

  Widget _buildContent(AuthState authState, bool isLoading) {
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

    return _buildResendForm(isLoading);
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
          'Please wait while we confirm your email address',
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
          _error?.replaceAll('Exception: ', '') ??
              'An error occurred during verification',
          style: const TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildResendForm(false),
      ],
    );
  }

  Widget _buildResendForm(bool isLoading) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.center,
          child: Icon(Icons.mail_outline,
              size: 70, color: Color(0xFF0A2463)),
        ),
        const SizedBox(height: 24),
        const Text(
          'Resend Verification Email',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
              color: Colors.black87),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter your email to receive a new verification link',
          style: TextStyle(color: Colors.black54, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
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
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : _resendActivation,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 50), // Consistent height
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: isLoading
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
                Text('Send Verification Email',
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
        // Contact Support Button - Same size as main button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _showContactDialog,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 50), // Same height as main button
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
                    fontSize: 16, // Same font size as main button
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Back to Login Button - Same size as main button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => context.go('/login'),
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 50), // Same height as main button
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
                    fontSize: 16, // Same font size as main button
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