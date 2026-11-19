import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/profile_avatar.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

  // AppStateScope tidak boleh dibaca di initState(), jadi isi awal
  // username diambil di sini (dipanggil sekali setelah initState).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    final user = AppStateScope.of(context).currentUser;
    _usernameController.text = user?.username ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Kamera hanya ada di HP; di desktop hanya galeri/file.
  bool get _cameraSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _choosePhoto() async {
    // Foto disimpan sebagai file lokal, jadi tidak didukung di Flutter Web.
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil hanya tersedia di aplikasi Android, iOS, atau desktop'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final state = AppStateScope.of(context);
    final hasPhoto = state.currentUser?.profilePhoto != null;

    // Hasil bottom sheet: ImageSource, atau 'remove' = hapus foto.
    final action = await showModalBottomSheet<Object>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            if (_cameraSupported)
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Ambil dari kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari galeri'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus foto', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(ctx, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    String? error;
    if (action == 'remove') {
      await state.removeProfilePhoto();
    } else if (action is ImageSource) {
      error = await state.pickProfilePhoto(action);
    }
    if (!mounted || error == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final state = AppStateScope.of(context);
    final error = await state.updateProfile(
      username: _usernameController.text.trim(),
      password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Profil akun berhasil diperbarui'),
        backgroundColor: error == null ? AppColors.income : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    if (error == null) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar + ikon kamera (ketuk untuk ganti foto profil)
                Center(
                  child: GestureDetector(
                    onTap: _choosePhoto,
                    child: Stack(
                      children: [
                        ProfileAvatar(
                          photoPath: AppStateScope.of(context).currentUser?.profilePhoto,
                          size: 96,
                          iconSize: 60,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Username Field
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hintText: 'Masukkan username baru',
                  prefixIcon: Icons.person_outline,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Baru Field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password Baru',
                  hintText: 'Biarkan kosong jika tidak diubah',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (val != null && val.isNotEmpty && val.length < 8) {
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ulangi Password Field (Gambar L5.17: "Ulangi Password")
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Ulangi Password',
                  hintText: 'Verifikasi password baru',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) {
                    if (_passwordController.text.isNotEmpty) {
                      if (val == null || val.isEmpty) {
                        return 'Silakan ulangi password baru';
                      }
                      if (val != _passwordController.text) {
                        return 'Password verifikasi tidak sesuai';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Button "Simpan" (Gambar L5.17)
                CustomButton(
                  text: 'Simpan',
                  variant: ButtonVariant.primary,
                  height: 48,
                  isLoading: _isLoading,
                  onPressed: _saveAccount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}