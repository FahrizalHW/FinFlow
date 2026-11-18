import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'services/api_client.dart'; 


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinFlowApp());
}

class FinFlowApp extends StatefulWidget {
  const FinFlowApp({super.key});

  @override
  State<FinFlowApp> createState() => _FinFlowAppState();
}

class _FinFlowAppState extends State<FinFlowApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(apiClient: ApiClient()); 
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      appState: _appState,
      child: MaterialApp(
        title: 'FinFlow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textPrimary,
            elevation: 0.5,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          );
        },
        home: const SplashScreen(),
      ),
    );
  }
}