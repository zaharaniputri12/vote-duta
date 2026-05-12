import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final IconData icon;
  final Color iconColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Konfirmasi',
    this.cancelText = 'Batal',
    this.icon = Icons.help_outline,
    this.iconColor = AppColors.warning,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Konfirmasi',
    String cancelText = 'Batal',
    IconData icon = Icons.help_outline,
    Color iconColor = AppColors.warning,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: const TextStyle(color: AppColors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}