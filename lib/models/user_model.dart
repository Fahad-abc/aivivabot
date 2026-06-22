import 'package:flutter/material.dart';

// ============================================================
// USER MODEL - Complete User Data Structure
// ============================================================

class AppUser {
  // ============================================================
  // BASIC INFORMATION
  // ============================================================

  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final DateTime createdAt;
  DateTime? lastLoginAt;
  DateTime? lastActiveAt;

  // ============================================================
  // ACADEMIC INFORMATION
  // ============================================================

  final String department;
  final int yearOfStudy;
  final String? fypTitle;
  final String? fypSupervisor;
  final List<String> fypTechnologies;
  final String? fypDescription;

  // ============================================================
  // APP PREFERENCES
  // ============================================================

  final UserPreferences preferences;

  // ============================================================
  // STATISTICS & PROGRESS
  // ============================================================

  final UserStatistics statistics;

  // ============================================================
  // SESSION HISTORY
  // ============================================================

  final List<String> sessionIds;
  final List<String> reportIds;

  // ============================================================
  // ACHIEVEMENTS
  // ============================================================

  final List<UserAchievement> achievements;
  final List<String> badges;

  // ============================================================
  // NOTIFICATION & SETTINGS
  // ============================================================

  final NotificationSettings notificationSettings;
  final bool isEmailVerified;
  final bool isPremium;
  DateTime? premiumExpiryDate;

  // ============================================================
  // DEVICE & APP INFO
  // ============================================================

  final String? deviceToken;
  final String appVersion;
  final String? lastUsedDevice;

  AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.profilePictureUrl,
    required this.createdAt,
    this.lastLoginAt,
    this.lastActiveAt,
    required this.department,
    required this.yearOfStudy,
    this.fypTitle,
    this.fypSupervisor,
    this.fypTechnologies = const [],
    this.fypDescription,
    required this.preferences,
    required this.statistics,
    this.sessionIds = const [],
    this.reportIds = const [],
    this.achievements = const [],
    this.badges = const [],
    required this.notificationSettings,
    this.isEmailVerified = false,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.deviceToken,
    this.appVersion = '1.0.0',
    this.lastUsedDevice,
  });

  // ============================================================
  // COMPUTED PROPERTIES
  // ============================================================

  String get initials {
    final nameParts = fullName.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 2).toUpperCase();
  }

  String get shortName {
    final nameParts = fullName.trim().split(' ');
    return nameParts[0];
  }

  String get departmentShort {
    switch (department.toLowerCase()) {
      case 'computer science':
        return 'CS';
      case 'software engineering':
        return 'SE';
      case 'information technology':
        return 'IT';
      case 'artificial intelligence':
        return 'AI';
      case 'data science':
        return 'DS';
      default:
        return department.substring(0, 2).toUpperCase();
    }
  }

  bool get hasFypInfo => fypTitle != null && fypTitle!.isNotEmpty;

  bool get isNewUser => statistics.totalSessions == 0;

  bool get isActiveToday {
    if (lastActiveAt == null) return false;
    final today = DateTime.now();
    final lastActive = lastActiveAt!;
    return today.year == lastActive.year &&
        today.month == lastActive.month &&
        today.day == lastActive.day;
  }

  int get daysAsMember => DateTime.now().difference(createdAt).inDays;

  String get memberSince {
    return '${createdAt.month}/${createdAt.year}';
  }

  double get averageScore => statistics.averageScore;

  int get completedSessions => statistics.completedSessions;

  int get currentStreak => statistics.currentStreak;

  bool get needsProfileCompletion {
    return fypTitle == null || fypTitle!.isEmpty;
  }

  // ============================================================
  // METHODS
  // ============================================================

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profilePictureUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? lastActiveAt,
    String? department,
    int? yearOfStudy,
    String? fypTitle,
    String? fypSupervisor,
    List<String>? fypTechnologies,
    String? fypDescription,
    UserPreferences? preferences,
    UserStatistics? statistics,
    List<String>? sessionIds,
    List<String>? reportIds,
    List<UserAchievement>? achievements,
    List<String>? badges,
    NotificationSettings? notificationSettings,
    bool? isEmailVerified,
    bool? isPremium,
    DateTime? premiumExpiryDate,
    String? deviceToken,
    String? appVersion,
    String? lastUsedDevice,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      department: department ?? this.department,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      fypTitle: fypTitle ?? this.fypTitle,
      fypSupervisor: fypSupervisor ?? this.fypSupervisor,
      fypTechnologies: fypTechnologies ?? this.fypTechnologies,
      fypDescription: fypDescription ?? this.fypDescription,
      preferences: preferences ?? this.preferences,
      statistics: statistics ?? this.statistics,
      sessionIds: sessionIds ?? this.sessionIds,
      reportIds: reportIds ?? this.reportIds,
      achievements: achievements ?? this.achievements,
      badges: badges ?? this.badges,
      notificationSettings: notificationSettings ?? this.notificationSettings,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPremium: isPremium ?? this.isPremium,
      premiumExpiryDate: premiumExpiryDate ?? this.premiumExpiryDate,
      deviceToken: deviceToken ?? this.deviceToken,
      appVersion: appVersion ?? this.appVersion,
      lastUsedDevice: lastUsedDevice ?? this.lastUsedDevice,
    );
  }

  void updateLastActive() {
    lastActiveAt = DateTime.now();
  }

  void updateLastLogin() {
    lastLoginAt = DateTime.now();
    lastActiveAt = DateTime.now();
  }

  void addSessionId(String sessionId) {
    sessionIds.add(sessionId);
  }

  void addReportId(String reportId) {
    reportIds.add(reportId);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'department': department,
      'yearOfStudy': yearOfStudy,
      'fypTitle': fypTitle,
      'fypSupervisor': fypSupervisor,
      'fypTechnologies': fypTechnologies,
      'fypDescription': fypDescription,
      'preferences': preferences.toJson(),
      'statistics': statistics.toJson(),
      'sessionIds': sessionIds,
      'reportIds': reportIds,
      'achievements': achievements.map((a) => a.toJson()).toList(),
      'badges': badges,
      'notificationSettings': notificationSettings.toJson(),
      'isEmailVerified': isEmailVerified,
      'isPremium': isPremium,
      'premiumExpiryDate': premiumExpiryDate?.toIso8601String(),
      'deviceToken': deviceToken,
      'appVersion': appVersion,
      'lastUsedDevice': lastUsedDevice,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      profilePictureUrl: json['profilePictureUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      department: json['department'],
      yearOfStudy: json['yearOfStudy'],
      fypTitle: json['fypTitle'],
      fypSupervisor: json['fypSupervisor'],
      fypTechnologies: List<String>.from(json['fypTechnologies'] ?? []),
      fypDescription: json['fypDescription'],
      preferences: UserPreferences.fromJson(json['preferences']),
      statistics: UserStatistics.fromJson(json['statistics']),
      sessionIds: List<String>.from(json['sessionIds'] ?? []),
      reportIds: List<String>.from(json['reportIds'] ?? []),
      achievements: (json['achievements'] as List?)
          ?.map((a) => UserAchievement.fromJson(a))
          .toList() ?? [],
      badges: List<String>.from(json['badges'] ?? []),
      notificationSettings: NotificationSettings.fromJson(json['notificationSettings']),
      isEmailVerified: json['isEmailVerified'] ?? false,
      isPremium: json['isPremium'] ?? false,
      premiumExpiryDate: json['premiumExpiryDate'] != null ? DateTime.parse(json['premiumExpiryDate']) : null,
      deviceToken: json['deviceToken'],
      appVersion: json['appVersion'] ?? '1.0.0',
      lastUsedDevice: json['lastUsedDevice'],
    );
  }

  factory AppUser.guest() {
    return AppUser(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      email: 'guest@aivivabot.com',
      fullName: 'Guest User',
      createdAt: DateTime.now(),
      department: 'Computer Science',
      yearOfStudy: 4,
      preferences: UserPreferences.defaults(),
      statistics: UserStatistics.initial(),
      notificationSettings: NotificationSettings.defaults(),
    );
  }

  factory AppUser.demo() {
    return AppUser(
      id: 'demo_user_001',
      email: 'student@university.edu',
      fullName: 'Ali Raza',
      phoneNumber: '+92 300 1234567',
      profilePictureUrl: null,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 1)),
      department: 'Computer Science',
      yearOfStudy: 4,
      fypTitle: 'AI VivaBot: Intelligent Viva Preparation System',
      fypSupervisor: 'Dr. Sarah Khan',
      fypTechnologies: ['Flutter', 'Gemini AI', 'Firebase', 'Speech Recognition'],
      fypDescription: 'An AI-powered voice assistant for university viva preparation.',
      preferences: UserPreferences.defaults(),
      statistics: UserStatistics.demo(),
      sessionIds: ['session_001', 'session_002', 'session_003'],
      reportIds: ['report_001', 'report_002', 'report_003'],
      achievements: UserAchievement.demoAchievements(),
      badges: ['🏆 First Session', '⭐ 5 Sessions', '📈 80% Score'],
      notificationSettings: NotificationSettings.defaults(),
      isEmailVerified: true,
      isPremium: false,
      appVersion: '1.0.0',
      lastUsedDevice: 'Android - Pixel 7',
    );
  }
}

