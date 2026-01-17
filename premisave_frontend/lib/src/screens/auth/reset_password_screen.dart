import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class ResetPasswordScreen extends ConsumerWidget {
  final String? resetToken;

  const ResetPasswordScreen({super.key, this.resetToken});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isLargeScreen
                ? _buildWideLayout(
              context,
              authState.isLoading,
              newPasswordController,
              confirmPasswordController,
              ref,
            )
                : _buildMobileLayout(
              context,
              authState.isLoading,
              newPasswordController,
              confirmPasswordController,
              ref,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      WidgetRef ref,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureNewPassword = true;
        bool obscureConfirmPassword = true;

        return Container(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 600),
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
                flex: 1,
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
                        Icon(Icons.lock_reset, color: Colors.white, size: 80),
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
                          "Create a new secure password for your Premisave account. "
                              "Make sure it's strong and unique to protect your investments.",
                          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            Icon(Icons.security, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("End-to-end encryption", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.lock_clock, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("24-hour reset link validity", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("Protected investment data", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right side - Reset Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildPasswordForm(
                        context,
                        isLoading,
                        obscureNewPassword,
                        obscureConfirmPassword,
                            () => setState(() => obscureNewPassword = !obscureNewPassword),
                            () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                        newPasswordController,
                        confirmPasswordController,
                        ref,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      WidgetRef ref,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureNewPassword = true;
        bool obscureConfirmPassword = true;

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset, color: Color(0xFF0A2463), size: 70),
                const SizedBox(height: 16),
                const Text(
                  "Create New Password",
                  style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter a new secure password for your account",
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildPasswordForm(
                  context,
                  isLoading,
                  obscureNewPassword,
                  obscureConfirmPassword,
                      () => setState(() => obscureNewPassword = !obscureNewPassword),
                      () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                  newPasswordController,
                  confirmPasswordController,
                  ref,
                ),
                const SizedBox(height: 20),
                _buildBackToLoginLink(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordForm(
      BuildContext context,
      bool isLoading,
      bool obscureNewPassword,
      bool obscureConfirmPassword,
      VoidCallback toggleObscureNewPassword,
      VoidCallback toggleObscureConfirmPassword,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      WidgetRef ref,
      ) {
    return Column(
      children: [
        // Reset Token Info (if available)
        if (resetToken != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFe8f5e9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4caf50), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFF4caf50), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Reset link verified. You can now set a new password.",
                    style: TextStyle(color: Color(0xFF2e7d32), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

        // New Password
        TextField(
          controller: newPasswordController,
          obscureText: obscureNewPassword,
          enabled: !isLoading && resetToken != null,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter your new password',
            prefixIcon: const Icon(Icons.lock_reset),
            suffixIcon: IconButton(
              icon: Icon(obscureNewPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscureNewPassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Confirm New Password
        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          enabled: !isLoading && resetToken != null,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            hintText: 'Confirm your new password',
            prefixIcon: const Icon(Icons.lock_clock_outlined),
            suffixIcon: IconButton(
              icon: Icon(obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscureConfirmPassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Password Requirements
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
              Text(
                "Password Requirements:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2463),
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text("At least 8 characters", style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text("Mix of letters and numbers", style: TextStyle(fontSize: 14)),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text("Include special characters", style: TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Reset Password Button
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
                : const Icon(Icons.lock_reset, color: Colors.white),
            label: Text(
              isLoading ? 'Resetting Password...' : 'Reset Password',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: (isLoading || resetToken == null)
                ? null
                : () async {
              if (newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                _showSnackBar(context, 'Please fill in all fields', Colors.red);
                return;
              }

              await ref.read(authProvider.notifier).confirmResetPassword(
                resetToken!,
                newPasswordController.text,
                confirmPasswordController.text,
              );

              // Success message is shown by the provider
              // Navigate back to login after a delay
              await Future.delayed(const Duration(seconds: 2));
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ),

        // Token Missing Warning
        if (resetToken == null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFffebee),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFf44336), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Color(0xFFf44336), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Invalid or expired reset link",
                        style: TextStyle(
                          color: Color(0xFFc62828),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => context.go('/forgot-password'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Request a new password reset link',
                          style: TextStyle(
                            color: Color(0xFF0A2463),
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBackToLoginLink(BuildContext context) {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: const Text(
        'Back to Login',
        style: TextStyle(
          color: Color(0xFF0A2463),
          fontWeight: FontWeight.w500,
        ),
      ),
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