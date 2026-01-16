import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/custom_text_field.dart';


class EditProfileForm extends ConsumerStatefulWidget {
  final VoidCallback onSuccess;
  final Map<String, String> initialData;

  const EditProfileForm({
    Key? key,
    required this.onSuccess,
    required this.initialData,
  }) : super(key: key);

  @override
  ConsumerState<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameCtrl;
  late TextEditingController _firstNameCtrl;
  late TextEditingController _middleNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _address1Ctrl;
  late TextEditingController _address2Ctrl;
  late TextEditingController _countryCtrl;
  late TextEditingController _languageCtrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _usernameCtrl = TextEditingController(text: widget.initialData['username'] ?? '');
    _firstNameCtrl = TextEditingController(text: widget.initialData['firstName'] ?? '');
    _middleNameCtrl = TextEditingController(text: widget.initialData['middleName'] ?? '');
    _lastNameCtrl = TextEditingController(text: widget.initialData['lastName'] ?? '');
    _phoneCtrl = TextEditingController(text: widget.initialData['phoneNumber'] ?? '');
    _address1Ctrl = TextEditingController(text: widget.initialData['address1'] ?? '');
    _address2Ctrl = TextEditingController(text: widget.initialData['address2'] ?? '');
    _countryCtrl = TextEditingController(text: widget.initialData['country'] ?? '');
    _languageCtrl = TextEditingController(text: widget.initialData['language'] ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _middleNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _countryCtrl.dispose();
    _languageCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authNotifier = ref.read(authProvider.notifier);
      final data = {
        'username': _usernameCtrl.text.trim(),
        'firstName': _firstNameCtrl.text.trim(),
        'middleName': _middleNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'address1': _address1Ctrl.text.trim(),
        'address2': _address2Ctrl.text.trim(),
        'country': _countryCtrl.text.trim(),
        'language': _languageCtrl.text.trim(),
      };
      authNotifier.updateProfile(data);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [Colors.grey[900]!, Colors.grey[850]!]
              : [Colors.white, Colors.grey[50]!],
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(theme, Icons.person, 'Basic Information'),
              const SizedBox(height: 16),
              _buildTextFieldRow(
                left: CustomTextField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  hintText: 'Enter first name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (value) => value!.isEmpty ? 'First name is required' : null,
                ),
                right: CustomTextField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  hintText: 'Enter last name',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _usernameCtrl,
                label: 'Username',
                hintText: 'Enter username',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _middleNameCtrl,
                label: 'Middle Name (Optional)',
                hintText: 'Enter middle name',
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(theme, Icons.contact_phone, 'Contact Details'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                hintText: 'Enter phone number',
                prefixIcon: const Icon(Icons.phone_rounded),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(theme, Icons.home, 'Address Information'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _address1Ctrl,
                label: 'Address Line 1',
                hintText: 'Enter primary address',
                prefixIcon: const Icon(Icons.home_rounded),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _address2Ctrl,
                label: 'Address Line 2 (Optional)',
                hintText: 'Apartment, suite, etc.',
                prefixIcon: const Icon(Icons.home_work_rounded),
              ),
              _buildTextFieldRow(
                left: CustomTextField(
                  controller: _countryCtrl,
                  label: 'Country',
                  hintText: 'Enter country',
                  prefixIcon: const Icon(Icons.location_on_rounded),
                ),
                right: CustomTextField(
                  controller: _languageCtrl,
                  label: 'Language',
                  hintText: 'e.g., English',
                  prefixIcon: const Icon(Icons.language_rounded),
                ),
              ),
              const SizedBox(height: 32),
              _buildActionButtons(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldRow({required Widget left, required Widget right}) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurface.withOpacity(0.6),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: theme.dividerColor),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_rounded, size: 20),
                SizedBox(width: 8),
                Text('Save Changes'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}