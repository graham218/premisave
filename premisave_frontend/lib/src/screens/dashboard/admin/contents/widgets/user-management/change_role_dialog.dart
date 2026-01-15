import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class ChangeRoleDialog extends StatefulWidget {
  final UserModel user;
  final Function(String) onChange;

  const ChangeRoleDialog({
    super.key,
    required this.user,
    required this.onChange,
  });

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late Role _selectedRole;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change User Role'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Role.values.map((role) {
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_selectedRole != widget.user.role) {
              Navigator.pop(context);
              widget.onChange(_selectedRole.name.toUpperCase());
            }
          },
          child: const Text('Change Role'),
        ),
      ],
    );
  }
}