// ============================================================
// USER PREFERENCES
// ============================================================

class UserPreferences {
  final ThemeMode themeMode;
  final String language;
  final bool voiceInputEnabled;
  final bool voiceOutputEnabled;
  final double voiceSpeed;
  final String preferredExaminerMode;
  final int defaultDurationMinutes;
  final int defaultHintsLimit;
  final bool autoSaveSessions;
  final bool autoGenerateReports;
  final bool dailyReminderEnabled;
  final TimeOfDay? reminderTime;
  final bool soundEffectsEnabled;
  final bool hapticsEnabled;

  UserPreferences({
    required this.themeMode,
    required this.language,
    required this.voiceInputEnabled,
    required this.voiceOutputEnabled,
    required this.voiceSpeed,
    required this.preferredExaminerMode,
    required this.defaultDurationMinutes,
    required this.defaultHintsLimit,
    required this.autoSaveSessions,
    required this.autoGenerateReports,
    required this.dailyReminderEnabled,
    this.reminderTime,
    required this.soundEffectsEnabled,
    required this.hapticsEnabled,
  });

  static UserPreferences defaults() {
    return UserPreferences(
      themeMode: ThemeMode.system,
      language: 'English',
      voiceInputEnabled: true,
      voiceOutputEnabled: true,
      voiceSpeed: 1.0,
      preferredExaminerMode: 'mixed',
      defaultDurationMinutes: 10,
      defaultHintsLimit: 3,
      autoSaveSessions: true,
      autoGenerateReports: true,
      dailyReminderEnabled: false,
      reminderTime: const TimeOfDay(hour: 18, minute: 0),
      soundEffectsEnabled: true,
      hapticsEnabled: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'language': language,
      'voiceInputEnabled': voiceInputEnabled,
      'voiceOutputEnabled': voiceOutputEnabled,
      'voiceSpeed': voiceSpeed,
      'preferredExaminerMode': preferredExaminerMode,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultHintsLimit': defaultHintsLimit,
      'autoSaveSessions': autoSaveSessions,
      'autoGenerateReports': autoGenerateReports,
      'dailyReminderEnabled': dailyReminderEnabled,
      'reminderHour': reminderTime?.hour,
      'reminderMinute': reminderTime?.minute,
      'soundEffectsEnabled': soundEffectsEnabled,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      themeMode: ThemeMode.values[json['themeMode']],
      language: json['language'],
      voiceInputEnabled: json['voiceInputEnabled'],
      voiceOutputEnabled: json['voiceOutputEnabled'],
      voiceSpeed: json['voiceSpeed'],
      preferredExaminerMode: json['preferredExaminerMode'],
      defaultDurationMinutes: json['defaultDurationMinutes'],
      defaultHintsLimit: json['defaultHintsLimit'],
      autoSaveSessions: json['autoSaveSessions'],
      autoGenerateReports: json['autoGenerateReports'],
      dailyReminderEnabled: json['dailyReminderEnabled'],
      reminderTime: json['reminderHour'] != null && json['reminderMinute'] != null
          ? TimeOfDay(hour: json['reminderHour'], minute: json['reminderMinute'])
          : null,
      soundEffectsEnabled: json['soundEffectsEnabled'],
      hapticsEnabled: json['hapticsEnabled'],
    );
  }
}

