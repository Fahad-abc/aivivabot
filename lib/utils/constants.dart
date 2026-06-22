import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// ============================================================
// APP CONSTANTS - Centralized Configuration
// ============================================================

class AppConstants {
  // ============================================================
  // APP INFO
  // ============================================================

  static const String appName = 'AI VivaBot';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your AI-powered viva preparation assistant';

  // ============================================================
  // API CONFIGURATION
  // ============================================================

  static const String geminiApiUrl = 'https://generativelanguage.googleapis.com/v1';
  static const String geminiModel = 'gemini-2.0-flash-exp';
  static const String openRouterApiUrl = 'https://openrouter.ai/api/v1/chat/completions';
  static const String openRouterModel = 'meta-llama/llama-3-8b-instruct:nitro';
  static String get openRouterApiKey => const String.fromEnvironment('OPENROUTER_API_KEY', defaultValue: '');

  // ✅ SETTINGS FOR PRODUCTION (Render)
  static const bool useProductionBackend = false;  // ← TRUE after Render deploy
  static const String productionBaseUrl = 'https://aiviva-backend.onrender.com';  // ← REPLACE with actual Render URL

  // ✅ YOUR COMPUTER'S IP ADDRESS (for physical device testing)
  static const String _computerIp = '192.168.100.133';  // ← CHANGE THIS TO YOUR IP

  /// Backend API base URL
  static String get backendBaseUrl {
    if (useProductionBackend) {
      return productionBaseUrl;
    }

    // Web
    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    // Android physical device
    if (Platform.isAndroid) {
      return 'http://$_computerIp:8080';
    }

    // iOS
    if (Platform.isIOS) {
      return 'http://$_computerIp:8080';
    }

    return 'http://$_computerIp:8080';
  }

  // ============================================================
  // SESSION DEFAULTS
  // ============================================================

  static const int defaultSessionDuration = 10; // minutes
  static const int defaultTotalQuestions = 15;
  static const int defaultMaxHints = 3;
  static const int defaultMaxRetries = 2;

  static const List<int> availableDurations = [5, 10, 15, 20, 30, 45, 60];
  static const List<int> availableHintOptions = [0, 1, 2, 3, 5];
  static const List<int> availableQuestionCounts = [5, 10, 15, 20, 25, 30];

  // ============================================================
  // SCORING CONSTANTS
  // ============================================================

  static const int perfectScoreThreshold = 90; // percentage
  static const int goodScoreThreshold = 75;
  static const int averageScoreThreshold = 60;
  static const int poorScoreThreshold = 40;

  static const int maxScorePerQuestion = 10;
  static const int minScorePerQuestion = 0;

  // ============================================================
  // TIMING CONSTANTS
  // ============================================================

  static const int splashDelay = 2000; // milliseconds
  static const int snackBarDuration = 3000; // milliseconds
  static const int animationDuration = 300; // milliseconds
  static const int pageTransitionDuration = 400; // milliseconds

  // ============================================================
  // FILE CONSTANTS
  // ============================================================

  static const int maxFileSizeMB = 10;
  static const List<String> allowedFileExtensions = ['pdf', 'docx', 'doc'];
  static const String sessionsFileName = 'sessions.json';
  static const String reportsFileName = 'reports.json';
  static const String backupFileName = 'viva_bot_backup.json';

  // ============================================================
  // SHARED PREFERENCES KEYS
  // ============================================================

  static const String prefUserKey = 'saved_user';
  static const String prefIsLoggedInKey = 'is_logged_in';
  static const String prefThemeModeKey = 'theme_mode';
  static const String prefIsDocumentUploadedKey = 'isDocumentUploaded';
  static const String prefDocumentPathKey = 'documentPath';
  static const String prefDocumentNameKey = 'documentName';

  // Voice Settings Keys
  static const String prefVoiceInputEnabled = 'voiceInputEnabled';
  static const String prefVoiceOutputEnabled = 'voiceOutputEnabled';
  static const String prefVoiceSpeed = 'voiceSpeed';
  static const String prefVoicePitch = 'voicePitch';
  static const String prefSelectedVoice = 'selectedVoice';

  // Session Settings Keys
  static const String prefPreferredExaminerMode = 'preferredExaminerMode';
  static const String prefDefaultDuration = 'defaultDuration';
  static const String prefDefaultHints = 'defaultHints';
  static const String prefAutoSaveSessions = 'autoSaveSessions';
  static const String prefAutoGenerateReports = 'autoGenerateReports';

  // Notification Settings Keys
  static const String prefDailyReminder = 'dailyReminder';
  static const String prefReminderHour = 'reminderHour';
  static const String prefReminderMinute = 'reminderMinute';
  static const String prefStudyReminders = 'studyReminders';
  static const String prefScoreUpdates = 'scoreUpdates';
  static const String prefAchievementAlerts = 'achievementAlerts';
  static const String prefWeeklyReports = 'weeklyReports';

  // Data Settings Keys
  static const String prefAutoBackup = 'autoBackup';
  static const String prefLastBackupDate = 'lastBackupDate';

