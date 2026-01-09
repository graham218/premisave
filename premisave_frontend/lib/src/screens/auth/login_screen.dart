import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);

  void _submitForm(AuthNotifier authNotifier) {
    if (_formKey.currentState!.validate()) {
      authNotifier.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.token != null && next.redirectUrl != null && !next.isLoading) {
        context.go(next.redirectUrl!);
      }
    });

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
                ? _buildWideLayout(context, authState, authNotifier)
                : _buildMobileLayout(context, authState, authNotifier),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(BuildContext context, AuthState authState, AuthNotifier authNotifier) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 950, maxHeight: 580),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
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
                  children: const [
                    Icon(Icons.real_estate_agent, color: Colors.white, size: 80),
                    SizedBox(height: 24),
                    Text(
                      "Welcome to Premisave",
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
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
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Center(child: SingleChildScrollView(child: _buildFormCard(authState, authNotifier))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, AuthState authState, AuthNotifier authNotifier) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Column(
          children: [
            const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 80),
            const SizedBox(height: 16),
            const Text(
              "Welcome to Premisave",
              style: TextStyle(fontSize: 26, color: Color(0xFF0A2463), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Sign in to your account", style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 32),
            _buildFormCard(authState, authNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(AuthState authState, AuthNotifier authNotifier) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !authState.isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !authState.isLoading,
            validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: _togglePasswordVisibility,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: authState.isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
                  : const Icon(Icons.login, color: Colors.white),
              label: Text(
                authState.isLoading ? 'Logging in...' : 'Login',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0A2463),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
              ),
              onPressed: authState.isLoading ? null : () => _submitForm(authNotifier),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: authState.isLoading ? null : () => context.go('/forgot-password'),
            child: const Text('Forgot Password?', style: TextStyle(color: Color(0xFF0A2463))),
          ),
          const SizedBox(height: 20),
          _buildSocialLoginButtons(authState, authNotifier),
          const SizedBox(height: 10),
          TextButton(
            onPressed: authState.isLoading ? null : () => context.go('/signup'),
            child: const Text("Don't have an account? Sign Up", style: TextStyle(color: Color(0xFF0A2463))),
          ),
          if (authState.error != null) ...[
            const SizedBox(height: 10),
            Text(authState.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons(AuthState authState, AuthNotifier authNotifier) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)),
            label: const Text('Continue with Google', style: TextStyle(color: Colors.black87)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: authState.isLoading ? null : () => authNotifier.googleSignIn(context),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2)),
            label: const Text('Continue with Facebook', style: TextStyle(color: Colors.black87)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: authState.isLoading ? null : () => authNotifier.facebookSignIn(context),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.black),
            label: const Text('Continue with Apple', style: TextStyle(color: Colors.black87)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: authState.isLoading ? null : () => authNotifier.appleSignIn(context),
          ),
        ),
      ],
    );
  }
}