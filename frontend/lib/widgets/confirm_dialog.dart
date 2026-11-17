import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'custom_button.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final bool showCloseIcon;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.message,
    this.confirmText = 'Hapus',
    this.cancelText = 'Batal',
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.showCloseIcon = true,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String title,
    String? message,
    String confirmText = 'Hapus',
    String cancelText = 'Batal',
    bool isDestructive = false,
    bool showCloseIcon = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        showCloseIcon: showCloseIcon,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radiusLarge),
      ),
      backgroundColor: Colors.white,
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showCloseIcon)
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () {
                    if (onCancel != null) {
                      onCancel!();
                    } else {
                      Navigator.of(context).pop(false);
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 10),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 20),
            // Primary Action Button (Matches Wireframe: Top button is primary action e.g. Hapus/Keluar)
            CustomButton(
              text: confirmText,
              onPressed: onConfirm,
              variant: isDestructive ? ButtonVariant.danger : ButtonVariant.primary,
              height: 44,
            ),
            const SizedBox(height: 8),
            // Secondary Action Button (Matches Wireframe: Bottom button is Batal)
            CustomButton(
              text: cancelText,
              onPressed: () {
                if (onCancel != null) {
                  onCancel!();
                } else {
                  Navigator.of(context).pop(false);
                }
              },
              variant: ButtonVariant.outline,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}

