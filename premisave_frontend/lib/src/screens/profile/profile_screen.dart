import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final usernameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final middleNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final address1Ctrl = TextEditingController();
  final address2Ctrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final languageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authState = ref.read(authProvider);
    if (authState.currentUser != null) {
      final user = authState.currentUser!;

      usernameCtrl.text = user.username;
      firstNameCtrl.text = user.firstName;
      middleNameCtrl.text = user.middleName;
      lastNameCtrl.text = user.lastName;
      phoneCtrl.text = user.phoneNumber;
      address1Ctrl.text = user.address1;
      address2Ctrl.text = user.address2;
      countryCtrl.text = user.country;
      languageCtrl.text = user.language;
    }
  }

  @override
  void dispose() {
    usernameCtrl.dispose();
    firstNameCtrl.dispose();
    middleNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    address1Ctrl.dispose();
    address2Ctrl.dispose();
    countryCtrl.dispose();
    languageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      final url = await ref.read(authProvider.notifier).uploadProfilePicture(picked);
      // You can update local state or refetch user if needed
    }
  }

  String? _getProfileImageUrl() {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;
    if (user != null && user.profilePictureUrl.isNotEmpty) {
      return user.profilePictureUrl;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (authState.isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider
                    : (_getProfileImageUrl() != null
                    ? CachedNetworkImageProvider(_getProfileImageUrl()!)
                    : const AssetImage('assets/images/default_avatar.png') as ImageProvider),
                child: _imageFile == null && _getProfileImageUrl() == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Email Display (Read-only)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined, color: Colors.grey),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          authState.currentUser?.email ?? 'No email',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: usernameCtrl,
              label: 'Username',
              hintText: 'Enter username',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: firstNameCtrl,
              label: 'First Name',
              hintText: 'Enter first name',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: middleNameCtrl,
              label: 'Middle Name',
              hintText: 'Optional',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: lastNameCtrl,
              label: 'Last Name',
              hintText: 'Enter last name',
              prefixIcon: const Icon(Icons.person_outline),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: phoneCtrl,
              label: 'Phone Number',
              hintText: 'Enter phone number',
              prefixIcon: const Icon(Icons.phone_outlined),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: address1Ctrl,
              label: 'Address Line 1',
              hintText: 'Enter address',
              prefixIcon: const Icon(Icons.home_outlined),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: address2Ctrl,
              label: 'Address Line 2',
              hintText: 'Optional',
              prefixIcon: const Icon(Icons.home_outlined),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: countryCtrl,
              label: 'Country',
              hintText: 'Enter country',
              prefixIcon: const Icon(Icons.location_on_outlined),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: languageCtrl,
              label: 'Language',
              hintText: 'e.g. English',
              prefixIcon: const Icon(Icons.language_outlined),
            ),
            const SizedBox(height: 30),

            CustomButton(
              text: 'Update Profile',
              isLoading: authState.isLoading,
              onPressed: () {
                if (authState.isLoading) return;

                final data = {
                  'username': usernameCtrl.text.trim(),
                  'firstName': firstNameCtrl.text.trim(),
                  'middleName': middleNameCtrl.text.trim(),
                  'lastName': lastNameCtrl.text.trim(),
                  'phoneNumber': phoneCtrl.text.trim(),
                  'address1': address1Ctrl.text.trim(),
                  'address2': address2Ctrl.text.trim(),
                  'country': countryCtrl.text.trim(),
                  'language': languageCtrl.text.trim(),
                };
                authNotifier.updateProfile(data);
              },
            ),
            const SizedBox(height: 16),

            // Password Change Button
            OutlinedButton(
              onPressed: () {
                _showChangePasswordDialog(context, authNotifier);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 20),
                  SizedBox(width: 8),
                  Text('Change Password'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            CustomButton(
              text: 'Logout',
              backgroundColor: Colors.red,
              onPressed: () => authNotifier.confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, AuthNotifier authNotifier) {
    final oldPasswordCtrl = TextEditingController();
    final newPasswordCtrl = TextEditingController();
    final confirmPasswordCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
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
              authNotifier.changePassword(
                oldPasswordCtrl.text.trim(),
                newPasswordCtrl.text.trim(),
                confirmPasswordCtrl.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }
}