  // ============================================================
  // ROUTE NAMES
  // ============================================================

  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeProfileSetup = '/profile-setup';
  static const String routeDashboard = '/dashboard';
  static const String routeExaminerSelection = '/examiner-selection';
  static const String routeDocumentUpload = '/document-upload';
  static const String routeVivaSession = '/viva-session';
  static const String routePauseMenu = '/pause-menu';
  static const String routeSessionComplete = '/session-complete';
  static const String routeDetailedReport = '/detailed-report';
  static const String routeWeakAreas = '/weak-areas';
  static const String routeProgressOverTime = '/progress-over-time';
  static const String routeSettings = '/settings';
  static const String routeHelp = '/help';

  // ============================================================
  // ERROR MESSAGES
  // ============================================================

  static const String errorDefault = 'Something went wrong. Please try again.';
  static const String errorNetwork = 'Network error. Please check your internet connection.';
  static const String errorApi = 'API error. Please try again later.';
  static const String errorAuth = 'Authentication failed. Please sign in again.';
  static const String errorFileUpload = 'File upload failed. Please try again.';
  static const String errorFileSize = 'File size exceeds limit. Maximum size is 10MB.';
  static const String errorFileType = 'Invalid file type. Please upload PDF or DOCX.';
  static const String errorNoDocument = 'Please upload your FYP document first.';
  static const String errorVoiceNotSupported = 'Voice recognition is not supported on this device.';

  // ============================================================
  // SUCCESS MESSAGES
  // ============================================================

  static const String successLogin = 'Logged in successfully!';
  static const String successLogout = 'Logged out successfully!';
  static const String successProfileUpdate = 'Profile updated successfully!';
  static const String successDocumentUpload = 'Document uploaded successfully!';
  static const String successSessionSave = 'Session saved successfully!';
  static const String successReportGenerated = 'Report generated successfully!';
  static const String successSettingsSaved = 'Settings saved successfully!';

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Get formatted file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get formatted duration from minutes
  static String formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes min';
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  static bool isStrongPassword(String password) {
    return password.length >= 6;
  }

  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

// ============================================================
// ANIMATION CONSTANTS
// ============================================================

class AnimationConstants {
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration slowest = Duration(milliseconds: 1000);

  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve elasticCurve = Curves.elasticOut;
}

// ============================================================
// PADDING & SPACING CONSTANTS
// ============================================================

class SpacingConstants {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
}

// ============================================================
// BORDER RADIUS CONSTANTS
// ============================================================

class BorderRadiusConstants {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 28.0;
  static const double circular = 40.0;

  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusCircular = BorderRadius.all(Radius.circular(circular));
}

// ============================================================
// SHADOW CONSTANTS
// ============================================================

class ShadowConstants {
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> getColoredShadow(Color color, {double blur = 20, double opacity = 0.3}) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blur,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

// ============================================================
// EXAMINER MODE CONSTANTS
// ============================================================

class ExaminerModeConstants {
  static const String friendly = 'friendly';
  static const String strict = 'strict';
  static const String technical = 'technical';
  static const String mixed = 'mixed';

  static const List<String> allModes = [friendly, strict, technical, mixed];

  static String getDisplayName(String mode) {
    switch (mode) {
      case friendly: return 'Friendly Examiner';
      case strict: return 'Strict Examiner';
      case technical: return 'Technical Expert';
      case mixed: return 'Mixed Mode';
      default: return 'Unknown';
    }
  }
}

// ============================================================
// QUESTION CATEGORY CONSTANTS
// ============================================================

class QuestionCategoryConstants {
  static const String technical = 'Technical';
  static const String database = 'Database';
  static const String api = 'API';
  static const String security = 'Security';
  static const String architecture = 'Architecture';
  static const String frontend = 'Frontend';
  static const String backend = 'Backend';
  static const String general = 'General';

  static const List<String> allCategories = [
    technical, database, api, security, architecture, frontend, backend, general
  ];
}

// ============================================================
// DEPARTMENT CONSTANTS
// ============================================================

class DepartmentConstants {
  static const String computerScience = 'Computer Science';
  static const String softwareEngineering = 'Software Engineering';
  static const String informationTechnology = 'Information Technology';
  static const String artificialIntelligence = 'Artificial Intelligence';
  static const String dataScience = 'Data Science';
  static const String cyberSecurity = 'Cyber Security';

  static const List<String> allDepartments = [
    computerScience,
    softwareEngineering,
    informationTechnology,
    artificialIntelligence,
    dataScience,
    cyberSecurity,
  ];
}

// ============================================================
// TECHNOLOGY CONSTANTS
// ============================================================

class TechnologyConstants {
  static const List<String> popularTechnologies = [
    'Flutter',
    'React Native',
    'Firebase',
    'MongoDB',
    'MySQL',
    'PostgreSQL',
    'Node.js',
    'Python',
    'Java',
    'Kotlin',
    'Swift',
    'TensorFlow',
    'PyTorch',
    'AWS',
    'Google Cloud',
    'Azure',
    'Docker',
    'Kubernetes',
  ];
}

// ============================================================
// MILESTONE CONSTANTS
// ============================================================

class MilestoneConstants {
  static const int firstSession = 1;
  static const int fiveSessions = 5;
  static const int tenSessions = 10;
  static const int twentySessions = 20;
  static const int fiftySessions = 50;

  static const int perfectScoreMilestone = 90;
  static const int goodScoreMilestone = 80;

  static const int sevenDayStreak = 7;
  static const int thirtyDayStreak = 30;
}