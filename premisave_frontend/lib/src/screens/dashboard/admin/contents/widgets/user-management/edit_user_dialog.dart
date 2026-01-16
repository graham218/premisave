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
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                _buildHeader(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 16),
                _buildContactInfoSection(),
                const SizedBox(height: 16),
                _buildRoleSelection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.edit, color: Color(0xFF0D47A1), size: 28),
        const SizedBox(width: 12),
        const Text('Edit User', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Username', 'username', Icons.person_outline, required: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Email', 'email', Icons.email_outlined, required: true, keyboardType: TextInputType.emailAddress)),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Full Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildTextField('First Name', 'firstName', Icons.person_outline, required: true)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Last Name', 'lastName', Icons.person_outline, required: true)),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Contact Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField('Phone', 'phoneNumber', Icons.phone_outlined, keyboardType: TextInputType.phone)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('Country', 'country', Icons.location_on_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField('Address 1', 'address1', Icons.home_outlined),
        const SizedBox(height: 12),
        _buildTextField('Address 2', 'address2', Icons.home_outlined),
      ],
    );
  }

  Widget _buildRoleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Role', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Role.values.map((role) {
            final roleName = role.name.replaceAll('_', ' ').toUpperCase();
            return ChoiceChip(
              label: Text(roleName),
              selected: _selectedRole == role,
              onSelected: (selected) => setState(() => _selectedRole = role),
              selectedColor: const Color(0xFF0D47A1),
              labelStyle: TextStyle(color: _selectedRole == role ? Colors.white : Colors.black, fontWeight: FontWeight.w500),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, String key, IconData icon, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.grey)),
            if (required) const Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: _controllers[key],
          keyboardType: keyboardType,
          validator: required ? (value) {
            if (value == null || value.isEmpty) return '$label is required';
            if (key == 'email' && !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Enter a valid email';
            return null;
          } : null,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            isDense: true,
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ],
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