import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// SETTINGS PROVIDER - Manages App Settings State
// ============================================================

class SettingsProvider extends ChangeNotifier {
  // ============================================================
  // STATE VARIABLES
  // ============================================================

  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  // Voice Settings
  bool _voiceInputEnabled = true;
  bool _voiceOutputEnabled = true;
  double _voiceSpeed = 1.0;
  double _voicePitch = 1.0;
  String _selectedVoice = 'Female (Default)';

  // Session Settings
  String _preferredExaminerMode = 'Mixed';
  int _defaultDuration = 10;
  int _defaultHints = 3;
  bool _autoSaveSessions = true;
  bool _autoGenerateReports = true;

  // Notification Settings
  bool _dailyReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 18, minute: 0);
  bool _studyReminders = true;
  bool _scoreUpdates = true;
  bool _achievementAlerts = true;
  bool _weeklyReports = true;

  // Data Settings
  bool _autoBackup = false;
  DateTime? _lastBackupDate;

  // Loading State
  bool _isLoading = false;

  // ============================================================
  // GETTERS
  // ============================================================

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  bool get voiceInputEnabled => _voiceInputEnabled;
  bool get voiceOutputEnabled => _voiceOutputEnabled;
  double get voiceSpeed => _voiceSpeed;
  double get voicePitch => _voicePitch;
  String get selectedVoice => _selectedVoice;

  String get preferredExaminerMode => _preferredExaminerMode;
  int get defaultDuration => _defaultDuration;
  int get defaultHints => _defaultHints;
  bool get autoSaveSessions => _autoSaveSessions;
  bool get autoGenerateReports => _autoGenerateReports;

  bool get dailyReminder => _dailyReminder;
  TimeOfDay get reminderTime => _reminderTime;
  bool get studyReminders => _studyReminders;
  bool get scoreUpdates => _scoreUpdates;
  bool get achievementAlerts => _achievementAlerts;
  bool get weeklyReports => _weeklyReports;

  bool get autoBackup => _autoBackup;
  DateTime? get lastBackupDate => _lastBackupDate;

  bool get isLoading => _isLoading;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  SettingsProvider() {
    loadSettings();
  }

  /// Load all settings from shared preferences
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Theme Settings
      final themeModeIndex = prefs.getInt('themeMode') ?? 0;
      _themeMode = ThemeMode.values[themeModeIndex];
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;

      // Voice Settings
      _voiceInputEnabled = prefs.getBool('voiceInputEnabled') ?? true;
      _voiceOutputEnabled = prefs.getBool('voiceOutputEnabled') ?? true;
      _voiceSpeed = prefs.getDouble('voiceSpeed') ?? 1.0;
      _voicePitch = prefs.getDouble('voicePitch') ?? 1.0;
      _selectedVoice = prefs.getString('selectedVoice') ?? 'Female (Default)';

      // Session Settings
      final mode = prefs.getString('preferredExaminerMode') ?? 'Mixed';
      if (mode.toLowerCase() == 'friendly') {
        _preferredExaminerMode = 'Friendly';
      } else if (mode.toLowerCase() == 'strict') {
        _preferredExaminerMode = 'Strict';
      } else if (mode.toLowerCase() == 'technical' || mode.toLowerCase() == 'technical expert') {
        _preferredExaminerMode = 'Technical Expert';
      } else {
        _preferredExaminerMode = 'Mixed';
      }

      final savedDuration = prefs.getInt('defaultDuration') ?? 10;
      _defaultDuration = [5, 10, 15, 20, 30, 45, 60].contains(savedDuration) ? savedDuration : 10;

      final savedHints = prefs.getInt('defaultHints') ?? 3;
      _defaultHints = [0, 1, 2, 3, 5].contains(savedHints) ? savedHints : 3;
      _autoSaveSessions = prefs.getBool('autoSaveSessions') ?? true;
      _autoGenerateReports = prefs.getBool('autoGenerateReports') ?? true;

      // Notification Settings
      _dailyReminder = prefs.getBool('dailyReminder') ?? false;
      final hour = prefs.getInt('reminderHour');
      final minute = prefs.getInt('reminderMinute');
      if (hour != null && minute != null) {
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      }
      _studyReminders = prefs.getBool('studyReminders') ?? true;
      _scoreUpdates = prefs.getBool('scoreUpdates') ?? true;
      _achievementAlerts = prefs.getBool('achievementAlerts') ?? true;
      _weeklyReports = prefs.getBool('weeklyReports') ?? true;

      // Data Settings
      _autoBackup = prefs.getBool('autoBackup') ?? false;
      final backupDate = prefs.getString('lastBackupDate');
      if (backupDate != null) {
        _lastBackupDate = DateTime.parse(backupDate);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // THEME SETTINGS
  // ============================================================

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    await prefs.setBool('isDarkMode', _isDarkMode);

    print('Theme mode set to: $mode');
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleDarkMode(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  // ============================================================
  // VOICE SETTINGS
  // ============================================================

  Future<void> setVoiceInputEnabled(bool enabled) async {
    _voiceInputEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceInputEnabled', enabled);
    notifyListeners();
  }

  Future<void> setVoiceOutputEnabled(bool enabled) async {
    _voiceOutputEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voiceOutputEnabled', enabled);
    notifyListeners();
  }

  Future<void> setVoiceSpeed(double speed) async {
    _voiceSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('voiceSpeed', speed);
    notifyListeners();
  }

  Future<void> setVoicePitch(double pitch) async {
    _voicePitch = pitch;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('voicePitch', pitch);
    notifyListeners();
  }

  Future<void> setSelectedVoice(String voice) async {
    _selectedVoice = voice;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedVoice', voice);
    notifyListeners();
  }

  // ============================================================
  // SESSION SETTINGS
  // ============================================================

  Future<void> setPreferredExaminerMode(String mode) async {
    _preferredExaminerMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredExaminerMode', mode);
    notifyListeners();
  }

  Future<void> setDefaultDuration(int minutes) async {
    _defaultDuration = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultDuration', minutes);
    notifyListeners();
  }

  Future<void> setDefaultHints(int hints) async {
    _defaultHints = hints;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('defaultHints', hints);
    notifyListeners();
  }

  Future<void> setAutoSaveSessions(bool enabled) async {
    _autoSaveSessions = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoSaveSessions', enabled);
    notifyListeners();
  }

  Future<void> setAutoGenerateReports(bool enabled) async {
    _autoGenerateReports = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoGenerateReports', enabled);
    notifyListeners();
  }

  // ============================================================
  // NOTIFICATION SETTINGS
  // ============================================================

  Future<void> setDailyReminder(bool enabled) async {
    _dailyReminder = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dailyReminder', enabled);
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderHour', time.hour);
    await prefs.setInt('reminderMinute', time.minute);
    notifyListeners();
  }

  Future<void> setStudyReminders(bool enabled) async {
    _studyReminders = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('studyReminders', enabled);
    notifyListeners();
  }

  Future<void> setScoreUpdates(bool enabled) async {
    _scoreUpdates = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scoreUpdates', enabled);
    notifyListeners();
  }

  Future<void> setAchievementAlerts(bool enabled) async {
    _achievementAlerts = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('achievementAlerts', enabled);
    notifyListeners();
  }

  Future<void> setWeeklyReports(bool enabled) async {
    _weeklyReports = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklyReports', enabled);
    notifyListeners();
  }

  // ============================================================
  // DATA SETTINGS
  // ============================================================

  Future<void> setAutoBackup(bool enabled) async {
    _autoBackup = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoBackup', enabled);
    notifyListeners();
  }

  Future<void> updateLastBackupDate() async {
    _lastBackupDate = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastBackupDate', _lastBackupDate!.toIso8601String());
    notifyListeners();
  }

  // ============================================================
  // RESET METHODS
  // ============================================================

  /// Reset all settings to default
  Future<void> resetAllSettings() async {
    await setThemeMode(ThemeMode.light);
    await setVoiceInputEnabled(true);
    await setVoiceOutputEnabled(true);
    await setVoiceSpeed(1.0);
    await setVoicePitch(1.0);
    await setSelectedVoice('Female (Default)');
    await setPreferredExaminerMode('Mixed');
    await setDefaultDuration(10);
    await setDefaultHints(3);
    await setAutoSaveSessions(true);
    await setAutoGenerateReports(true);
    await setDailyReminder(false);
    await setStudyReminders(true);
    await setScoreUpdates(true);
    await setAchievementAlerts(true);
    await setWeeklyReports(true);
    await setAutoBackup(false);
  }
}