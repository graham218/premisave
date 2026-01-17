import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final emailController = TextEditingController();

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
          child: isLargeScreen
              ? _buildDesktopLayout(
            context,
            authState.isLoading,
            emailController,
            ref,
          )
              : _buildMobileLayout(
            context,
            authState.isLoading,
            emailController,
            ref,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController emailController,
      WidgetRef ref,
      ) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 850, maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          // Left side - Branding
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
                    Icon(Icons.lock_reset_outlined, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text(
                      "Reset Your Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Enter your email address and we'll send you a link to reset your password. "
                          "Secure access to your real estate investments.",
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right side - Reset Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFormContent(
                        isLoading,
                        emailController,
                        context,
                        ref,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildBackToLoginLink(isLoading, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController emailController,
      WidgetRef ref,
      ) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_reset_outlined, color: Color(0xFF0A2463), size: 70),
            const SizedBox(height: 16),
            const Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 26,
                color: Color(0xFF0A2463),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Enter your email to receive a password reset link",
              style: TextStyle(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildFormContent(
              isLoading,
              emailController,
              context,
              ref,
            ),
            const SizedBox(height: 16),
            _buildBackToLoginLink(isLoading, context),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent(
      bool isLoading,
      TextEditingController emailController,
      BuildContext context,
      WidgetRef ref,
      ) {
    return Column(
      children: [
        // Email Field
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Email Address',
            hintText: 'Enter your registered email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: !isLoading,
            fillColor: Colors.grey[50],
          ),
        ),

        // Instructions
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFf8f9fa),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF0A2463), size: 20),
                  SizedBox(width: 8),
                  Text(
                    "What to expect:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2463),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "A secure password reset link will be sent to your email",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "The link will expire in 24 hours for security",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Check your spam folder if you don't see the email",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Send Reset Link Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.send_outlined, color: Colors.white),
            label: Text(
              isLoading ? 'Sending...' : 'Send Reset Link',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            onPressed: isLoading
                ? null
                : () async {
              FocusScope.of(context).unfocus();
              final email = emailController.text.trim();

              if (email.isEmpty) {
                _showSnackBar(context, 'Please enter your email address', Colors.red);
                return;
              }

              // Validate email format
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
                _showSnackBar(context, 'Please enter a valid email address', Colors.red);
                return;
              }

              try {
                // Call the forgotPassword method from auth provider
                await ref.read(authProvider.notifier).forgotPassword(email);

                // Show success message
                _showSnackBar(
                  context,
                  'Password reset link sent to your email',
                  const Color(0xFF0A2463),
                );

                // Clear the email field
                emailController.clear();

                // Navigate back to login after a short delay
                await Future.delayed(const Duration(seconds: 2));
                if (context.mounted) {
                  context.go('/login');
                }
              } catch (e) {
                // Error is already shown by the provider via ToastUtils
                // You can also show a snackbar here if needed
                _showSnackBar(
                  context,
                  'Failed to send reset link. Please try again.',
                  Colors.red,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackToLoginLink(bool isLoading, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.arrow_back_outlined, color: Colors.grey, size: 18),
        const SizedBox(width: 8),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: Color(0xFF0A2463),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}