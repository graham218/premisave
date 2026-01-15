import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final oldPasswordController = TextEditingController();
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
              oldPasswordController,
              newPasswordController,
              confirmPasswordController,
              authNotifier,
            )
                : _buildMobileLayout(
              context,
              authState.isLoading,
              oldPasswordController,
              newPasswordController,
              confirmPasswordController,
              authNotifier,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController oldPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      AuthNotifier authNotifier,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureOldPassword = true;
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2463),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.real_estate_agent, color: Colors.white, size: 80),
                        const SizedBox(height: 24),
                        const Text(
                          "Secure Your Premisave Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Update your password to keep your real estate investments secure. "
                              "We recommend using a strong, unique password.",
                          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: const [
                            Icon(Icons.security, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("End-to-end encryption", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.lock_clock, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("Regular security updates", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
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

              // Right side - Password Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildPasswordForm(
                        context,
                        isLoading,
                        obscureOldPassword,
                        obscureNewPassword,
                        obscureConfirmPassword,
                            () => setState(() => obscureOldPassword = !obscureOldPassword),
                            () => setState(() => obscureNewPassword = !obscureNewPassword),
                            () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                        oldPasswordController,
                        newPasswordController,
                        confirmPasswordController,
                        authNotifier,
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
      TextEditingController oldPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      AuthNotifier authNotifier,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscureOldPassword = true;
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
                const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 70),
                const SizedBox(height: 16),
                const Text(
                  "Change Your Password",
                  style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Secure your Premisave account with a new password",
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildPasswordForm(
                  context,
                  isLoading,
                  obscureOldPassword,
                  obscureNewPassword,
                  obscureConfirmPassword,
                      () => setState(() => obscureOldPassword = !obscureOldPassword),
                      () => setState(() => obscureNewPassword = !obscureNewPassword),
                      () => setState(() => obscureConfirmPassword = !obscureConfirmPassword),
                  oldPasswordController,
                  newPasswordController,
                  confirmPasswordController,
                  authNotifier,
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
      bool obscureOldPassword,
      bool obscureNewPassword,
      bool obscureConfirmPassword,
      VoidCallback toggleObscureOldPassword,
      VoidCallback toggleObscureNewPassword,
      VoidCallback toggleObscureConfirmPassword,
      TextEditingController oldPasswordController,
      TextEditingController newPasswordController,
      TextEditingController confirmPasswordController,
      AuthNotifier authNotifier,
      ) {
    return Column(
      children: [
        // Current Password
        TextField(
          controller: oldPasswordController,
          obscureText: obscureOldPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Current Password',
            hintText: 'Enter your current password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscureOldPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscureOldPassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // New Password
        TextField(
          controller: newPasswordController,
          obscureText: obscureNewPassword,
          enabled: !isLoading,
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
          enabled: !isLoading,
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

        // Change Password Button
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
              isLoading ? 'Updating Password...' : 'Change Password',
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
            onPressed: isLoading
                ? null
                : () async {
              await authNotifier.changePassword(
                oldPasswordController.text,
                newPasswordController.text,
                confirmPasswordController.text,
              );

              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password changed successfully'),
                  backgroundColor: const Color(0xFF0A2463),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );

              // Navigate back to login
              context.go('/login');
            },
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
}