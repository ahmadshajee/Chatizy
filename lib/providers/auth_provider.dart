import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/auth_service.dart';

/// Manages authentication state across the app.
/// Provides the current user profile and role for routing decisions.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  Profile? _currentProfile;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _authSub;

  Profile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentProfile != null;
  UserRole get currentRole => _currentProfile?.role ?? UserRole.personal;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authSub = _authService.authStateChanges.listen((authState) async {
      if (authState.session != null) {
        await _loadProfile();
      } else {
        _currentProfile = null;
        notifyListeners();
      }
    });
    // Try to load existing session
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      _currentProfile = await _authService.getCurrentProfile();
      notifyListeners();
    } catch (e) {
      // No session or profile
    }
  }

  /// Sign in with email and password.
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up as a Personal user.
  Future<bool> signUpPersonal({
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _authService.signUpPersonal(
        email: email,
        password: password,
        fullName: fullName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up as a Business Employee.
  Future<bool> signUpEmployee({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
    String? nickname,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentProfile = await _authService.signUpEmployee(
        email: email,
        password: password,
        fullName: fullName,
        companyDomain: companyDomain,
        nickname: nickname,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  /// Create a Business Admin (Super Admin action).
  Future<bool> createBusinessAdmin({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.createBusinessAdmin(
        email: email,
        password: password,
        fullName: fullName,
        companyDomain: companyDomain,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create an Employee (Business Admin action).
  Future<bool> createEmployee({
    required String email,
    required String password,
    required String fullName,
    required String companyDomain,
    String? nickname,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.createEmployee(
        email: email,
        password: password,
        fullName: fullName,
        companyDomain: companyDomain,
        nickname: nickname,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