// ============================================================
// USER STATISTICS
// ============================================================

class UserStatistics {
  final int totalSessions;
  final int completedSessions;
  final int abandonedSessions;
  final int totalQuestionsAnswered;
  final int totalCorrectAnswers;
  final int totalPerfectAnswers;
  final int totalHintsUsed;
  final int totalPracticeMinutes;
  final double averageScore;
  final int highestScore;
  final int lowestScore;
  final int currentStreak;
  final int bestStreak;
  final Map<String, double> categoryAverages;
  final Map<String, int> examinerModeUsage;
  final DateTime lastSessionDate;
  final List<double> weeklyScores;
  final List<double> monthlyScores;

  UserStatistics({
    required this.totalSessions,
    required this.completedSessions,
    required this.abandonedSessions,
    required this.totalQuestionsAnswered,
    required this.totalCorrectAnswers,
    required this.totalPerfectAnswers,
    required this.totalHintsUsed,
    required this.totalPracticeMinutes,
    required this.averageScore,
    required this.highestScore,
    required this.lowestScore,
    required this.currentStreak,
    required this.bestStreak,
    required this.categoryAverages,
    required this.examinerModeUsage,
    required this.lastSessionDate,
    required this.weeklyScores,
    required this.monthlyScores,
  });

  double get accuracy => totalQuestionsAnswered > 0
      ? (totalCorrectAnswers / totalQuestionsAnswered) * 100
      : 0;

  double get perfectionRate => totalQuestionsAnswered > 0
      ? (totalPerfectAnswers / totalQuestionsAnswered) * 100
      : 0;

  double get hintsPerSession => completedSessions > 0
      ? totalHintsUsed / completedSessions
      : 0;

  double get averageMinutesPerSession => completedSessions > 0
      ? totalPracticeMinutes / completedSessions
      : 0;

  double get scoreImprovement {
    if (weeklyScores.length < 2) return 0;
    return weeklyScores.last - weeklyScores.first;
  }

  bool get hasImproved => scoreImprovement > 0;

  static UserStatistics initial() {
    return UserStatistics(
      totalSessions: 0,
      completedSessions: 0,
      abandonedSessions: 0,
      totalQuestionsAnswered: 0,
      totalCorrectAnswers: 0,
      totalPerfectAnswers: 0,
      totalHintsUsed: 0,
      totalPracticeMinutes: 0,
      averageScore: 0,
      highestScore: 0,
      lowestScore: 0,
      currentStreak: 0,
      bestStreak: 0,
      categoryAverages: {},
      examinerModeUsage: {},
      lastSessionDate: DateTime.now(),
      weeklyScores: [],
      monthlyScores: [],
    );
  }

