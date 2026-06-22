import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/local/storage_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '496798876863-qeh0op81u5rv6ibqtrq27pklaodpmgg4.apps.googleusercontent.com',
  );
  final StorageService _storageService = StorageService();

  static const String _userKey = 'saved_user';
  static const String _authTokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static const String DEMO_EMAIL = 'demo@vivabot.com';
  static const String DEMO_PASSWORD = 'demo123';

  // ============================================================
  // GOOGLE SIGN IN (Mobile - Native)
  // ============================================================

  Future<AppUser?> signInWithGoogle() async {
    try {
      print('🟡 Google Sign-In started (Mobile)...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('🔴 Google Sign-In cancelled by user');
        return null;
      }

      print('🟢 Google user: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        print('✅ Firebase user: ${firebaseUser.uid}');

        final appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
          department: '',
          yearOfStudy: 1,
          preferences: UserPreferences.defaults(),
          statistics: UserStatistics.initial(),
          notificationSettings: NotificationSettings.defaults(),
        );

        await _storageService.saveUser(appUser);
        await _saveAuthToken(await firebaseUser.getIdToken());
        await _setLoggedIn(true);
        return appUser;
      }
      return null;
    } catch (e) {
      print('❌ Google sign in error: $e');
      return null;
    }
  }

  // ============================================================
  // GOOGLE SIGN IN (Web - Pure Flutter Firebase)
  // ============================================================

  Future<AppUser?> signInWithGoogleWeb() async {
    try {
      print('🟡 Google Sign-In Web started (Pure Flutter)...');

      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final UserCredential userCredential = await _firebaseAuth.signInWithPopup(googleProvider);

      final User? firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('🔴 Firebase user is null');
        return null;
      }

      print('✅ Sign-in successful: ${firebaseUser.email}');

      final appUser = AppUser(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName ?? 'User',
        createdAt: DateTime.now(),
        department: '',
        yearOfStudy: 1,
        preferences: UserPreferences.defaults(),
        statistics: UserStatistics.initial(),
        notificationSettings: NotificationSettings.defaults(),
      );

      await _storageService.saveUser(appUser);
      await _saveAuthToken(await firebaseUser.getIdToken());
      await _setLoggedIn(true);

      return appUser;
    } catch (e) {
      print('❌ Google sign in web error: $e');
      return null;
    }
  }

  // ============================================================
  // SMART SIGN IN - Detects platform automatically
  // ============================================================

  Future<AppUser?> signInWithGoogleSmart() async {
    if (kIsWeb) {
      print('🌐 Web platform - using Firebase signInWithPopup');
      return await signInWithGoogleWeb();
    } else {
      print('📱 Mobile platform - using native Google Sign-In');
      return await signInWithGoogle();
    }
  }

  // ============================================================
  // EMAIL AUTHENTICATION (Firebase Real)
  // ============================================================

  Future<AppUser?> signInWithEmail(String email, String password) async {
    try {
      print('🟡 Email sign in started for: $email');

      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        print('✅ Email sign in successful: ${firebaseUser.email}');

        final appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
          department: '',
          yearOfStudy: 1,
          preferences: UserPreferences.defaults(),
          statistics: UserStatistics.initial(),
          notificationSettings: NotificationSettings.defaults(),
        );

        await _storageService.saveUser(appUser);
        await _saveAuthToken(await firebaseUser.getIdToken());
        await _setLoggedIn(true);
        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Email sign in error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        print('No user found with this email');
      } else if (e.code == 'wrong-password') {
        print('Wrong password');
      }
      return null;
    } catch (e) {
      print('❌ Email sign in error: $e');
      return null;
    }
  }

  Future<AppUser?> signUpWithEmail(String email, String password, String fullName) async {
    try {
      print('🟡 Email sign up started for: $email');

      final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        // Update display name
        await firebaseUser.updateDisplayName(fullName);
        await firebaseUser.reload();

        print('✅ Email sign up successful: ${firebaseUser.email}');

        final appUser = AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: fullName,
          createdAt: DateTime.now(),
          department: '',
          yearOfStudy: 1,
          preferences: UserPreferences.defaults(),
          statistics: UserStatistics.initial(),
          notificationSettings: NotificationSettings.defaults(),
        );

        await _storageService.saveUser(appUser);
        await _saveAuthToken(await firebaseUser.getIdToken());
        await _setLoggedIn(true);
        return appUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('❌ Email sign up error: ${e.code} - ${e.message}');
      if (e.code == 'email-already-in-use') {
        print('Email already in use');
      } else if (e.code == 'weak-password') {
        print('Password is too weak');
      }
      return null;
    } catch (e) {
      print('❌ Email sign up error: $e');
      return null;
    }
  }

  // ============================================================
  // PASSWORD RESET (Real Firebase)
  // ============================================================

  Future<bool> resetPassword(String email) async {
    try {
      print('🟡 Sending password reset email to: $email');
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Password reset email sent successfully to: $email');
      return true;
    } on FirebaseAuthException catch (e) {
      print('❌ Password reset error: ${e.code} - ${e.message}');
      if (e.code == 'user-not-found') {
        print('No user found with this email address');
      } else if (e.code == 'invalid-email') {
        print('Invalid email format');
      }
      return false;
    } catch (e) {
      print('❌ Password reset error: $e');
      return false;
    }
  }

  // ============================================================
  // GUEST MODE
  // ============================================================

  Future<AppUser> signInAsGuest() async {
    print('🟡 Guest login');
    final guestUser = AppUser.guest();
    await _storageService.saveUser(guestUser);
    await _setLoggedIn(true);
    print('✅ Guest logged in');
    return guestUser;
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore if not signed in
    }
    await _storageService.clearUserData();
    await _clearAuthToken();
    await _setLoggedIn(false);
    print('User signed out successfully');
  }

  // ============================================================
  // USER MANAGEMENT
  // ============================================================

  Future<AppUser?> getCurrentUser() async {
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        return AppUser(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: firebaseUser.displayName ?? 'User',
          createdAt: DateTime.now(),
          department: '',
          yearOfStudy: 1,
          preferences: UserPreferences.defaults(),
          statistics: UserStatistics.initial(),
          notificationSettings: NotificationSettings.defaults(),
        );
      }
      return await _storageService.getUser();
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<AppUser?> updateUserProfile(AppUser user) async {
    try {
      await _storageService.saveUser(user);
      return user;
    } catch (e) {
      print('Update profile error: $e');
      return null;
    }
  }

  Future<void> saveUser(AppUser user) async {
    await _storageService.saveUser(user);
  }

  Future<AppUser?> getSavedUser() async {
    return await _storageService.getUser();
  }

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================

  Future<void> _saveAuthToken(String? token) async {
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<void> _clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  Future<void> _setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // ============================================================
  // DEMO MODE
  // ============================================================

  Future<AppUser> signInDemo() async {
    final demoUser = AppUser.demo();
    await _storageService.saveUser(demoUser);
    await _setLoggedIn(true);
    return demoUser;
  }
}