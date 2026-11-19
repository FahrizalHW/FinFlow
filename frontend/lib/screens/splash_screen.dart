import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../state/app_state.dart';
import 'auth/login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    // Setelah frame pertama (AppStateScope baru boleh dibaca di sini):
    // cek sesi tersimpan sambil menampilkan splash.
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

    Future<void> _start() async {
    final state = AppStateScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final restoring = state.restoreSession();
    await Future.delayed(const Duration(milliseconds: 2200));
    final restored = await restoring.catchError((_) => false);
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            restored ? const MainNavigationScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    // Token tersimpan ditolak server -> beri tahu user kenapa ke Login.
    if (state.sessionExpiredOnRestore) {
      state.sessionExpiredOnRestore = false;
      messenger.showSnackBar(
        const SnackBar(content: Text('Sesi berakhir, silakan login kembali')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FinFlow',
                style: AppStyles.logoSplash.copyWith(
                  letterSpacing: 2.0,
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 48,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}