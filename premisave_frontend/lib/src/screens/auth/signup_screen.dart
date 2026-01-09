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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.real_estate_agent, color: Colors.white, size: 70),
                        const SizedBox(height: 20),
                        const Text(
                          "Join Premisave Today",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Create your account to start investing in real estate. "
                              "Track properties, manage portfolios, and build your financial future.",
                          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                        _buildFeatureRow("Secure investment tracking"),
                        const SizedBox(height: 10),
                        _buildFeatureRow("Real-time property updates"),
                        const SizedBox(height: 10),
                        _buildFeatureRow("Portfolio management tools"),
                      ],
                    ),
                  ),
                ),
              ),

              // Right side - Signup Form
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                          isLargeScreen: true,
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

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
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
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
                const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(0xFF0A2463),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join Premisave to start your real estate investment journey",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
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
                  isLargeScreen: false,
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
      {required bool isLargeScreen}
      ) {
    return Column(
      children: [
        // Personal Information Section
        const Text(
          "Personal Information",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 16),

        // Username and Email - Stack vertically on mobile
        if (isLargeScreen)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: usernameCtrl,
                  label: 'Username',
                  hintText: 'Enter username',
                  icon: Icons.person_outline,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: emailCtrl,
                  label: 'Email',
                  hintText: 'Enter email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isLoading: isLoading,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTextField(
                controller: usernameCtrl,
                label: 'Username',
                hintText: 'Enter username',
                icon: Icons.person_outline,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: emailCtrl,
                label: 'Email',
                hintText: 'Enter email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isLoading: isLoading,
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Name Fields - Stacked on mobile, row on desktop
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Full Name",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (isLargeScreen)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: firstNameCtrl,
                  label: 'First Name',
                  hintText: 'Enter first name',
                  icon: Icons.person_outline,
                  isLoading: isLoading,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: middleNameCtrl,
                  label: 'Middle Name',
                  hintText: 'Optional',
                  icon: Icons.person_outline,
                  isLoading: isLoading,
                  isRequired: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: lastNameCtrl,
                  label: 'Last Name',
                  hintText: 'Enter last name',
                  icon: Icons.person_outline,
                  isLoading: isLoading,
                  isRequired: true,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTextField(
                controller: firstNameCtrl,
                label: 'First Name',
                hintText: 'Enter first name',
                icon: Icons.person_outline,
                isLoading: isLoading,
                isRequired: true,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: middleNameCtrl,
                label: 'Middle Name',
                hintText: 'Optional',
                icon: Icons.person_outline,
                isLoading: isLoading,
                isRequired: false,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: lastNameCtrl,
                label: 'Last Name',
                hintText: 'Enter last name',
                icon: Icons.person_outline,
                isLoading: isLoading,
                isRequired: true,
              ),
            ],
          ),

        // Contact Information Section
        const SizedBox(height: 16),
        const Text(
          "Contact Information",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 12),

        // Phone and Language - Stack vertically on mobile
        if (isLargeScreen)
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: phoneCtrl,
                  label: 'Phone Number',
                  hintText: 'Enter phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isLoading: isLoading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: languageCtrl,
                  label: 'Language',
                  hintText: 'Default: English',
                  icon: Icons.language_outlined,
                  isLoading: isLoading,
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              _buildTextField(
                controller: phoneCtrl,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isLoading: isLoading,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: languageCtrl,
                label: 'Language',
                hintText: 'Default: English',
                icon: Icons.language_outlined,
                isLoading: isLoading,
              ),
            ],
          ),

        const SizedBox(height: 12),

        // Address Fields
        _buildTextField(
          controller: address1Ctrl,
          label: 'Address Line 1',
          hintText: 'Optional',
          icon: Icons.home_outlined,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: address2Ctrl,
          label: 'Address Line 2',
          hintText: 'Optional',
          icon: Icons.home_outlined,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: countryCtrl,
          label: 'Country',
          hintText: 'Optional',
          icon: Icons.location_on_outlined,
          isLoading: isLoading,
        ),

        // Password Section
        const SizedBox(height: 16),
        const Text(
          "Account Security",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0A2463),
          ),
        ),
        const SizedBox(height: 12),

        _buildPasswordField(
          controller: passwordCtrl,
          obscurePassword: obscurePassword,
          toggleObscurePassword: toggleObscurePassword,
          isLoading: isLoading,
        ),

        // Password Requirements
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFf8f9fa),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Password Requirements:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF0A2463),
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

        // Social Signup Section
        const SizedBox(height: 20),
        const Text(
          "Or sign up with",
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(height: 12),

        _buildSocialSignupButtons(context, authNotifier, isLoading),

        // Sign Up Button
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: isLoading
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Icon(Icons.person_add, color: Colors.white, size: 20),
            label: Text(
              isLoading ? 'Creating Account...' : 'Create Account',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A2463),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
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
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isLoading = false,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscurePassword,
    required VoidCallback toggleObscurePassword,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscurePassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Enter secure password',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: toggleObscurePassword,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 12,
            ),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSignupButtons(BuildContext context, AuthNotifier authNotifier, bool isLoading) {
    return Column(
      children: [
        // Google Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 20),
            label: const Text(
              'Sign up with Google',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.googleSignIn(context),
          ),
        ),

        const SizedBox(height: 8),

        // Facebook Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2), size: 20),
            label: const Text(
              'Sign up with Facebook',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.facebookSignIn(context),
          ),
        ),

        const SizedBox(height: 8),

        // Apple Sign Up
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.black, size: 20),
            label: const Text(
              'Sign up with Apple',
              style: TextStyle(color: Colors.black87, fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
          style: TextStyle(color: Colors.black54, fontSize: 13),
        ),
        const SizedBox(width: 6),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          child: const Text(
            'Login',
            style: TextStyle(
              color: Color(0xFF0A2463),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}