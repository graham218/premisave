import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

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
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.token != null && next.redirectUrl != null && !next.isLoading) {
        context.go(next.redirectUrl!);
      }
    });

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
            child: isWideScreen ? _buildWideLayout(authState, authNotifier) : _buildMobileLayout(authState, authNotifier),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(AuthState authState, AuthNotifier authNotifier) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        height: 600, // Fixed height for large screens
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
                            "Welcome to Premisave",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your gateway to smart real estate investments.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSocialLoginButtons(authState, authNotifier),
                  ],
                ),
              ),
            ),
            Container(
              width: 400, // Fixed width for form
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
                child: _buildForm(authState, authNotifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AuthState authState, AuthNotifier authNotifier) {
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
                      "Welcome to Premisave",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Sign in to your account",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildForm(authState, authNotifier),
              const SizedBox(height: 16),
              _buildSocialLoginButtons(authState, authNotifier),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(AuthState authState, AuthNotifier authNotifier) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null || !value.contains('@') ? 'Enter valid email' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: _togglePasswordVisibility,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Password required' : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : () => _submitForm(authNotifier),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: authState.isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                  : Text('Login', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => context.go('/signup'),
                child: Text("Sign Up", style: TextStyle(color: Colors.green[700])),
              ),
              TextButton(
                onPressed: () => context.go('/forgot-password'),
                child: Text("Forgot Password?", style: TextStyle(color: Colors.blue[700])),
              ),
            ],
          ),
          if (authState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Text(authState.error!, style: TextStyle(color: Colors.red[700])),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons(AuthState authState, AuthNotifier authNotifier) {
    final buttons = [
      _buildSocialButton('Google', Icons.g_mobiledata, Colors.red, () => authNotifier.googleSignIn(context)),
      _buildSocialButton('Facebook', Icons.facebook, Colors.blue, () => authNotifier.facebookSignIn(context)),
      _buildSocialButton('Apple', Icons.apple, Colors.black, () => authNotifier.appleSignIn(context)),
    ];

    return Column(
      children: [
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        Text("Or continue with", style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buttons,
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }
}