  static UserStatistics demo() {
    return UserStatistics(
      totalSessions: 12,
      completedSessions: 10,
      abandonedSessions: 2,
      totalQuestionsAnswered: 85,
      totalCorrectAnswers: 58,
      totalPerfectAnswers: 12,
      totalHintsUsed: 8,
      totalPracticeMinutes: 125,
      averageScore: 72.5,
      highestScore: 88,
      lowestScore: 45,
      currentStreak: 3,
      bestStreak: 5,
      categoryAverages: {
        'Technical': 78.0,
        'Database': 65.0,
        'API': 70.0,
        'Architecture': 68.0,
      },
      examinerModeUsage: {
        'Strict': 5,
        'Friendly': 3,
        'Technical Expert': 4,
        'Mixed': 2,
      },
      lastSessionDate: DateTime.now().subtract(const Duration(days: 1)),
      weeklyScores: [65, 68, 70, 72, 75, 78, 80],
      monthlyScores: [65, 68, 70, 72, 75, 78, 80, 82, 85, 88],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSessions': totalSessions,
      'completedSessions': completedSessions,
      'abandonedSessions': abandonedSessions,
      'totalQuestionsAnswered': totalQuestionsAnswered,
      'totalCorrectAnswers': totalCorrectAnswers,
      'totalPerfectAnswers': totalPerfectAnswers,
      'totalHintsUsed': totalHintsUsed,
      'totalPracticeMinutes': totalPracticeMinutes,
      'averageScore': averageScore,
      'highestScore': highestScore,
      'lowestScore': lowestScore,
      'currentStreak': currentStreak,
      'bestStreak': bestStreak,
      'categoryAverages': categoryAverages,
      'examinerModeUsage': examinerModeUsage,
      'lastSessionDate': lastSessionDate.toIso8601String(),
      'weeklyScores': weeklyScores,
      'monthlyScores': monthlyScores,
    };
  }

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalSessions: json['totalSessions'],
      completedSessions: json['completedSessions'],
      abandonedSessions: json['abandonedSessions'],
      totalQuestionsAnswered: json['totalQuestionsAnswered'],
      totalCorrectAnswers: json['totalCorrectAnswers'],
      totalPerfectAnswers: json['totalPerfectAnswers'],
      totalHintsUsed: json['totalHintsUsed'],
      totalPracticeMinutes: json['totalPracticeMinutes'],
      averageScore: json['averageScore'],
      highestScore: json['highestScore'],
      lowestScore: json['lowestScore'],
      currentStreak: json['currentStreak'],
      bestStreak: json['bestStreak'],
      categoryAverages: Map<String, double>.from(json['categoryAverages']),
      examinerModeUsage: Map<String, int>.from(json['examinerModeUsage']),
      lastSessionDate: DateTime.parse(json['lastSessionDate']),
      weeklyScores: List<double>.from(json['weeklyScores']),
      monthlyScores: List<double>.from(json['monthlyScores']),
    );
  }
}

// ============================================================
// USER ACHIEVEMENT
// ============================================================

class UserAchievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final DateTime unlockedAt;
  final bool isRare;

  UserAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlockedAt,
    required this.isRare,
  });

  static List<UserAchievement> demoAchievements() {
    return [
      UserAchievement(
        id: 'first_session',
        title: 'First Step',
        description: 'Completed your first viva session',
        icon: '🏆',
        unlockedAt: DateTime.now().subtract(const Duration(days: 30)),
        isRare: false,
      ),
      UserAchievement(
        id: 'five_sessions',
        title: 'Consistent Learner',
        description: 'Completed 5 viva sessions',
        icon: '⭐',
        unlockedAt: DateTime.now().subtract(const Duration(days: 20)),
        isRare: false,
      ),
      UserAchievement(
        id: 'eighty_score',
        title: 'Star Performer',
        description: 'Scored 80% or higher in a session',
        icon: '🌟',
        unlockedAt: DateTime.now().subtract(const Duration(days: 15)),
        isRare: true,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'unlockedAt': unlockedAt.toIso8601String(),
      'isRare': isRare,
    };
  }

  factory UserAchievement.fromJson(Map<String, dynamic> json) {
    return UserAchievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      unlockedAt: DateTime.parse(json['unlockedAt']),
      isRare: json['isRare'],
    );
  }
}

// ============================================================
// NOTIFICATION SETTINGS
// ============================================================

class NotificationSettings {
  final bool studyReminders;
  final bool scoreUpdates;
  final bool achievementAlerts;
  final bool weeklyReports;
  final bool tipsAndTricks;
  final bool promotionalOffers;

  NotificationSettings({
    required this.studyReminders,
    required this.scoreUpdates,
    required this.achievementAlerts,
    required this.weeklyReports,
    required this.tipsAndTricks,
    required this.promotionalOffers,
  });

  static NotificationSettings defaults() {
    return NotificationSettings(
      studyReminders: true,
      scoreUpdates: true,
      achievementAlerts: true,
      weeklyReports: true,
      tipsAndTricks: true,
      promotionalOffers: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studyReminders': studyReminders,
      'scoreUpdates': scoreUpdates,
      'achievementAlerts': achievementAlerts,
      'weeklyReports': weeklyReports,
      'tipsAndTricks': tipsAndTricks,
      'promotionalOffers': promotionalOffers,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      studyReminders: json['studyReminders'],
      scoreUpdates: json['scoreUpdates'],
      achievementAlerts: json['achievementAlerts'],
      weeklyReports: json['weeklyReports'],
      tipsAndTricks: json['tipsAndTricks'],
      promotionalOffers: json['promotionalOffers'],
    );
  }
}