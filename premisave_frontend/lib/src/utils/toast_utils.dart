import 'package:flutter/material.dart';
import '../../main.dart';

class ToastUtils {
  static void showSuccessToast(String message) {
    _show(message, Colors.green, Icons.check_circle);
  }

  static void showErrorToast(String message) {
    _show(message, Colors.red, Icons.error);
  }

  static void showInfoToast(String message) {
    _show(message, Colors.blue, Icons.info);
  }

  static void showWarningToast(String message) {
    _show(message, Colors.orange, Icons.warning);
  }

  static void _show(String message, Color color, IconData icon) {
    // Use a try-catch to handle any context issues
    try {
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) {
        print('ToastUtils: ScaffoldMessengerKey is not available');
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () => messenger.hideCurrentSnackBar(),
          ),
        ),
      );
    } catch (e) {
      print('ToastUtils error: $e');
    }
  }
}