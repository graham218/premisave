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
  bool _isVerifying = false;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    if (widget.verificationToken != null) {
      _verifyToken();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _verifyToken() async {
    // For now, we'll handle this with a direct call since it's not in auth provider
    // You could add this to auth provider too if you want
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    setState(() {
      _isVerifying = false;
      _isVerified = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) context.go('/login');
  }

  Future<void> _resendActivation() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackbar('Please enter your email address');
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showErrorSnackbar('Please enter a valid email address');
      return;
    }

    await ref.read(authProvider.notifier).resendActivation(email);
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

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

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
            child: isLargeScreen
                ? _buildWideLayout(context, authState)
                : _buildMobileLayout(context, authState),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, AuthState authState) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 900),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0A2463),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified_user_outlined, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text(
                      "Verify Your Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Complete your registration to start investing.",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: _buildVerificationContent(context, authState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: _buildVerificationContent(context, authState),
    );
  }

  Widget _buildVerificationContent(BuildContext context, AuthState authState) {
    if (_isVerifying) {
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
          const Text('Redirecting to login...', style: TextStyle(fontSize: 16)),
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
          'Check your email for the verification link',
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),

        // Email input field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // Resend button
        authState.isLoading
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

        // Contact support button
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

        // Back to login
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }
}