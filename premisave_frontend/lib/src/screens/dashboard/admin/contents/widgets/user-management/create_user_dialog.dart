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

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Username', 'username', required: true),
              const SizedBox(height: 12),
              _buildTextField('Email', 'email', keyboardType: TextInputType.emailAddress, required: true),
              const SizedBox(height: 12),
              _buildTextField('First Name', 'firstName', required: true),
              const SizedBox(height: 12),
              _buildTextField('Last Name', 'lastName', required: true),
              const SizedBox(height: 12),
              _buildTextField('Phone Number', 'phoneNumber', keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _buildTextField('Address 1', 'address1'),
              const SizedBox(height: 12),
              _buildTextField('Address 2', 'address2'),
              const SizedBox(height: 12),
              _buildTextField('Country', 'country'),
              const SizedBox(height: 12),
              _buildTextField('Password', 'password', obscureText: true, required: true),
              const SizedBox(height: 16),
              const Text('Select Role:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...Role.values.map((role) {
                final roleName = role.name.replaceAll('_', ' ').toUpperCase();
                return RadioListTile<Role>(
                  title: Text(roleName),
                  value: role,
                  groupValue: _selectedRole,
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createUser,
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (key == 'email' && !value.contains('@')) {
          return 'Enter a valid email';
        }
        if (key == 'password' && value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      } : null,
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