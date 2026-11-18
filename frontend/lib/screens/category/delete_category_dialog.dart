import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../widgets/custom_button.dart';

class DeleteCategoryDialog extends StatelessWidget {
  final String categoryName;
  final VoidCallback onConfirmDelete;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryName,
    required this.onConfirmDelete,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String categoryName,
    required VoidCallback onConfirmDelete,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => DeleteCategoryDialog(
        categoryName: categoryName,
        onConfirmDelete: () {
          onConfirmDelete();
          Navigator.of(ctx).pop(true);
        },
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Close 'x' icon
            Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(false),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
                  ),
                ),
              ),
            const Text(
              'Hapus Kategori?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Kategori yang masih dipakai transaksi tidak dapat dihapus. Ubah atau hapus transaksinya terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            CustomButton(
              text: 'Hapus',
              onPressed: onConfirmDelete,
              variant: ButtonVariant.primary,
              height: 44,
            ),
            const SizedBox(height: 8),
            CustomButton(
              text: 'Batal',
              onPressed: () => Navigator.of(context).pop(false),
              variant: ButtonVariant.outline,
              height: 44,
            ),
          ],
        ),
      ),
    );
  }
}