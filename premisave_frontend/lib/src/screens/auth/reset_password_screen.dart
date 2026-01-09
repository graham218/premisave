import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authProvider.notifier);
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: oldPasswordController,
              label: 'Old Password',
              hintText: 'Enter current password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: newPasswordController,
              label: 'New Password',
              hintText: 'Enter new password',
              obscureText: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'Confirm New Password',
              hintText: 'Confirm new password',
              obscureText: true,
            ),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Change Password',
              onPressed: () async {
                await authNotifier.changePassword(
                  oldPasswordController.text,
                  newPasswordController.text,
                  confirmPasswordController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
                context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}