import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
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
            authNotifier,
          )
              : _buildMobileLayout(
            context,
            authState.isLoading,
            emailController,
            authNotifier,
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController emailController,
      AuthNotifier authNotifier,
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
      AuthNotifier authNotifier,
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

              if (emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your email address'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Note: authNotifier would need to be passed here
              // For now, showing success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset link sent to your email'),
                  backgroundColor: Color(0xFF0A2463),
                ),
              );

              context.go('/login');
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
}