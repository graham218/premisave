import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class EditUserDialog extends StatefulWidget {
  final UserModel user;
  final Function(Map<String, dynamic>) onSave;

  const EditUserDialog({
    super.key,
    required this.user,
    required this.onSave,
  });

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, TextEditingController> _controllers;
  late Role _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
    _controllers = {
      'username': TextEditingController(text: widget.user.username),
      'email': TextEditingController(text: widget.user.email),
      'firstName': TextEditingController(text: widget.user.firstName),
      'lastName': TextEditingController(text: widget.user.lastName),
      'phoneNumber': TextEditingController(text: widget.user.phoneNumber),
      'address1': TextEditingController(text: widget.user.address1),
      'address2': TextEditingController(text: widget.user.address2),
      'country': TextEditingController(text: widget.user.country),
    };
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
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
          onPressed: _saveChanges,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String key, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: _controllers[key],
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: required ? (value) {
        if (value == null || value.isEmpty) {
          return '$label is required';
        }
        if (key == 'email' && !value.contains('@')) {
          return 'Enter a valid email';
        }
        return null;
      } : null,
    );
  }

  void _saveChanges() {
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
        'role': _selectedRole.name.toUpperCase(),
      };

      Navigator.pop(context);
      widget.onSave(userData);
    }
  }
}