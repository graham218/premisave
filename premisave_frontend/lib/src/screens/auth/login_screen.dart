import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && next.redirectUrl != null && next.isLoading == false) {
        context.go(next.redirectUrl!);
      }
    });

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
                ? _buildWideLayout(context, authState.isLoading, emailController, passwordController, authNotifier, authState)
                : _buildMobileLayout(context, authState.isLoading, emailController, passwordController, authNotifier, authState),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController emailController,
      TextEditingController passwordController,
      AuthNotifier authNotifier,
      AuthState authState,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscurePassword = true;

        return Container(
          constraints: const BoxConstraints(maxWidth: 950, maxHeight: 580),
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
                    color: const Color(0xFF0A2463), // Premisave blue
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
                      children: const [
                        Icon(Icons.real_estate_agent, color: Colors.white, size: 80),
                        SizedBox(height: 24),
                        Text(
                          "Welcome to Premisave",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Your gateway to smart real estate investments. "
                              "Track properties, manage portfolios, and grow your wealth securely.",
                          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right side - Login Form
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Center(
                    child: SingleChildScrollView(
                      child: _buildFormCard(
                        context,
                        isLoading,
                        emailController,
                        passwordController,
                        obscurePassword,
                            () => setState(() => obscurePassword = !obscurePassword),
                        authNotifier,
                        authState,
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
      TextEditingController emailController,
      TextEditingController passwordController,
      AuthNotifier authNotifier,
      AuthState authState,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscurePassword = true;

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
                const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 80),
                const SizedBox(height: 16),
                const Text(
                  "Welcome to Premisave",
                  style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Sign in to your account",
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                _buildFormCard(
                  context,
                  isLoading,
                  emailController,
                  passwordController,
                  obscurePassword,
                      () => setState(() => obscurePassword = !obscurePassword),
                  authNotifier,
                  authState,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormCard(
      BuildContext context,
      bool isLoading,
      TextEditingController emailController,
      TextEditingController passwordController,
      bool obscurePassword,
      VoidCallback toggleObscurePassword,
      AuthNotifier authNotifier,
      AuthState authState,
      ) {
    return Column(
      children: [
        // Email Field
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Enter your email',
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Password Field
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter your password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: toggleObscurePassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Login Button
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
                : const Icon(Icons.login, color: Colors.white),
            label: Text(
              isLoading ? 'Logging in...' : 'Login',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463), // Premisave blue
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: isLoading
                ? null
                : () => authNotifier.signIn(
              emailController.text.trim(),
              passwordController.text,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Forgot Password
        TextButton(
          onPressed: isLoading ? null : () => context.go('/forgot-password'),
          child: const Text(
            'Forgot Password?',
            style: TextStyle(color: Color(0xFF0A2463)),
          ),
        ),

        const SizedBox(height: 20),

        // Social Login Buttons
        _buildSocialLoginButtons(context, authNotifier, isLoading),

        const SizedBox(height: 10),

        // Sign Up Link
        TextButton(
          onPressed: isLoading ? null : () => context.go('/signup'),
          child: const Text(
            'Don\'t have an account? Sign Up',
            style: TextStyle(color: Color(0xFF0A2463)),
          ),
        ),

        // Error Message
        if (authState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              authState.error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(BuildContext context, AuthNotifier authNotifier, bool isLoading) {
    return Column(
      children: [
        // Google Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)),
            label: const Text(
              'Continue with Google',
              style: TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.googleSignIn(context),
          ),
        ),

        const SizedBox(height: 10),

        // Facebook Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2)),
            label: const Text(
              'Continue with Facebook',
              style: TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.facebookSignIn(context),
          ),
        ),

        const SizedBox(height: 10),

        // Apple Sign In
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.black),
            label: const Text(
              'Continue with Apple',
              style: TextStyle(color: Colors.black87),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.appleSignIn(context),
          ),
        ),
      ],
    );
  }
}