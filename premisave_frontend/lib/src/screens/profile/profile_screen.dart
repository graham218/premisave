import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
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

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
      final url = await ref.read(authProvider.notifier).uploadProfilePicture(picked);
      // You can update local state or refetch user if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
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
                    : CachedNetworkImageProvider('https://via.placeholder.com/150'),
                child: _imageFile == null ? const Icon(Icons.camera_alt, size: 40) : null,
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(controller: usernameCtrl, label: 'Username', hintText: 'Enter username'),
            CustomTextField(controller: firstNameCtrl, label: 'First Name', hintText: 'Enter first name'),
            CustomTextField(controller: middleNameCtrl, label: 'Middle Name', hintText: 'Optional'),
            CustomTextField(controller: lastNameCtrl, label: 'Last Name', hintText: 'Enter last name'),
            CustomTextField(controller: phoneCtrl, label: 'Phone Number', hintText: 'Enter phone number'),
            CustomTextField(controller: address1Ctrl, label: 'Address 1', hintText: 'Optional'),
            CustomTextField(controller: address2Ctrl, label: 'Address 2', hintText: 'Optional'),
            CustomTextField(controller: countryCtrl, label: 'Country', hintText: 'Optional'),
            CustomTextField(controller: languageCtrl, label: 'Language', hintText: 'e.g. English'),
            const SizedBox(height: 30),
            CustomButton(
              text: 'Update Profile',
              onPressed: () {
                final data = {
                  'username': usernameCtrl.text,
                  'firstName': firstNameCtrl.text,
                  'middleName': middleNameCtrl.text,
                  'lastName': lastNameCtrl.text,
                  'phoneNumber': phoneCtrl.text,
                  'address1': address1Ctrl.text,
                  'address2': address2Ctrl.text,
                  'country': countryCtrl.text,
                  'language': languageCtrl.text,
                };
                authNotifier.updateProfile(data);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Logout',
              onPressed: () => authNotifier.confirmLogout(context),
            ),
          ],
        ),
      ),
    );
  }
}