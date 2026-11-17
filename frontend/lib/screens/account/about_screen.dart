import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Wordmark FinFlow (Matches Gambar L5.18)
              const Center(
                child: Text(
                  'FinFlow',
                  style: AppStyles.logoAuth,
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Versi 1.0.0 (Build 2026)',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Card Section 1: Tujuan Aplikasi
              _buildInfoSection(
                title: 'Tujuan Aplikasi',
                content:
                    'FinFlow dirancang untuk membantu pengguna mengelola dan memantau pemasukan serta pengeluaran pribadi secara praktis, terstruktur, dan efisien. Dengan pencatatan yang rapi, pengguna dapat mengambil keputusan finansial yang lebih terencana dan terukur.',
              ),
              const SizedBox(height: 18),

              // Card Section 2: Fungsi & Fitur Utama
              _buildInfoSection(
                title: 'Fungsi & Fitur Utama',
                content:
                    '• Autentikasi Pengguna (Login & Registrasi Akun)\n'
                    '• Beranda Ringkasan Saldo, Total Pemasukan & Pengeluaran\n'
                    '• Riwayat Transaksi Lengkap dengan Filter Tanggal & Kategori\n'
                    '• Pencatatan, Pengubahan (Edit), & Penghapusan Transaksi\n'
                    '• Manajemen Kategori Transaksi Mandiri (Tambah & Hapus)\n'
                    '• Pengelolaan Akun & Profil Pengguna',
              ),
              const SizedBox(height: 18),

              // Card Section 3: Catatan Pembaruan (Patch Notes)
              _buildInfoSection(
                title: 'Catatan Pembaruan (Patch Notes)',
                content:
                    'Versi 1.0.0 (Rilis Perdana):\n'
                    '• Implementasi antarmuka pengguna sesuai spesifikasi Lampiran 5 Wireframe.\n'
                    '• Dukungan pencatatan transaksi pemasukan dan pengeluaran secara real-time.\n'
                    '• Integrasi sistem kategori kustom dan filter riwayat komprehensif.\n'
                    '• Dialog konfirmasi keamanan penghapusan dan logout.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppStyles.radiusMedium),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}