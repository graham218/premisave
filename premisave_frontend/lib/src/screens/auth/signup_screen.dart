import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final isLargeScreen = MediaQuery.of(context).size.width > 700;

    // Listen for successful signup to redirect to login
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Redirect to login after successful signup
      if (next.shouldRedirectToLogin && !next.isLoading) {
        // Small delay to show the success toast first
        Future.delayed(const Duration(milliseconds: 500), () {
          context.go('/login');
        });
      }

      // Handle successful login redirect (keep existing logic)
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
    return _SignupFormLayout(
      authState: authState,
      authNotifier: authNotifier,
      child: (controllers, isLoading, formKey, toggleObscurePassword, obscurePassword, submitForm) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 1100, maxHeight: 700),
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
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.real_estate_agent, color: Colors.white, size: 70),
                        const SizedBox(height: 20),
                        const Text(
                          "Join Premisave Today",
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.3),
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
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _SignupFormContent(
                          controllers: controllers,
                          isLoading: isLoading,
                          formKey: formKey,
                          toggleObscurePassword: toggleObscurePassword,
                          obscurePassword: obscurePassword,
                          authState: authState,
                          authNotifier: authNotifier,
                          submitForm: submitForm,
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

  Widget _buildMobileLayout(BuildContext context, AuthState authState, AuthNotifier authNotifier) {
    return _SignupFormLayout(
      authState: authState,
      authNotifier: authNotifier,
      child: (controllers, isLoading, formKey, toggleObscurePassword, obscurePassword, submitForm) {
        return SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 6))],
            ),
            child: Column(
              children: [
                const Icon(Icons.real_estate_agent, color: Color(0xFF0A2463), size: 60),
                const SizedBox(height: 16),
                const Text(
                  "Create Your Account",
                  style: TextStyle(fontSize: 22, color: Color(0xFF0A2463), fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join Premisave to start your real estate investment journey",
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _SignupFormContent(
                  controllers: controllers,
                  isLoading: isLoading,
                  formKey: formKey,
                  toggleObscurePassword: toggleObscurePassword,
                  obscurePassword: obscurePassword,
                  authState: authState,
                  authNotifier: authNotifier,
                  submitForm: submitForm,
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

  Widget _buildFeatureRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13))),
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context, bool isLoading) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?", style: TextStyle(color: Colors.black54, fontSize: 13)),
        const SizedBox(width: 6),
        TextButton(
          onPressed: isLoading ? null : () => context.go('/login'),
          child: const Text('Login', style: TextStyle(color: Color(0xFF0A2463), fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}

class _SignupFormLayout extends StatefulWidget {
  final AuthState authState;
  final AuthNotifier authNotifier;
  final Widget Function(
      Map<String, TextEditingController> controllers,
      bool isLoading,
      GlobalKey<FormState> formKey,
      VoidCallback toggleObscurePassword,
      bool obscurePassword,
      VoidCallback submitForm,
      ) child;

  const _SignupFormLayout({
    required this.authState,
    required this.authNotifier,
    required this.child,
  });

  @override
  State<_SignupFormLayout> createState() => _SignupFormLayoutState();
}

class _SignupFormLayoutState extends State<_SignupFormLayout> {
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

  void _toggleObscurePassword() => setState(() => _obscurePassword = !_obscurePassword);

  void _submitForm() {
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
      widget.authNotifier.signUp(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child(
      controllers,
      widget.authState.isLoading,
      _formKey,
      _toggleObscurePassword,
      _obscurePassword,
      _submitForm,
    );
  }
}

class _SignupFormContent extends StatelessWidget {
  final Map<String, TextEditingController> controllers;
  final bool isLoading;
  final GlobalKey<FormState> formKey;
  final VoidCallback toggleObscurePassword;
  final bool obscurePassword;
  final AuthState authState;
  final AuthNotifier authNotifier;
  final VoidCallback submitForm;
  final bool isLargeScreen;

  const _SignupFormContent({
    required this.controllers,
    required this.isLoading,
    required this.formKey,
    required this.toggleObscurePassword,
    required this.obscurePassword,
    required this.authState,
    required this.authNotifier,
    required this.submitForm,
    required this.isLargeScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2463)),
          ),
          const SizedBox(height: 16),
          _buildTopRow(),
          const SizedBox(height: 12),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text("Full Name", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
          ),
          const SizedBox(height: 8),
          _buildNameFields(),
          const SizedBox(height: 16),
          const Text(
            "Contact Information",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2463)),
          ),
          const SizedBox(height: 12),
          _buildContactFields(),
          const SizedBox(height: 12),
          _buildAddress1Field(),
          const SizedBox(height: 12),
          _buildAddress2Field(),
          const SizedBox(height: 12),
          _buildCountryField(),
          const SizedBox(height: 16),
          const Text(
            "Account Security",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0A2463)),
          ),
          const SizedBox(height: 12),
          _buildPasswordField(),
          const SizedBox(height: 12),
          _buildPasswordRequirements(),
          const SizedBox(height: 20),
          const Text("Or sign up with", style: TextStyle(color: Colors.black54, fontSize: 13)),
          const SizedBox(height: 12),
          _buildSocialSignupButtons(context),
          const SizedBox(height: 20),
          _buildSubmitButton(),
          if (authState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(authState.error!, style: const TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }

  Widget _buildTopRow() {
    final usernameField = _buildTextField(
      controller: controllers['username']!,
      label: 'Username',
      hintText: 'Enter username',
      icon: Icons.person_outline,
      validator: (value) => value == null || value.isEmpty ? 'Username is required' : null,
    );

    final emailField = _buildTextField(
      controller: controllers['email']!,
      label: 'Email',
      hintText: 'Enter email',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
        return null;
      },
    );

    return isLargeScreen ? Row(children: [Expanded(child: usernameField), const SizedBox(width: 12), Expanded(child: emailField)])
        : Column(children: [usernameField, const SizedBox(height: 12), emailField]);
  }

  Widget _buildNameFields() {
    final firstNameField = _buildTextField(
      controller: controllers['firstName']!,
      label: 'First Name',
      hintText: 'Enter first name',
      icon: Icons.person_outline,
      validator: (value) => value == null || value.isEmpty ? 'First name is required' : null,
    );

    final middleNameField = _buildTextField(
      controller: controllers['middleName']!,
      label: 'Middle Name',
      hintText: 'Optional',
      icon: Icons.person_outline,
      isRequired: false,
    );

    final lastNameField = _buildTextField(
      controller: controllers['lastName']!,
      label: 'Last Name',
      hintText: 'Enter last name',
      icon: Icons.person_outline,
      validator: (value) => value == null || value.isEmpty ? 'Last name is required' : null,
    );

    return isLargeScreen
        ? Row(children: [Expanded(child: firstNameField), const SizedBox(width: 12), Expanded(child: middleNameField), const SizedBox(width: 12), Expanded(child: lastNameField)])
        : Column(children: [firstNameField, const SizedBox(height: 12), middleNameField, const SizedBox(height: 12), lastNameField]);
  }

  Widget _buildContactFields() {
    final phoneField = _buildTextField(
      controller: controllers['phone']!,
      label: 'Phone Number',
      hintText: 'Enter phone number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) => value == null || value.isEmpty ? 'Phone number is required' : null,
    );

    final languageField = _buildTextField(
      controller: controllers['language']!,
      label: 'Language',
      hintText: 'Default: English',
      icon: Icons.language_outlined,
    );

    return isLargeScreen ? Row(children: [Expanded(child: phoneField), const SizedBox(width: 12), Expanded(child: languageField)])
        : Column(children: [phoneField, const SizedBox(height: 12), languageField]);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: !isLoading,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
            errorMaxLines: 2,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAddress1Field() => _buildTextField(
    controller: controllers['address1']!,
    label: 'Address Line 1',
    hintText: 'Optional',
    icon: Icons.home_outlined,
    isRequired: false,
  );

  Widget _buildAddress2Field() => _buildTextField(
    controller: controllers['address2']!,
    label: 'Address Line 2',
    hintText: 'Optional',
    icon: Icons.home_outlined,
    isRequired: false,
  );

  Widget _buildCountryField() => _buildTextField(
    controller: controllers['country']!,
    label: 'Country',
    hintText: 'Optional',
    icon: Icons.location_on_outlined,
    isRequired: false,
  );

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Password', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)),
            Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controllers['password']!,
          obscureText: obscurePassword,
          enabled: !isLoading,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Password is required';
            if (value.length < 8) return 'Password must be at least 8 characters';
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])').hasMatch(value)) {
              return 'Password must include uppercase, lowercase, number and special character';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Enter secure password',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(obscurePassword ? Icons.visibility : Icons.visibility_off, size: 20),
              onPressed: toggleObscurePassword,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
            errorMaxLines: 2,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFf8f9fa),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Password Requirements:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0A2463))),
          const SizedBox(height: 6),
          _buildRequirementItem("At least 8 characters"),
          _buildRequirementItem("Mix of uppercase and lowercase"),
          _buildRequirementItem("Include numbers (0-9)"),
          _buildRequirementItem("Include special characters"),
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
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildSocialSignupButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.g_mobiledata, color: Color(0xFFDB4437), size: 20),
            label: const Text('Sign up with Google', style: TextStyle(color: Colors.black87, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.googleSignIn(context),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.facebook, color: Color(0xFF4267B2), size: 20),
            label: const Text('Sign up with Facebook', style: TextStyle(color: Colors.black87, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.facebookSignIn(context),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.apple, color: Colors.black, size: 20),
            label: const Text('Sign up with Apple', style: TextStyle(color: Colors.black87, fontSize: 14)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Colors.grey),
            ),
            onPressed: isLoading ? null : () => authNotifier.appleSignIn(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        )
            : const Icon(Icons.person_add, color: Colors.white, size: 20),
        label: Text(
          isLoading ? 'Creating Account...' : 'Create Account',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A2463),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 2,
        ),
        onPressed: isLoading ? null : submitForm,
      ),
    );
  }
}