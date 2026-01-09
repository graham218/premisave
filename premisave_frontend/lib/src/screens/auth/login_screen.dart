import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_login_button.dart';
import '../../widgets/loading_overlay.dart';

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

    return Scaffold(
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextField(controller: emailController, label: 'Email', hintText: 'Enter your email'),
              CustomTextField(controller: passwordController, label: 'Password', hintText: 'Enter your password', obscureText: true),
              const SizedBox(height: 20),
              CustomButton(
                text: 'Login',
                onPressed: () => authNotifier.signIn(emailController.text.trim(), passwordController.text),
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () => context.go('/forgot-password'), child: const Text('Forgot Password?')),
              const SizedBox(height: 20),
              SocialLoginButton(icon: 'google.png', onPressed: () => authNotifier.googleSignIn(context)),
              SocialLoginButton(icon: 'facebook.png', onPressed: () => authNotifier.facebookSignIn(context)),
              SocialLoginButton(icon: 'apple.png', onPressed: () => authNotifier.appleSignIn(context)),
              const SizedBox(height: 10),
              TextButton(onPressed: () => context.go('/signup'), child: const Text('Don\'t have an account? Sign Up')),
              if (authState.error != null) Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}