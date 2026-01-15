import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class CreateUserDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;

  const CreateUserDialog({
    super.key,
    required this.onCreate,
  });

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'username': TextEditingController(),
    'email': TextEditingController(),
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'phoneNumber': TextEditingController(),
    'password': TextEditingController(),
    'address1': TextEditingController(),
    'address2': TextEditingController(),
    'country': TextEditingController(),
  };
  Role _selectedRole = Role.client;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Row(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Color(0xFF0D47A1),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Create New User',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fill in the details to create a new user account',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Personal Information Section
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 16),

                // Username and Email Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Username',
                        'username',
                        Icons.person_outline,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Email',
                        'email',
                        Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Name Row
                const Text(
                  'Full Name',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'First Name',
                        'firstName',
                        Icons.person_outline,
                        required: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Last Name',
                        'lastName',
                        Icons.person_outline,
                        required: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Contact Information Section
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 16),

                // Phone and Country Row
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Phone Number',
                        'phoneNumber',
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        'Country',
                        'country',
                        Icons.location_on_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Address Fields
                _buildTextField(
                  'Address Line 1',
                  'address1',
                  Icons.home_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'Address Line 2',
                  'address2',
                  Icons.home_outlined,
                ),
                const SizedBox(height: 16),

                // Account Security Section
                const Text(
                  'Account Security',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field with Requirements
                _buildPasswordField(),
                const SizedBox(height: 12),
                _buildPasswordRequirements(),
                const SizedBox(height: 16),

                // Role Selection
                const Text(
                  'Select Role',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: Role.values.map((role) {
                    final roleName = role.name.replaceAll('_', ' ').toUpperCase();
                    return ChoiceChip(
                      label: Text(roleName),
                      selected: _selectedRole == role,
                      onSelected: (selected) {
                        setState(() {
                          _selectedRole = role;
                        });
                      },
                      selectedColor: const Color(0xFF0D47A1),
                      labelStyle: TextStyle(
                        color: _selectedRole == role ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Create User'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label,
      String key,
      IconData icon, {
        bool required = false,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            if (required)
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
        TextFormField(
          controller: _controllers[key],
          keyboardType: keyboardType,
          validator: required
              ? (value) {
            if (value == null || value.isEmpty) {
              return '$label is required';
            }
            if (key == 'email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          }
              : null,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
            errorMaxLines: 2,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
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
        TextFormField(
          controller: _controllers['password'],
          obscureText: _obscurePassword,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
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
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
          const Text(
            'Password Requirements:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF0A2463),
            ),
          ),
          const SizedBox(height: 6),
          _buildRequirementItem('At least 8 characters'),
          _buildRequirementItem('Mix of uppercase and lowercase letters'),
          _buildRequirementItem('Include numbers (0-9)'),
          _buildRequirementItem('Include special characters (e.g., @#\$%^&*)'),
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
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 14,
          ),
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

  void _createUser() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'username': _controllers['username']!.text,
        'email': _controllers['email']!.text,
        'firstName': _controllers['firstName']!.text,
        'lastName': _controllers['lastName']!.text,
        'phoneNumber': _controllers['phoneNumber']!.text,
        'address1': _controllers['address1']!.text,
        'address2': _controllers['address2']!.text,
        'country': _controllers['country']!.text,
        'password': _controllers['password']!.text,
        'role': _selectedRole.name.toUpperCase(),
      };

      Navigator.pop(context);
      widget.onCreate(userData);
    }
  }
}