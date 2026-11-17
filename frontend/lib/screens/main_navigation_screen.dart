import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../state/app_state.dart';
import '../widgets/confirm_dialog.dart';
import 'account/account_screen.dart';
import 'auth/login_screen.dart';
import 'history/history_screen.dart';
import 'home/home_screen.dart';
import 'transaction/add_transaction_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  // 0: Beranda, 1: Riwayat, 2: Akun
  int _selectedTab = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    HistoryScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int navIndex) {
    if (navIndex == 2) {
      // Tambah button pressed
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const AddTransactionScreen()));
      return;
    }

    if (navIndex == 4) {
      // Keluar button pressed -> Show Pop-up Logout (Gambar L5.20)
      _showLogoutDialog();
      return;
    }

    final targetTab = navIndex == 3 ? 2 : navIndex;
    setState(() {
      _selectedTab = targetTab;
    });

    final state = AppStateScope.of(context);
    state.setNavIndex(targetTab);
  }

  void _showLogoutDialog() {
    ConfirmDialog.show(
      context: context,
      title: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Keluar',
      cancelText: 'Batal',
      isDestructive: false,
    ).then((confirmed) async {
      if (confirmed == true && mounted) {
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
    if (state.activeNavIndex != _selectedTab) {
      _selectedTab = state.activeNavIndex;
    }

    return Scaffold(
      body: IndexedStack(index: _selectedTab, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  navIndex: 0,
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  isActive: _selectedTab == 0,
                ),
                _buildNavItem(
                  navIndex: 1,
                  icon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  isActive: _selectedTab == 1,
                ),
                // Center Tambah Button (Prominent circular plus icon as shown in Gambar L5.4)
                _buildCenterAddButton(),
                _buildNavItem(
                  navIndex: 3,
                  icon: Icons.person_rounded,
                  label: 'Akun',
                  isActive: _selectedTab == 2,
                ),
                _buildNavItem(
                  navIndex: 4,
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  isActive: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int navIndex,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    final color = isActive ? Colors.white : Colors.white.withAlpha(190);

    return InkWell(
      onTap: () => _onItemTapped(navIndex),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: AppColors.primary,
          size: 32,
        ),
      ),
    );
  }
}
