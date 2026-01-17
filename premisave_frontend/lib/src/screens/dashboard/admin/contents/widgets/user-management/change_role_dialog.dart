import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class ChangeRoleDialog extends StatefulWidget {
  final UserModel user;
  final Function(String) onChange;
  const ChangeRoleDialog({super.key, required this.user, required this.onChange});

  @override
  State<ChangeRoleDialog> createState() => _ChangeRoleDialogState();
}

class _ChangeRoleDialogState extends State<ChangeRoleDialog> {
  late Role _selectedRole;

  // Updated with your actual roles
  final Map<Role, IconData> _roleIcons = {
    Role.client: Icons.person,
    Role.homeOwner: Icons.home,
    Role.admin: Icons.admin_panel_settings,
    Role.operations: Icons.build,
    Role.finance: Icons.attach_money,
    Role.support: Icons.support_agent,
  };

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role;
  }

  String _formatRoleName(Role role) {
    final name = role.name;
    if (name == 'homeOwner') return 'Home Owner';
    return name[0].toUpperCase() + name.substring(1);
  }

  // Convert role to backend format
  String _convertRoleToBackendFormat(Role role) {
    switch (role) {
      case Role.homeOwner:
        return 'HOME_OWNER'; // Add underscore for backend
      default:
        return role.name.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Change User Role', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('${widget.user.firstName} ${widget.user.lastName}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7))),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: Role.values.map((role) {
            final isSelected = _selectedRole == role;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: isSelected ? theme.primaryColor : theme.dividerColor),
              ),
              child: ListTile(
                leading: Icon(_roleIcons[role], color: isSelected ? theme.primaryColor : null),
                title: Text(_formatRoleName(role),
                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                trailing: isSelected ? Icon(Icons.check, color: theme.primaryColor) : null,
                onTap: () => setState(() => _selectedRole = role),
              ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
            if (_selectedRole != widget.user.role) {
              // Use the conversion function
              widget.onChange(_convertRoleToBackendFormat(_selectedRole));
            }
          },
          child: const Text('Update Role'),
        ),
      ],
    );
  }
}