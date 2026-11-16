import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient}) : _api = apiClient ?? ApiClient() {
    _auth = AuthService(_api);
  }

  final ApiClient _api;
  late final AuthService _auth;

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
    notifyListeners();
    return null;
  }

  /// null = sukses, selain itu isinya pesan error dari server.
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
