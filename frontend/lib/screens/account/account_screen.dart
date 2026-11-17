import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../state/app_state.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/custom_button.dart';
import '../auth/login_screen.dart';
import 'about_screen.dart';
import 'edit_account_screen.dart';
import 'help_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    ConfirmDialog.show(
      context: context,
      title: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      isDestructive: false,
    ).then((confirmed) async {
      if (confirmed == true && context.mounted) {
        final state = AppStateScope.of(context);
        final navigator = Navigator.of(context);
        await state.logout();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final user = state.currentUser;
    final username = user?.username ?? 'Pengguna FinFlow';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Akun',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar circle (Matches Gambar L5.16)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Username text
              Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Akun Personal FinFlow',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // 4 Stacked Blue Buttons (Exact Match to Gambar L5.16)
              CustomButton(
                text: 'Edit Akun',
                variant: ButtonVariant.primary,
                height: 48,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditAccountScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              CustomButton(
                text: 'Tentang Aplikasi',
                variant: ButtonVariant.primary,
                height: 48,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AboutScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              CustomButton(
                text: 'Pusat Bantuan',
                variant: ButtonVariant.primary,
                height: 48,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HelpScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),

              CustomButton(
                text: 'Keluar',
                variant: ButtonVariant.primary,
                height: 48,
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}