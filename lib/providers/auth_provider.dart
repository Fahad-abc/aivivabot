import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_model.dart';
import '../services/auth/auth_service.dart';

// ============================================================
// AUTH PROVIDER - Manages Authentication State
// ============================================================

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  // ============================================================
  // GETTERS
  // ============================================================

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _currentUser?.id.startsWith('guest_') ?? false;
  bool get isPremium => _currentUser?.isPremium ?? false;

  String get userInitials => _currentUser?.initials ?? '?';
  String get userName => _currentUser?.shortName ?? 'User';
  String get userFullName => _currentUser?.fullName ?? 'Guest User';
  String get userEmail => _currentUser?.email ?? 'guest@aivivabot.com';

  int get currentStreak {
    return _currentUser?.statistics.currentStreak ?? 0;
  }

  // ============================================================
  // AUTH METHODS
  // ============================================================

  /// Sign in with email and password (Real Firebase)
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        await _saveUserToLocal(_currentUser!);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Invalid email or password');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign up with email and password (Real Firebase)
  Future<bool> signUpWithEmail(String email, String password, String fullName) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signUpWithEmail(email, password, fullName);
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        await _saveUserToLocal(_currentUser!);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError('Sign up failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in with Google (Works on Android + Web)
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      print('🟡 AuthProvider: signInWithGoogle called');
      print('🟡 Platform: ${kIsWeb ? "Web" : "Mobile"}');

      AppUser? user;

      if (kIsWeb) {
        print('🟢 Using web Google Sign-In');
        user = await _authService.signInWithGoogleWeb();
      } else {
        print('🟢 Using native Google Sign-In');
        user = await _authService.signInWithGoogle();
      }

      if (user != null) {
        print('✅ Sign-in successful: ${user.email}');
        _currentUser = user;
        _isAuthenticated = true;
        await _saveUserToLocal(_currentUser!);
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        print('🔴 Sign-in failed: user is null');
        _setError('Google sign in failed');
        return false;
      }
    } catch (e) {
      print('❌ AuthProvider error: $e');
      _setError(e.toString());
      return false;
    }
  }

  /// Sign in as Guest
  Future<void> signInAsGuest() async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _authService.signInAsGuest();
      _currentUser = user;
      _isAuthenticated = true;
      await _saveUserToLocal(_currentUser!);
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _authService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      await _clearUserFromLocal();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Reset password - sends email to user
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.resetPassword(email);
      _setLoading(false);
      notifyListeners();
      return result;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? department,
    int? yearOfStudy,
    String? fypTitle,
    String? fypSupervisor,
    List<String>? fypTechnologies,
    String? fypDescription,
  }) async {
    _setLoading(true);

    try {
      if (_currentUser != null) {
        final updatedUser = _currentUser!.copyWith(
          fullName: fullName ?? _currentUser!.fullName,
          phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
          department: department ?? _currentUser!.department,
          yearOfStudy: yearOfStudy ?? _currentUser!.yearOfStudy,
          fypTitle: fypTitle ?? _currentUser!.fypTitle,
          fypSupervisor: fypSupervisor ?? _currentUser!.fypSupervisor,
          fypTechnologies: fypTechnologies ?? _currentUser!.fypTechnologies,
          fypDescription: fypDescription ?? _currentUser!.fypDescription,
        );
        _currentUser = updatedUser;
        await _saveUserToLocal(updatedUser);
        _setLoading(false);
        notifyListeners();
        return true;
      }
      _setError('No authenticated user found. Please sign in first.');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Update FYP information
  Future<bool> updateFypInfo({
    required String title,
    String? supervisor,
    List<String>? technologies,
    String? description,
  }) async {
    return updateProfile(
      fypTitle: title,
      fypSupervisor: supervisor,
      fypTechnologies: technologies ?? [],
      fypDescription: description,
    );
  }

  /// Update last active timestamp
  void updateLastActive() {
    _currentUser?.updateLastActive();
    notifyListeners();
  }

  /// Add session to user history
  void addSessionId(String sessionId) {
    _currentUser?.addSessionId(sessionId);
    notifyListeners();
  }

  /// Add report to user history
  void addReportId(String reportId) {
    _currentUser?.addReportId(reportId);
    notifyListeners();
  }

  /// Get current user
  AppUser? getUser() {
    return _currentUser;
  }

  // ============================================================
  // LOAD USER DATA
  // ============================================================

  /// Load saved user from local storage
  Future<void> loadSavedUser() async {
    _setLoading(true);

    try {
      final user = await _authService.getSavedUser();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
      }
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  bool hasFypInfo() {
    return _currentUser?.hasFypInfo ?? false;
  }

  String getFypTitle() {
    return _currentUser?.fypTitle ?? 'No FYP title set';
  }

  List<String> getFypTechnologies() {
    return _currentUser?.fypTechnologies ?? [];
  }

  bool needsProfileCompletion() {
    return _currentUser?.needsProfileCompletion ?? true;
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  static const String _userKey = 'saved_user';

  Future<void> _saveUserToLocal(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, user.id);
    await prefs.setBool('is_logged_in', true);
  }

  Future<void> _clearUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove('is_logged_in');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}