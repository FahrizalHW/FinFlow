import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/history_result.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/transaction_service.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _auth = AuthService(_api);
    _categoryService = CategoryService(_api);
    _transactionService = TransactionService(_api);
  }

  final ApiClient _api;
  late final AuthService _auth;
  late final CategoryService _categoryService;
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
    _historyTab = 'Semua';
    _resetFilterValues();
    await refreshAll();
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
    _historyTransactions = [];
    _historyTotal = 0;
    _categories = [];
    _activeNavIndex = 0;
    _historyTab = 'Semua';
    _resetFilterValues();
    _loadError = null;
    notifyListeners();
  }

  Future<String?> updateProfile({String? username, String? password}) async {
    if (_currentUser == null) return null;
    final newName =
        (username != null && username.trim().isNotEmpty) ? username.trim() : _currentUser!.username;
    try {
      final user = await _auth.updateProfile(username: newName, password: password);
      _currentUser = user.copyWith(profilePhoto: _currentUser!.profilePhoto);
      notifyListeners();
    } on ApiException catch (e) {
      return e.message;
    }
    return null;
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

  // Pilihan filter di Riwayat (dikirim ke backend sebagai parameter).
  String _historyTab = 'Semua'; // 'Semua', 'Pemasukan', 'Pengeluaran'
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String? _filterCategory;

  String get historyTab => _historyTab;
  DateTime? get filterStartDate => _filterStartDate;
  DateTime? get filterEndDate => _filterEndDate;
  String? get filterCategory => _filterCategory;

  bool get isFilterActive =>
      _filterStartDate != null ||
      _filterEndDate != null ||
      _filterCategory != null;

  Future<void> setHistoryTab(String tab) async {
    _historyTab = tab;
    notifyListeners();
    await loadHistory();
  }

  Future<void> applyFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _filterCategory =
        (category == null || category.isEmpty || category == 'Semua Kategori')
        ? null
        : category;
    notifyListeners();
    await loadHistory();
  }

  Future<void> resetFilter() async {
    _resetFilterValues();
    notifyListeners();
    await loadHistory();
  }

  void _resetFilterValues() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filterCategory = null;
  }

  // ---------------- Data dari backend ----------------
  SummaryModel? _summary;
  List<TransactionModel> _historyTransactions = [];
  double _historyTotal = 0;
  List<CategoryModel> _categories = [];
  String? _loadError;

  String? get loadError => _loadError;

  double get totalBalance => _summary?.balance ?? 0;
  double get totalMonthlyIncome => _summary?.monthlyIncome ?? 0;
  double get totalMonthlyExpense => _summary?.monthlyExpense ?? 0;
  List<TransactionModel> get recentTransactions =>
      _summary?.recentTransactions ?? const [];

  /// Riwayat yang sudah difilter dan diurutkan oleh backend.
  List<TransactionModel> get filteredTransactions => _historyTransactions;

  /// Angka di atas daftar riwayat, dihitung backend sesuai tab dan filter.
  double get displayedSum => _historyTotal;

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  /// Muat ulang kategori, ringkasan Beranda, dan riwayat.
  Future<void> refreshAll() async {
    try {
      final results = await Future.wait([
        _categoryService.fetchAll(),
        _transactionService.fetchSummary(),
        _transactionService.fetchHistory(
          type: _historyTypeParam(),
          categoryName: _filterCategory,
          startDate: _filterStartDate,
          endDate: _filterEndDate,
        ),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _summary = results[1] as SummaryModel;
      final history = results[2] as HistoryResult;
      _historyTransactions = history.transactions;
      _historyTotal = history.displayedTotal;
      _loadError = null;
    } on ApiException catch (e) {
      if (isAuthenticated) _loadError = e.message;
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    try {
      final history = await _transactionService.fetchHistory(
        type: _historyTypeParam(),
        categoryName: _filterCategory,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );
      _historyTransactions = history.transactions;
      _historyTotal = history.displayedTotal;
      _loadError = null;
    } on ApiException catch (e) {
      if (isAuthenticated) _loadError = e.message;
    }
    notifyListeners();
  }

  String? _historyTypeParam() {
    switch (_historyTab) {
      case 'Pemasukan':
        return 'pemasukan';
      case 'Pengeluaran':
        return 'pengeluaran';
      default:
        return null;
    }
  }

  // ---------------- Transaksi ----------------
  /// null = sukses, selain itu isinya pesan error dari server.
  Future<String?> addTransaction({
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await _transactionService.create(
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        notes: notes,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await refreshAll(); // saldo, riwayat, dan beranda dihitung ulang server
    return null;
  }

  // ---------------- Kategori ----------------
  /// Hanya menyaring daftar untuk tampilan dropdown (sesuai tab jenis).
  List<CategoryModel> getCategoriesByType(String type) {
    final lower = type.toLowerCase();
    return _categories.where((c) => c.type.toLowerCase() == lower).toList();
  }

  Future<String?> addCategory(String name, String type) async {
    try {
      await _categoryService.create(name: name, type: type.toLowerCase());
      _categories = await _categoryService.fetchAll();
    } on ApiException catch (e) {
      return e.message;
    }
    notifyListeners();
    return null;
  }

  /// Aturan "hapus kategori = hapus semua transaksinya" ada di backend.
  Future<String?> deleteCategory(int categoryId) async {
    try {
      await _categoryService.delete(categoryId);
    } on ApiException catch (e) {
      return e.message;
    }
    await refreshAll();
    return null;
  }

  // ---------------- Detail, edit, hapus transaksi ----------------
  /// Mencari transaksi di data yang sudah dimuat (riwayat atau ringkasan).
  TransactionModel? findTransaction(int id) {
    for (final t in _historyTransactions) {
      if (t.id == id) return t;
    }
    for (final t in recentTransactions) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// null = sukses, selain itu isinya pesan error dari server.
  Future<String?> updateTransaction({
    required int id,
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required DateTime date,
    String? notes,
  }) async {
    try {
      await _transactionService.update(
        id: id,
        title: title,
        amount: amount,
        type: type,
        categoryId: categoryId,
        date: date,
        notes: notes,
      );
    } on ApiException catch (e) {
      return e.message;
    }
    await refreshAll(); // saldo dan daftar dihitung ulang server
    return null;
  }

  Future<String?> deleteTransaction(int id) async {
    try {
      await _transactionService.delete(id);
    } on ApiException catch (e) {
      return e.message;
    }
    await refreshAll();
    return null;
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