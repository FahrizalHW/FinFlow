import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../models/user_model.dart';

class AppState extends ChangeNotifier {
  // Users
  final List<UserModel> _registeredUsers = [
    const UserModel(
      id: 1,
      username: 'Reyan',
      password: 'password123',
    ),
  ];

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Active Tab Index (0: Beranda, 1: Riwayat, 2: Akun)
  int _activeNavIndex = 0;
  int get activeNavIndex => _activeNavIndex;

  void setNavIndex(int index) {
    if (index >= 0 && index <= 2) {
      _activeNavIndex = index;
      notifyListeners();
    }
  }

  // Categories
  final List<CategoryModel> _categories = [
    // System Default Pemasukan
    const CategoryModel(id: 1, userId: null, name: 'Gaji', type: 'pemasukan'),
    const CategoryModel(id: 2, userId: null, name: 'Bonus', type: 'pemasukan'),
    const CategoryModel(id: 3, userId: null, name: 'Investasi', type: 'pemasukan'),
    const CategoryModel(id: 4, userId: null, name: 'Penjualan', type: 'pemasukan'),

    // System Default Pengeluaran
    const CategoryModel(id: 5, userId: null, name: 'Makanan', type: 'pengeluaran'),
    const CategoryModel(id: 6, userId: null, name: 'Minuman', type: 'pengeluaran'),
    const CategoryModel(id: 7, userId: null, name: 'Hiburan', type: 'pengeluaran'),
    const CategoryModel(id: 8, userId: null, name: 'Game', type: 'pengeluaran'),
    const CategoryModel(id: 9, userId: null, name: 'Transportasi', type: 'pengeluaran'),
    const CategoryModel(id: 10, userId: null, name: 'Belanja', type: 'pengeluaran'),
  ];

  int _nextCategoryId = 11;

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  List<CategoryModel> getCategoriesByType(String type) {
    final lower = type.toLowerCase();
    return _categories.where((c) => c.type.toLowerCase() == lower).toList();
  }

  // Transactions (Default empty for new users)
  final List<TransactionModel> _transactions = [];

  int _nextTransactionId = 1;

  List<TransactionModel> get transactions {
    final list = List<TransactionModel>.from(_transactions);
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  // Filter options for Riwayat Transaksi
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
      (_filterCategory != null && _filterCategory!.isNotEmpty && _filterCategory != 'Semua Kategori');

  void setHistoryTab(String tab) {
    _historyTab = tab;
    notifyListeners();
  }

  void applyFilter({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) {
    _filterStartDate = startDate;
    _filterEndDate = endDate;
    _filterCategory = (category == 'Semua Kategori' || category == null || category.isEmpty) ? null : category;
    notifyListeners();
  }

  void resetFilter() {
    _filterStartDate = null;
    _filterEndDate = null;
    _filterCategory = null;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    return transactions.where((tx) {
      // Tab filter
      if (_historyTab == 'Pemasukan' && !tx.isIncome) return false;
      if (_historyTab == 'Pengeluaran' && tx.isIncome) return false;

      // Category filter
      if (_filterCategory != null && _filterCategory!.isNotEmpty) {
        if (tx.categoryName.toLowerCase() != _filterCategory!.toLowerCase()) {
          return false;
        }
      }

      // Date range filter
      if (_filterStartDate != null) {
        final start = DateTime(_filterStartDate!.year, _filterStartDate!.month, _filterStartDate!.day);
        if (tx.date.isBefore(start)) return false;
      }
      if (_filterEndDate != null) {
        final end = DateTime(_filterEndDate!.year, _filterEndDate!.month, _filterEndDate!.day, 23, 59, 59);
        if (tx.date.isAfter(end)) return false;
      }

      return true;
    }).toList();
  }

  // Financial calculations
  double get totalBalance {
    double total = 0;
    for (final tx in _transactions) {
      if (tx.isIncome) {
        total += tx.amount;
      } else {
        total -= tx.amount;
      }
    }
    return total;
  }

  double get totalMonthlyIncome {
    final now = DateTime.now();
    double total = 0;
    for (final tx in _transactions) {
      if (tx.isIncome && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  double get totalMonthlyExpense {
    final now = DateTime.now();
    double total = 0;
    for (final tx in _transactions) {
      if (!tx.isIncome && tx.date.month == now.month && tx.date.year == now.year) {
        total += tx.amount;
      }
    }
    return total;
  }

  List<TransactionModel> get recentTransactions {
    final sorted = transactions;
    return sorted.take(5).toList();
  }

  // Auth operations
  bool login(String username, String password) {
    final trimmedUsername = username.trim();
    final user = _registeredUsers.firstWhere(
      (u) => u.username.toLowerCase() == trimmedUsername.toLowerCase() && u.password == password,
      orElse: () => const UserModel(id: -1, username: '', password: ''),
    );

    if (user.id != -1) {
      _currentUser = user;
      _activeNavIndex = 0;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool signup(String username, String password) {
    final trimmed = username.trim();
    if (trimmed.isEmpty || password.isEmpty) return false;

    final exists = _registeredUsers.any(
      (u) => u.username.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return false;

    final newUser = UserModel(
      id: _registeredUsers.length + 1,
      username: trimmed,
      password: password,
    );
    _registeredUsers.add(newUser);
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _activeNavIndex = 0;
    resetFilter();
    notifyListeners();
  }

  void updateProfile({String? username, String? password, String? profilePhoto}) {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      username: (username != null && username.trim().isNotEmpty) ? username.trim() : _currentUser!.username,
      password: (password != null && password.isNotEmpty) ? password : _currentUser!.password,
      profilePhoto: profilePhoto ?? _currentUser!.profilePhoto,
    );

    final idx = _registeredUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (idx != -1) {
      _registeredUsers[idx] = updated;
    }
    _currentUser = updated;
    notifyListeners();
  }

  // Transaction CRUD
  void addTransaction({
    required String title,
    required double amount,
    required String type,
    required int categoryId,
    required String categoryName,
    required DateTime date,
    String? notes,
  }) {
    final newTx = TransactionModel(
      id: _nextTransactionId++,
      userId: _currentUser?.id ?? 1,
      categoryId: categoryId,
      categoryName: categoryName,
      type: type.toLowerCase(),
      title: title.trim(),
      amount: amount,
      date: date,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
    );

    _transactions.add(newTx);
    notifyListeners();
  }

  void updateTransaction(TransactionModel updated) {
    final index = _transactions.indexWhere((tx) => tx.id == updated.id);
    if (index != -1) {
      _transactions[index] = updated;
      notifyListeners();
    }
  }

  void deleteTransaction(int transactionId) {
    _transactions.removeWhere((tx) => tx.id == transactionId);
    notifyListeners();
  }

  // Category CRUD
  void addCategory(String name, String type) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final newCat = CategoryModel(
      id: _nextCategoryId++,
      userId: _currentUser?.id ?? 1,
      name: trimmed,
      type: type.toLowerCase(),
    );
    _categories.add(newCat);
    notifyListeners();
  }

  /// Rule 7 & Lampiran 5: Deleting a category cascade-deletes all its transactions
  void deleteCategory(int categoryId) {
    final catIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (catIndex != -1) {
      final category = _categories[catIndex];
      // Cascade delete transactions with this category
      _transactions.removeWhere((tx) => tx.categoryId == category.id || tx.categoryName.toLowerCase() == category.name.toLowerCase());
      _categories.removeAt(catIndex);
      notifyListeners();
    }
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

