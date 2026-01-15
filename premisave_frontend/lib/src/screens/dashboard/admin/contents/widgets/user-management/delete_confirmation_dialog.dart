import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final UserModel user;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.user,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.orange,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Are you sure you want to delete ${user.firstName} ${user.lastName}?',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone. All user data will be permanently deleted.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}