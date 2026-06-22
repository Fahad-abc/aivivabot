import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class StorageService {
  static const String _userKey = 'saved_user';
  static const String _isLoggedInKey = 'is_logged_in';

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  Future<AppUser?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    if (userString != null && userString.isNotEmpty) {
      try {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        return AppUser.fromJson(userJson);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }
}