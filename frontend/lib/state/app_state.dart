import 'package:flutter/material.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _auth = AuthService(_api);
    _transactionService = TransactionService(_api);
  }

  final ApiClient _api;
  late final AuthService _auth;
  late final TransactionService _transactionService;

  // ---------------- Sesi ----------------
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  /// null = sukses, selain itu isinya pesan error dari server.
  Future<String?> login(String username, String password) async {
    try {
      _currentUser = await _auth.login(username, password);
    } on ApiException catch (e) {
      return e.message;
    }
    _activeNavIndex = 0;
    await loadSummary();
    notifyListeners();
    return null;
  }

  Future<String?> signup(
    String username,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      await _auth.register(
        username: username,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.logout();
    _currentUser = null;
    _summary = null;
    _activeNavIndex = 0;
    _loadError = null;
    notifyListeners();
  }

  // ---------------- State tampilan ----------------
  // Tab aktif (0: Beranda, 1: Riwayat, 2: Akun)
  int _activeNavIndex = 0;
  int get activeNavIndex => _activeNavIndex;

  void setNavIndex(int index) {
    if (index >= 0 && index <= 2) {
      _activeNavIndex = index;
      notifyListeners();
    }
  }

  // ---------------- Data dari backend ----------------
  SummaryModel? _summary;
  String? _loadError;
  String? get loadError => _loadError;

  double get totalBalance => _summary?.balance ?? 0;
  double get totalMonthlyIncome => _summary?.monthlyIncome ?? 0;
  double get totalMonthlyExpense => _summary?.monthlyExpense ?? 0;
  List<TransactionModel> get recentTransactions =>
      _summary?.recentTransactions ?? const [];

  Future<void> loadSummary() async {
    try {
      _summary = await _transactionService.fetchSummary();
      _loadError = null;
    } on ApiException catch (e) {
      _loadError = e.message;
    }
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState appState,
    required super.child,
  }) : super(notifier: appState);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!.notifier!;
  }
}