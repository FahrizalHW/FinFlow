import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Border radius values
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;

  // Box shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: AppColors.primary.withAlpha(64),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];

  // Text Styles
  static const TextStyle logoSplash = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  static const TextStyle logoAuth = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    color: AppColors.primary,
    letterSpacing: 1.1,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // Formatting utility methods
  static String formatRupiah(num amount, {bool showSign = false, bool isIncome = false}) {
    final absAmount = amount.abs();
    final formattedNumber = _formatWithSeparators(absAmount);
    
    if (showSign) {
      if (isIncome) {
        return '+Rp $formattedNumber';
      } else {
        return '-Rp $formattedNumber';
      }
    }
    if (amount < 0) {
      return '-Rp. $formattedNumber';
    }
    return 'Rp. $formattedNumber';
  }

  static String _formatWithSeparators(num value) {
    final intPart = value.toInt().toString();
    final buffer = StringBuffer();
    final length = intPart.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intPart[i]);
    }
    return buffer.toString();
  }

  static String formatDate(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static String formatDateTime(DateTime dt) {
    return '${formatDate(dt)}, ${formatTime(dt)}';
  }
}
