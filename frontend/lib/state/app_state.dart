import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImageSource;
import '../models/category_model.dart';
import '../models/history_result.dart';
import '../models/summary_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/profile_photo_service.dart';
import '../services/transaction_service.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _auth = AuthService(_api);
    _categoryService = CategoryService(_api);
    _transactionService = TransactionService(_api);
    // Server menjawab 401 saat token kedaluwarsa/dicabut -> logout otomatis.
    _api.onUnauthorized = _handleUnauthorized;
  }

  final ApiClient _api;
  late final AuthService _auth;
  late final CategoryService _categoryService;
  late final TransactionService _transactionService;
  final ProfilePhotoService _photoService = ProfilePhotoService();

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
    await _loadLocalPhoto();
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
    _loggingOut = true;
    try {
      await _auth.logout();
    } finally {
      _loggingOut = false;
    }
    _clearSessionData();
    notifyListeners();
  }

  void _clearSessionData() {
    _currentUser = null;
    _summary = null;
    _historyTransactions = [];
    _historyTotal = 0;
    _categories = [];
    _activeNavIndex = 0;
    _historyTab = 'Semua';
    _resetFilterValues();
    _loadError = null;
  }

  // ---------------- Pulihkan sesi ----------------
  bool _loggingOut = false;

  /// true jika pemulihan sesi gagal karena token ditolak server (401).
  bool sessionExpiredOnRestore = false;

  /// Diisi oleh main.dart: dipanggil saat sesi berakhir di tengah pemakaian
  /// (token ditolak server), untuk mengembalikan user ke layar Login.
  VoidCallback? onSessionExpired;

  void _handleUnauthorized() {
    // Abaikan jika memang belum/sedang tidak login (mis. salah password,
    // atau 401 dari proses logout itu sendiri).
    if (_currentUser == null || _loggingOut) return;
    _api.clearToken();
    _clearSessionData();
    notifyListeners();
    onSessionExpired?.call();
  }

  /// Dipanggil splash. true = token tersimpan masih berlaku dan user sudah
  /// dimuat, jadi app bisa langsung ke Beranda.
  Future<bool> restoreSession() async {
    try {
      await _api.loadToken();
      if (!_api.hasToken) return false;
      _currentUser = await _auth.me();
    } on ApiException catch (e) {
      // 401 = token tidak berlaku lagi -> hapus. Error lain (offline, server
      // mati): token dibiarkan, user diarahkan ke Login.
      if (e.statusCode == 401) {
        await _api.clearToken();
        sessionExpiredOnRestore = true;
      }
      return false;
    } catch (_) {
      return false;
    }
    await _loadLocalPhoto();
    _activeNavIndex = 0;
    _historyTab = 'Semua';
    _resetFilterValues();
    await refreshAll();
    notifyListeners();
    return true;
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

  // ---------------- Foto profil (lokal) ----------------
  /// Dipanggil setelah user diketahui (login / pulihkan sesi) untuk
  /// memasang foto profil lokal ke currentUser.
  Future<void> _loadLocalPhoto() async {
    final user = _currentUser;
    if (user == null) return;
    final path = await _photoService.load(user.id);
    if (path != null) {
      _currentUser = user.copyWith(profilePhoto: path);
    }
  }

  /// null = sukses atau dibatalkan, selain itu pesan error.
  Future<String?> pickProfilePhoto(ImageSource source) async {
    final user = _currentUser;
    if (user == null) return null;
    try {
      final path = await _photoService.pickAndSave(user.id, source);
      if (path == null) return null;
      _currentUser = user.copyWith(profilePhoto: path);
      notifyListeners();
    } catch (_) {
      return 'Gagal mengambil foto';
    }
    return null;
  }

  Future<void> removeProfilePhoto() async {
    final user = _currentUser;
    if (user == null) return;
    await _photoService.remove(user.id);
    // copyWith tidak bisa mengosongkan foto, jadi bangun ulang modelnya.
    _currentUser = UserModel(id: user.id, username: user.username);
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
  int _loadingCount = 0; // jumlah pemuatan yang sedang berjalan

  String? get loadError => _loadError;

  /// true selama data sedang dimuat dari server.
  bool get isLoading => _loadingCount > 0;

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

  Future<void> refreshAll() async {
    _loadingCount++;
    notifyListeners();
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
    } catch (_) {
      if (isAuthenticated) _loadError = 'Data dari server tidak dapat dibaca.';
    } finally {
      _loadingCount--;
    }
    notifyListeners();
  }

  Future<void> loadHistory() async {
    _loadingCount++;
    notifyListeners();
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
    } catch (_) {
      if (isAuthenticated) _loadError = 'Data dari server tidak dapat dibaca.';
    } finally {
      _loadingCount--;
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

  /// Backend menolak (409) jika kategori masih dipakai transaksi.
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