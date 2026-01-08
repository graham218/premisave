import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';

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

    ref.listen(authProvider, (_, state) {
      if (state.token != null) {
        context.go(state.redirectUrl ?? '/verify');
      }
    });

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(controller: usernameCtrl, label: 'Username', hintText: 'Enter username'),
              CustomTextField(controller: firstNameCtrl, label: 'First Name', hintText: 'Enter first name'),
              CustomTextField(controller: middleNameCtrl, label: 'Middle Name', hintText: 'Optional'),
              CustomTextField(controller: lastNameCtrl, label: 'Last Name', hintText: 'Enter last name'),
              CustomTextField(controller: emailCtrl, label: 'Email', hintText: 'Enter email'),
              CustomTextField(controller: phoneCtrl, label: 'Phone Number', hintText: 'Enter phone number'),
              CustomTextField(controller: address1Ctrl, label: 'Address Line 1', hintText: 'Optional'),
              CustomTextField(controller: address2Ctrl, label: 'Address Line 2', hintText: 'Optional'),
              CustomTextField(controller: countryCtrl, label: 'Country', hintText: 'Optional'),
              CustomTextField(controller: languageCtrl, label: 'Language', hintText: 'Default: English'),
              CustomTextField(controller: passwordCtrl, label: 'Password', hintText: 'Enter password', obscureText: true),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Sign Up',
                onPressed: () {
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
              TextButton(onPressed: () => context.go('/login'), child: const Text('Already have account? Login')),
              if (authState.error != null) Text(authState.error!, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}