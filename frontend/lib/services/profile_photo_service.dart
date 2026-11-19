import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Foto profil disimpan LOKAL di perangkat (belum diunggah ke server).
/// File disalin ke folder dokumen aplikasi, path-nya disimpan per user
/// di SharedPreferences, jadi akun lain di perangkat yang sama tidak
/// ikut melihat foto ini.
class ProfilePhotoService {
  static const _keyPrefix = 'profile_photo_path_';
  final ImagePicker _picker = ImagePicker();

  /// Path foto tersimpan untuk user ini, atau null jika belum ada.
  Future<String?> load(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('$_keyPrefix$userId');
    if (path == null) return null;
    return File(path).existsSync() ? path : null;
  }

  /// Pilih foto dari kamera/galeri, salin ke folder aplikasi, simpan path-nya.
  /// Mengembalikan path baru, atau null jika user membatalkan.
  Future<String?> pickAndSave(int userId, ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final dot = picked.path.lastIndexOf('.');
    final ext = dot == -1 ? 'jpg' : picked.path.substring(dot + 1);
    // Nama unik supaya Image.file tidak menampilkan gambar lama dari cache.
    final dest =
        '${dir.path}/profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await File(picked.path).copy(dest);

    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getString('$_keyPrefix$userId');
    await prefs.setString('$_keyPrefix$userId', dest);
    await _deleteIfExists(old);
    return dest;
  }

  Future<void> remove(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final old = prefs.getString('$_keyPrefix$userId');
    await prefs.remove('$_keyPrefix$userId');
    await _deleteIfExists(old);
  }

  Future<void> _deleteIfExists(String? path) async {
    if (path == null) return;
    final f = File(path);
    if (f.existsSync()) await f.delete();
  }
}
