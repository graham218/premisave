import 'package:flutter/material.dart';
import '../../../../../../models/auth/user_model.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailsDialog({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUserProfile(),
              const SizedBox(height: 24),
              _buildStatusBadges(),
              const SizedBox(height: 24),
              _buildPersonalDetails(),
              const SizedBox(height: 16),
              _buildAddressDetails(),
              const SizedBox(height: 24),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.person_outline, color: Color(0xFF0D47A1), size: 28),
        const SizedBox(width: 12),
        const Text('User Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
      ],
    );
  }

  Widget _buildUserProfile() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              user.firstName.isNotEmpty && user.lastName.isNotEmpty
                  ? '${user.firstName[0]}${user.lastName[0]}'
                  : '?',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${user.firstName} ${user.lastName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(user.email, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text('@${user.username}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildBadge(user.role.name.replaceAll('_', ' ').toUpperCase(), _getRoleColor(user.role.name)),
        _buildBadge(user.active ? 'ACTIVE' : 'INACTIVE', user.active ? Colors.green : Colors.red),
        _buildBadge(user.verified ? 'VERIFIED' : 'UNVERIFIED', user.verified ? Colors.blue : Colors.orange),
      ],
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPersonalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Personal Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 16),
        _buildDetailRow('Phone Number', user.phoneNumber, Icons.phone_outlined),
        _buildDetailRow('Language', user.language, Icons.language_outlined),
        _buildDetailRow('Country', user.country, Icons.location_on_outlined),
      ],
    );
  }

  Widget _buildAddressDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Address Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
        const SizedBox(height: 16),
        _buildDetailRow('Address Line 1', user.address1, Icons.home_outlined),
        _buildDetailRow('Address Line 2', user.address2, Icons.home_outlined),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value.isNotEmpty ? value : 'Not set', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D47A1),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Close', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin': return Colors.red;
      case 'client': return Colors.green;
      case 'home_owner': return Colors.blue;
      case 'operations': return Colors.orange;
      case 'finance': return Colors.purple;
      case 'support': return Colors.teal;
      default: return Colors.grey;
    }
  }
}