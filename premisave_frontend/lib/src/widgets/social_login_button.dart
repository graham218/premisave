import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        icon: Image.asset('assets/images/$icon', width: 24, height: 24),
        label: Text('Continue with ${icon.split('.').first.capitalize()}'),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          side: const BorderSide(color: Colors.grey),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

extension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}