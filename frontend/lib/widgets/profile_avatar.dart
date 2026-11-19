import 'dart:io';

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Avatar bulat: menampilkan foto profil lokal jika ada,
/// kalau tidak ada tampil ikon orang.
class ProfileAvatar extends StatelessWidget {
  final String? photoPath;
  final double size;
  final double iconSize;
  final bool outlined; // gaya kecil di Beranda (latar terang + garis tepi)
  final bool shadow;

  const ProfileAvatar({
    super.key,
    required this.photoPath,
    required this.size,
    required this.iconSize,
    this.outlined = false,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      Icons.person,
      size: iconSize,
      color: outlined ? AppColors.primary : Colors.white,
    );
    final path = photoPath;
    final hasPhoto = path != null && File(path).existsSync();

    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: outlined ? AppColors.primaryLight : AppColors.primary,
        shape: BoxShape.circle,
        border: outlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
        boxShadow: shadow && !outlined
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: hasPhoto
          ? Image.file(
              File(path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => icon,
            )
          : icon,
    );
  }
}
