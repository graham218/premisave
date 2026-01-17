import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  late final Map<String, TextEditingController> controllers;
  late final GlobalKey<FormState> _formKey;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    controllers = {
      'username': TextEditingController(),
      'firstName': TextEditingController(),
      'middleName': TextEditingController(),
      'lastName': TextEditingController(),
      'email': TextEditingController(),
      'phone': TextEditingController(),
      'address1': TextEditingController(),
      'address2': TextEditingController(),
      'country': TextEditingController(),
      'language': TextEditingController(text: 'English'),
      'password': TextEditingController(),
    };
  }

  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _togglePasswordVisibility() => setState(() => _obscurePassword = !_obscurePassword);

  void _submitForm(AuthNotifier authNotifier) {
    if (_formKey.currentState!.validate()) {
      final data = {
        'username': controllers['username']!.text,
        'firstName': controllers['firstName']!.text,
        'middleName': controllers['middleName']!.text,
        'lastName': controllers['lastName']!.text,
        'email': controllers['email']!.text,
        'phoneNumber': controllers['phone']!.text,
        'address1': controllers['address1']!.text,
        'address2': controllers['address2']!.text,
        'country': controllers['country']!.text,
        'language': controllers['language']!.text,
        'password': controllers['password']!.text,
      };
      authNotifier.signUp(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    ref.listen<AuthState>(authProvider, (_, next) {
      if (next.shouldRedirectToLogin && !next.isLoading) {
        Future.delayed(const Duration(milliseconds: 500), () {
          context.go('/login');
        });
      }

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
        height: 700, // Slightly taller for signup
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
                            "Join Premisave Today",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Create your account to start investing in real estate.",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          _buildFeatureRow("Secure investment tracking"),
                          const SizedBox(height: 10),
                          _buildFeatureRow("Real-time property updates"),
                          const SizedBox(height: 10),
                          _buildFeatureRow("Portfolio management tools"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildSocialSignupButtons(authState, authNotifier),
                  ],
                ),
              ),
            ),
            Container(
              width: 500, // Wider for signup form
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
                child: _buildForm(authState, authNotifier, true),
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
                      "Join Premisave",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Create your account",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildForm(authState, authNotifier, false),
              const SizedBox(height: 16),
              _buildSocialSignupButtons(authState, authNotifier),
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

  Widget _buildForm(AuthState authState, AuthNotifier authNotifier, bool isWideScreen) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personal Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 16),

          // Username
          TextFormField(
            controller: controllers['username'],
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
          ),
          const SizedBox(height: 12),

          // Name Fields
          if (isWideScreen)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers['firstName'],
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'First name is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['middleName'],
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Middle Name (Optional)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['lastName'],
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Last name is required' : null,
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                TextFormField(
                  controller: controllers['firstName'],
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'First name is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers['middleName'],
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Middle Name (Optional)',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers['lastName'],
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Last name is required' : null,
                ),
              ],
            ),

          const SizedBox(height: 16),
          Text(
            "Contact Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),

          // Email
          TextFormField(
            controller: controllers['email'],
            keyboardType: TextInputType.emailAddress,
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Phone and Language
          if (isWideScreen)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controllers['phone'],
                    keyboardType: TextInputType.phone,
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: controllers['language'],
                    enabled: !authState.isLoading,
                    decoration: InputDecoration(
                      labelText: 'Language',
                      prefixIcon: const Icon(Icons.language_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                TextFormField(
                  controller: controllers['phone'],
                  keyboardType: TextInputType.phone,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controllers['language'],
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    labelText: 'Language',
                    prefixIcon: const Icon(Icons.language_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12),
          TextFormField(
            controller: controllers['address1'],
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Address Line 1 (Optional)',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controllers['address2'],
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Address Line 2 (Optional)',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controllers['country'],
            enabled: !authState.isLoading,
            decoration: InputDecoration(
              labelText: 'Country (Optional)',
              prefixIcon: const Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            "Account Security",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.green[800],
            ),
          ),
          const SizedBox(height: 12),

          // Password
          TextFormField(
            controller: controllers['password'],
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
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 8) return 'Password must be at least 8 characters';
              if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])').hasMatch(value)) {
                return 'Password must include uppercase, lowercase, number and special character';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Password Requirements
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Password Requirements:",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
                const SizedBox(height: 6),
                _buildRequirementItem("At least 8 characters"),
                _buildRequirementItem("Mix of uppercase and lowercase"),
                _buildRequirementItem("Include numbers (0-9)"),
                _buildRequirementItem("Include special characters"),
              ],
            ),
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
                  : Text('Create Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text("Login", style: TextStyle(color: Colors.green[700])),
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

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green[600], size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _buildSocialSignupButtons(AuthState authState, AuthNotifier authNotifier) {
    final buttons = [
      _buildSocialButton('Google', Icons.g_mobiledata, Colors.red, () => authNotifier.googleSignIn(context)),
      _buildSocialButton('Facebook', Icons.facebook, Colors.blue, () => authNotifier.facebookSignIn(context)),
      _buildSocialButton('Apple', Icons.apple, Colors.black, () => authNotifier.appleSignIn(context)),
    ];

    return Column(
      children: [
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        Text("Or sign up with", style: TextStyle(color: Colors.grey[600])),
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