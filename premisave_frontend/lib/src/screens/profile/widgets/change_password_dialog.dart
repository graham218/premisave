import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool _validatePassword(String? password) {
    if (password == null || password.isEmpty) return false;
    if (password.length < 8) return false;
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])').hasMatch(password)) {
      return false;
    }
    return true;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])').hasMatch(value)) {
      return 'Include uppercase, lowercase, number & special char';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).changePassword(
        _oldPasswordCtrl.text,
        _newPasswordCtrl.text,
        _confirmPasswordCtrl.text,
      );

      final authState = ref.read(authProvider);
      if (!authState.isLoading && authState.error == null && context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.lock_rounded),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: onToggleObscure,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_rounded, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text('Change Password',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                ],
              ),
              const SizedBox(height: 20),
              _buildPasswordField(
                controller: _oldPasswordCtrl,
                label: 'Current Password',
                obscureText: _obscureOldPassword,
                onToggleObscure: () => setState(() => _obscureOldPassword = !_obscureOldPassword),
                validator: (value) => value == null || value.isEmpty ? 'Current password is required' : null,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _newPasswordCtrl,
                label: 'New Password',
                obscureText: _obscureNewPassword,
                onToggleObscure: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                controller: _confirmPasswordCtrl,
                label: 'Confirm New Password',
                obscureText: _obscureConfirmPassword,
                onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please confirm password';
                  if (value != _newPasswordCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Password Requirements:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                    const SizedBox(height: 6),
                    _buildRequirement('At least 8 characters', _newPasswordCtrl.text.length >= 8),
                    _buildRequirement('Uppercase letter', RegExp(r'[A-Z]').hasMatch(_newPasswordCtrl.text)),
                    _buildRequirement('Lowercase letter', RegExp(r'[a-z]').hasMatch(_newPasswordCtrl.text)),
                    _buildRequirement('Number', RegExp(r'\d').hasMatch(_newPasswordCtrl.text)),
                    _buildRequirement('Special character', RegExp(r'[\W_]').hasMatch(_newPasswordCtrl.text)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authState.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authState.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('Update'),
                    ),
                  ),
                ],
              ),
              if (authState.error != null) ...[
                const SizedBox(height: 12),
                Text(authState.error!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(isValid ? Icons.check_circle : Icons.circle_outlined,
              color: isValid ? Colors.green : Colors.grey, size: 14),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, color: isValid ? Colors.green : Colors.grey)),
        ],
      ),
    );
  }
}