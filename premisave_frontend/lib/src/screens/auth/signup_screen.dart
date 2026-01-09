import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    final usernameCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final middleNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final address1Ctrl = TextEditingController();
    final address2Ctrl = TextEditingController();
    final countryCtrl = TextEditingController();
    final languageCtrl = TextEditingController(text: 'English');
    final passwordCtrl = TextEditingController();

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
                ? _buildWideLayout(
              context,
              authState.isLoading,
              usernameCtrl,
              firstNameCtrl,
              middleNameCtrl,
              lastNameCtrl,
              emailCtrl,
              phoneCtrl,
              address1Ctrl,
              address2Ctrl,
              countryCtrl,
              languageCtrl,
              passwordCtrl,
              authNotifier,
              authState,
            )
                : _buildMobileLayout(
              context,
              authState.isLoading,
              usernameCtrl,
              firstNameCtrl,
              middleNameCtrl,
              lastNameCtrl,
              emailCtrl,
              phoneCtrl,
              address1Ctrl,
              address2Ctrl,
              countryCtrl,
              languageCtrl,
              passwordCtrl,
              authNotifier,
              authState,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
      BuildContext context,
      bool isLoading,
      TextEditingController usernameCtrl,
      TextEditingController firstNameCtrl,
      TextEditingController middleNameCtrl,
      TextEditingController lastNameCtrl,
      TextEditingController emailCtrl,
      TextEditingController phoneCtrl,
      TextEditingController address1Ctrl,
      TextEditingController address2Ctrl,
      TextEditingController countryCtrl,
      TextEditingController languageCtrl,
      TextEditingController passwordCtrl,
      AuthNotifier authNotifier,
      AuthState authState,
      ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool obscurePassword = true;

        return Container(
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 700),
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
                          "Join Premisave Today",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Create your account to start investing in real estate. "
                              "Track properties, manage portfolios, and build your financial future with us.",
                          style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("Secure investment tracking", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("Real-time property updates", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white70, size: 20),
                            SizedBox(width: 10),
                            Text("Portfolio management tools", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right side - Signup Form
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        _buildFormSection(
                          context,
                          isLoading,
                          obscurePassword,
                              () => setState(() => obscurePassword = !obscurePassword),
                          usernameCtrl,
                          firstNameCtrl,
                          middleNameCtrl,
                          lastNameCtrl,
                          emailCtrl,
                          phoneCtrl,
                          address1Ctrl,
                          address2Ctrl,
                          countryCtrl,
                          languageCtrl,
                          passwordCtrl,
                          authNotifier,
                          authState,
                        ),
                        const SizedBox(height: 20),
                        _buildLoginLink(context, isLoading),
                      ],
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
      TextEditingController usernameCtrl,
      TextEditingController firstNameCtrl,
      TextEditingController middleNameCtrl,
      TextEditingController lastNameCtrl,
      TextEditingController emailCtrl,
      TextEditingController phoneCtrl,
      TextEditingController address1Ctrl,
      TextEditingController address2Ctrl,
      TextEditingController countryCtrl,
      TextEditingController languageCtrl,
      TextEditingController passwordCtrl,
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
                const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 70),
                const SizedBox(height: 16),
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 26,
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join Premisave to start your real estate investment journey",
                  style: TextStyle(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildFormSection(
                  context,
                  isLoading,
                  obscurePassword,
                      () => setState(() => obscurePassword = !obscurePassword),
                  usernameCtrl,
                  firstNameCtrl,
                  middleNameCtrl,
                  lastNameCtrl,
                  emailCtrl,
                  phoneCtrl,
                  address1Ctrl,
                  address2Ctrl,
                  countryCtrl,
                  languageCtrl,
                  passwordCtrl,
                  authNotifier,
                  authState,
                ),
                const SizedBox(height: 20),
                _buildLoginLink(context, isLoading),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormSection(
      BuildContext context,
      bool isLoading,
      bool obscurePassword,
      VoidCallback toggleObscurePassword,
      TextEditingController usernameCtrl,
      TextEditingController firstNameCtrl,
      TextEditingController middleNameCtrl,
      TextEditingController lastNameCtrl,
      TextEditingController emailCtrl,
      TextEditingController phoneCtrl,
      TextEditingController address1Ctrl,
      TextEditingController address2Ctrl,
      TextEditingController countryCtrl,
      TextEditingController languageCtrl,
      TextEditingController passwordCtrl,
      AuthNotifier authNotifier,
      AuthState authState,
      ) {
    return Column(
      children: [
        // Personal Information Section
        const Text(
          "Personal Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 16),

        // Username and Email Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: usernameCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Name Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: firstNameCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter first name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: middleNameCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Middle Name',
                  hintText: 'Optional',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: lastNameCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter last name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Contact Information Section
        const SizedBox(height: 20),
        const Text(
          "Contact Information",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 16),

        // Phone and Language Row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter phone number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: languageCtrl,
                enabled: !isLoading,
                decoration: InputDecoration(
                  labelText: 'Language',
                  hintText: 'Default: English',
                  prefixIcon: const Icon(Icons.language_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Address Row
        TextField(
          controller: address1Ctrl,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Address Line 1',
            hintText: 'Optional',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: address2Ctrl,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Address Line 2',
            hintText: 'Optional',
            prefixIcon: const Icon(Icons.home_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: countryCtrl,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Country',
            hintText: 'Optional',
            prefixIcon: const Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Password Section
        const SizedBox(height: 20),
        const Text(
          "Account Security",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 16),

        TextField(
          controller: passwordCtrl,
          obscureText: obscurePassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Password',
            hintText: 'Enter password',
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

        // Social Signup Section
        const SizedBox(height: 24),
        const Text(
          "Or sign up with",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),

        _buildSocialSignupButtons(context, authNotifier, isLoading),

        // Sign Up Button
        const SizedBox(height: 24),
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
                : const Icon(Icons.person_add, color: Colors.white),
            label: Text(
              isLoading ? 'Creating Account...' : 'Create Account',
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
                : () {
              final data = {
                'username': usernameCtrl.text,
                'firstName': firstNameCtrl.text,
                'middleName': middleNameCtrl.text,
                'lastName': lastNameCtrl.text,
                'email': emailCtrl.text,
                'phoneNumber': phoneCtrl.text,
                'address1': address1Ctrl.text,
                'address2': address2Ctrl.text,
                'country': countryCtrl.text,
                'language': languageCtrl.text,
                'password': passwordCtrl.text,
              };
              authNotifier.signUp(data);
            },
          ),
        ),

        // Error Message
        if (authState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              authState.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildSocialSignupButtons(BuildContext context, AuthNotifier authNotifier, bool isLoading) {
    return Column(
      children: [
        // Google Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437)),
            label: const Text(
              'Sign up with Google',
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

        // Facebook Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2)),
            label: const Text(
              'Sign up with Facebook',
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

        // Apple Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.black),
            label: const Text(
              'Sign up with Apple',
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

  Widget _buildLoginLink(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account?",
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Color(0xFF0A2463),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}