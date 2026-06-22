import 'package:flutter/material.dart';
import 'question_model.dart';

// ============================================================
// MAIN REPORT MODEL
// ============================================================

class VivaReport {
  // Basic Information
  final String id;
  final String sessionId;
  final DateTime generatedAt;
  final DateTime sessionDate;

  // Session Metadata
  final String examinerMode;
  final int totalQuestions;
  final int attemptedQuestions;
  final int durationMinutes;
  final int hintsUsed;

  // Scores
  final int overallScore;
  final int maxPossibleScore;
  final int technicalScore;
  final int communicationScore;
  final int confidenceScore;

  // Question Details
  final List<QuestionReport> questionReports;

  // Weak Areas Analysis
  final List<WeakArea> weakAreas;
  final List<StrongArea> strongAreas;

  // Performance by Category
  final Map<QuestionCategory, CategoryPerformance> categoryPerformance;

  // AI Recommendations
  final List<String> recommendations;
  final List<String> studyResources;

  // Progress Tracking
  final int sessionNumber;
  final int improvementSinceLastSession;
  final bool isPersonalBest;

  // Additional Data
  final String? pdfDownloadPath;
  final bool isShared;
  final Map<String, dynamic>? customData;

  VivaReport({
    required this.id,
    required this.sessionId,
    required this.generatedAt,
    required this.sessionDate,
    required this.examinerMode,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.durationMinutes,
    required this.hintsUsed,
    required this.overallScore,
    required this.maxPossibleScore,
    required this.technicalScore,
    required this.communicationScore,
    required this.confidenceScore,
    required this.questionReports,
    required this.weakAreas,
    required this.strongAreas,
    required this.categoryPerformance,
    required this.recommendations,
    required this.studyResources,
    required this.sessionNumber,
    required this.improvementSinceLastSession,
    required this.isPersonalBest,
    this.pdfDownloadPath,
    this.isShared = false,
    this.customData,
  });

  // ============================================================
  // COMPUTED PROPERTIES
  // ============================================================

  double get overallScorePercentage =>
      maxPossibleScore > 0 ? (overallScore / maxPossibleScore) * 100 : 0;

  double get technicalScorePercentage => (technicalScore / 100) * 100;
  double get communicationScorePercentage => (communicationScore / 100) * 100;
  double get confidenceScorePercentage => (confidenceScore / 100) * 100;

  double get averageScorePerQuestion =>
      attemptedQuestions > 0 ? overallScore / attemptedQuestions : 0;

  int get correctAnswersCount =>
      questionReports.where((q) => q.isCorrect).length;

  int get perfectAnswersCount =>
      questionReports.where((q) => q.isPerfect).length;

  int get failedAnswersCount =>
      questionReports.where((q) => q.isFailed).length;

  int get notAnsweredCount => totalQuestions - attemptedQuestions;

  String get performanceLevel {
    if (overallScorePercentage >= 90) return 'Excellent';
    if (overallScorePercentage >= 75) return 'Good';
    if (overallScorePercentage >= 60) return 'Satisfactory';
    if (overallScorePercentage >= 40) return 'Needs Improvement';
    return 'Requires Significant Work';
  }

  Color get performanceColor {
    if (overallScorePercentage >= 90) return const Color(0xFF4CAF50);
    if (overallScorePercentage >= 75) return const Color(0xFF2A5CFF);
    if (overallScorePercentage >= 60) return const Color(0xFFFFB800);
    if (overallScorePercentage >= 40) return const Color(0xFFFF9800);
    return const Color(0xFFFF3B5C);
  }

  IconData get performanceIcon {
    if (overallScorePercentage >= 90) return Icons.emoji_events;
    if (overallScorePercentage >= 75) return Icons.thumb_up;
    if (overallScorePercentage >= 60) return Icons.trending_up;
    if (overallScorePercentage >= 40) return Icons.warning;
    return Icons.error;
  }

  String get performanceMessage {
    if (overallScorePercentage >= 90) {
      return 'Outstanding! You\'re well prepared for your viva.';
    }
    if (overallScorePercentage >= 75) {
      return 'Good job! Focus on weak areas to excel.';
    }
    if (overallScorePercentage >= 60) {
      return 'Satisfactory performance. Review the ideal answers.';
    }
    if (overallScorePercentage >= 40) {
      return 'More practice needed. Start with weak topics.';
    }
    return 'Don\'t worry! Use the study resources and try again.';
  }

  List<QuestionReport> get weakQuestions =>
      questionReports.where((q) => q.scorePercentage < 50).toList();

  List<QuestionReport> get strongQuestions =>
      questionReports.where((q) => q.scorePercentage >= 80).toList();

  List<QuestionCategory> get topWeakCategories {
    final weakCategories = categoryPerformance.entries
        .where((e) => e.value.scorePercentage < 60)
        .toList();
    weakCategories.sort((a, b) => a.value.scorePercentage.compareTo(b.value.scorePercentage));
    return weakCategories.map((e) => e.key).take(3).toList();
  }

  List<QuestionCategory> get topStrongCategories {
    final strongCategories = categoryPerformance.entries
        .where((e) => e.value.scorePercentage >= 75)
        .toList();
    strongCategories.sort((a, b) => b.value.scorePercentage.compareTo(a.value.scorePercentage));
    return strongCategories.map((e) => e.key).take(3).toList();
  }

  // ============================================================
  // METHODS
  // ============================================================

  VivaReport copyWith({
    String? id,
    String? sessionId,
    DateTime? generatedAt,
    DateTime? sessionDate,
    String? examinerMode,
    int? totalQuestions,
    int? attemptedQuestions,
    int? durationMinutes,
    int? hintsUsed,
    int? overallScore,
    int? maxPossibleScore,
    int? technicalScore,
    int? communicationScore,
    int? confidenceScore,
    List<QuestionReport>? questionReports,
    List<WeakArea>? weakAreas,
    List<StrongArea>? strongAreas,
    Map<QuestionCategory, CategoryPerformance>? categoryPerformance,
    List<String>? recommendations,
    List<String>? studyResources,
    int? sessionNumber,
    int? improvementSinceLastSession,
    bool? isPersonalBest,
    String? pdfDownloadPath,
    bool? isShared,
    Map<String, dynamic>? customData,
  }) {
    return VivaReport(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      generatedAt: generatedAt ?? this.generatedAt,
      sessionDate: sessionDate ?? this.sessionDate,
      examinerMode: examinerMode ?? this.examinerMode,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      attemptedQuestions: attemptedQuestions ?? this.attemptedQuestions,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      overallScore: overallScore ?? this.overallScore,
      maxPossibleScore: maxPossibleScore ?? this.maxPossibleScore,
      technicalScore: technicalScore ?? this.technicalScore,
      communicationScore: communicationScore ?? this.communicationScore,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      questionReports: questionReports ?? this.questionReports,
      weakAreas: weakAreas ?? this.weakAreas,
      strongAreas: strongAreas ?? this.strongAreas,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
      recommendations: recommendations ?? this.recommendations,
      studyResources: studyResources ?? this.studyResources,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      improvementSinceLastSession: improvementSinceLastSession ?? this.improvementSinceLastSession,
      isPersonalBest: isPersonalBest ?? this.isPersonalBest,
      pdfDownloadPath: pdfDownloadPath ?? this.pdfDownloadPath,
      isShared: isShared ?? this.isShared,
      customData: customData ?? this.customData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sessionId': sessionId,
      'generatedAt': generatedAt.toIso8601String(),
      'sessionDate': sessionDate.toIso8601String(),
      'examinerMode': examinerMode,
      'totalQuestions': totalQuestions,
      'attemptedQuestions': attemptedQuestions,
      'durationMinutes': durationMinutes,
      'hintsUsed': hintsUsed,
      'overallScore': overallScore,
      'maxPossibleScore': maxPossibleScore,
      'technicalScore': technicalScore,
      'communicationScore': communicationScore,
      'confidenceScore': confidenceScore,
      'questionReports': questionReports.map((q) => q.toJson()).toList(),
      'weakAreas': weakAreas.map((w) => w.toJson()).toList(),
      'strongAreas': strongAreas.map((s) => s.toJson()).toList(),
      'categoryPerformance': categoryPerformance.map((key, value) => MapEntry(key.name, value.toJson())),
      'recommendations': recommendations,
      'studyResources': studyResources,
      'sessionNumber': sessionNumber,
      'improvementSinceLastSession': improvementSinceLastSession,
      'isPersonalBest': isPersonalBest,
      'pdfDownloadPath': pdfDownloadPath,
      'isShared': isShared,
      'customData': customData,
    };
  }

  factory VivaReport.fromJson(Map<String, dynamic> json) {
    return VivaReport(
      id: json['id'],
      sessionId: json['sessionId'],
      generatedAt: DateTime.parse(json['generatedAt']),
      sessionDate: DateTime.parse(json['sessionDate']),
      examinerMode: json['examinerMode'],
      totalQuestions: json['totalQuestions'],
      attemptedQuestions: json['attemptedQuestions'],
      durationMinutes: json['durationMinutes'],
      hintsUsed: json['hintsUsed'],
      overallScore: json['overallScore'],
      maxPossibleScore: json['maxPossibleScore'],
      technicalScore: json['technicalScore'],
      communicationScore: json['communicationScore'],
      confidenceScore: json['confidenceScore'],
      questionReports: (json['questionReports'] as List)
          .map((q) => QuestionReport.fromJson(q))
          .toList(),
      weakAreas: (json['weakAreas'] as List)
          .map((w) => WeakArea.fromJson(w))
          .toList(),
      strongAreas: (json['strongAreas'] as List)
          .map((s) => StrongArea.fromJson(s))
          .toList(),
      categoryPerformance: (json['categoryPerformance'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          QuestionCategoryExtension.fromString(key),
          CategoryPerformance.fromJson(value),
        ),
      ),
      recommendations: List<String>.from(json['recommendations']),
      studyResources: List<String>.from(json['studyResources']),
      sessionNumber: json['sessionNumber'],
      improvementSinceLastSession: json['improvementSinceLastSession'],
      isPersonalBest: json['isPersonalBest'],
      pdfDownloadPath: json['pdfDownloadPath'],
      isShared: json['isShared'] ?? false,
      customData: json['customData'],
    );
  }

  String getFormattedDate() {
    return '${sessionDate.day}/${sessionDate.month}/${sessionDate.year}';
  }

  String getFormattedTime() {
    return '${sessionDate.hour.toString().padLeft(2, '0')}:${sessionDate.minute.toString().padLeft(2, '0')}';
  }

  String getDurationString() {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      final hourText = hours == 1 ? 'hour' : 'hours';
      return '$hours $hourText $minutes min';
    }
    return '$minutes minutes';
  }
}

// ============================================================
// QUESTION REPORT (per question analysis)
// ============================================================

class QuestionReport {
  final String questionId;
  final String questionText;
  final String userAnswer;
  final String idealAnswer;
  final int score;
  final int maxScore;
  final String feedback;
  final List<String> missingPoints;
  final List<String> strongPoints;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final bool isAnswered;
  final DateTime answeredAt;
  final int timeTakenSeconds;
  final bool hintUsed;

  QuestionReport({
    required this.questionId,
    required this.questionText,
    required this.userAnswer,
    required this.idealAnswer,
    required this.score,
    required this.maxScore,
    required this.feedback,
    required this.missingPoints,
    required this.strongPoints,
    required this.category,
    required this.difficulty,
    required this.isAnswered,
    required this.answeredAt,
    required this.timeTakenSeconds,
    required this.hintUsed,
  });

  double get scorePercentage => (score / maxScore) * 100;

  bool get isCorrect => scorePercentage >= 60;
  bool get isPerfect => scorePercentage >= 90;
  bool get isFailed => scorePercentage < 40;

  String get status {
    if (!isAnswered) return 'Not Answered';
    if (isPerfect) return 'Perfect';
    if (isCorrect) return 'Correct';
    if (isFailed) return 'Failed';
    return 'Partial';
  }

  Color get statusColor {
    if (!isAnswered) return Colors.grey;
    if (isPerfect) return const Color(0xFF4CAF50);
    if (isCorrect) return const Color(0xFF2A5CFF);
    if (isFailed) return const Color(0xFFFF3B5C);
    return const Color(0xFFFFB800);
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'questionText': questionText,
      'userAnswer': userAnswer,
      'idealAnswer': idealAnswer,
      'score': score,
      'maxScore': maxScore,
      'feedback': feedback,
      'missingPoints': missingPoints,
      'strongPoints': strongPoints,
      'category': category.name,
      'difficulty': difficulty.name,
      'isAnswered': isAnswered,
      'answeredAt': answeredAt.toIso8601String(),
      'timeTakenSeconds': timeTakenSeconds,
      'hintUsed': hintUsed,
    };
  }

  factory QuestionReport.fromJson(Map<String, dynamic> json) {
    return QuestionReport(
      questionId: json['questionId'],
      questionText: json['questionText'],
      userAnswer: json['userAnswer'],
      idealAnswer: json['idealAnswer'],
      score: json['score'],
      maxScore: json['maxScore'],
      feedback: json['feedback'],
      missingPoints: List<String>.from(json['missingPoints']),
      strongPoints: List<String>.from(json['strongPoints']),
      category: QuestionCategoryExtension.fromString(json['category']),
      difficulty: QuestionDifficultyExtension.fromString(json['difficulty']),
      isAnswered: json['isAnswered'],
      answeredAt: DateTime.parse(json['answeredAt']),
      timeTakenSeconds: json['timeTakenSeconds'],
      hintUsed: json['hintUsed'],
    );
  }
}

// ============================================================
// WEAK AREA MODEL
// ============================================================

class WeakArea {
  final String topic;
  final double scorePercentage;
  final int questionsCount;
  final List<String> specificIssues;
  final String recommendation;
  final bool isCritical;

  WeakArea({
    required this.topic,
    required this.scorePercentage,
    required this.questionsCount,
    required this.specificIssues,
    required this.recommendation,
    required this.isCritical,
  });

  Color get severityColor {
    if (scorePercentage < 30) return const Color(0xFFFF3B5C);
    if (scorePercentage < 50) return const Color(0xFFFF9800);
    return const Color(0xFFFFB800);
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'scorePercentage': scorePercentage,
      'questionsCount': questionsCount,
      'specificIssues': specificIssues,
      'recommendation': recommendation,
      'isCritical': isCritical,
    };
  }

  factory WeakArea.fromJson(Map<String, dynamic> json) {
    return WeakArea(
      topic: json['topic'],
      scorePercentage: json['scorePercentage'],
      questionsCount: json['questionsCount'],
      specificIssues: List<String>.from(json['specificIssues']),
      recommendation: json['recommendation'],
      isCritical: json['isCritical'],
    );
  }
}

// ============================================================
// STRONG AREA MODEL
// ============================================================

class StrongArea {
  final String topic;
  final double scorePercentage;
  final int questionsCount;
  final List<String> strengths;
  final String encouragement;

  StrongArea({
    required this.topic,
    required this.scorePercentage,
    required this.questionsCount,
    required this.strengths,
    required this.encouragement,
  });

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'scorePercentage': scorePercentage,
      'questionsCount': questionsCount,
      'strengths': strengths,
      'encouragement': encouragement,
    };
  }

  factory StrongArea.fromJson(Map<String, dynamic> json) {
    return StrongArea(
      topic: json['topic'],
      scorePercentage: json['scorePercentage'],
      questionsCount: json['questionsCount'],
      strengths: List<String>.from(json['strengths']),
      encouragement: json['encouragement'],
    );
  }
}

// ============================================================
// CATEGORY PERFORMANCE MODEL
// ============================================================

class CategoryPerformance {
  final QuestionCategory category;
  final int totalQuestions;
  final int attemptedQuestions;
  final int totalScore;
  final int maxPossibleScore;
  final double averageTimeSeconds;

  CategoryPerformance({
    required this.category,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.averageTimeSeconds,
  });

  double get scorePercentage =>
      maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0;

  double get completionRate =>
      totalQuestions > 0 ? (attemptedQuestions / totalQuestions) * 100 : 0;

  String get performanceLevel {
    if (scorePercentage >= 80) return 'Strong';
    if (scorePercentage >= 60) return 'Good';
    if (scorePercentage >= 40) return 'Average';
    return 'Weak';
  }

  Color get performanceColor {
    if (scorePercentage >= 80) return const Color(0xFF4CAF50);
    if (scorePercentage >= 60) return const Color(0xFF2A5CFF);
    if (scorePercentage >= 40) return const Color(0xFFFFB800);
    return const Color(0xFFFF3B5C);
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'totalQuestions': totalQuestions,
      'attemptedQuestions': attemptedQuestions,
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'averageTimeSeconds': averageTimeSeconds,
    };
  }

  factory CategoryPerformance.fromJson(Map<String, dynamic> json) {
    return CategoryPerformance(
      category: QuestionCategoryExtension.fromString(json['category']),
      totalQuestions: json['totalQuestions'],
      attemptedQuestions: json['attemptedQuestions'],
      totalScore: json['totalScore'],
      maxPossibleScore: json['maxPossibleScore'],
      averageTimeSeconds: json['averageTimeSeconds'],
    );
  }
}

// ============================================================
// SAMPLE REPORT (for testing/demo)
// ============================================================

class SampleReportGenerator {
  static VivaReport getSampleReport() {
    final questionReports = [
      QuestionReport(
        questionId: 'q1',
        questionText: 'Why did you choose Flutter for your project?',
        userAnswer: 'Because it makes cross-platform apps easily.',
        idealAnswer: 'Flutter was chosen because it allows cross-platform development with a single codebase, provides near-native performance through the Skia rendering engine, and offers a rich set of customizable widgets.',
        score: 6,
        maxScore: 10,
        feedback: 'Good start but missing technical details about Skia rendering and widget system.',
        missingPoints: ['Performance details', 'Skia rendering engine', 'Widget ecosystem'],
        strongPoints: ['Cross-platform concept correct'],
        category: QuestionCategory.technical,
        difficulty: QuestionDifficulty.medium,
        isAnswered: true,
        answeredAt: DateTime.now().subtract(const Duration(minutes: 5)),
        timeTakenSeconds: 45,
        hintUsed: false,
      ),
      QuestionReport(
        questionId: 'q2',
        questionText: 'What is database normalization?',
        userAnswer: 'I am not sure about this.',
        idealAnswer: 'Normalization is the process of organizing database tables to reduce data redundancy and improve data integrity through normal forms like 1NF, 2NF, and 3NF.',
        score: 2,
        maxScore: 10,
        feedback: 'Please review database normalization concepts. Focus on normal forms.',
        missingPoints: ['Definition of normalization', 'Normal forms (1NF, 2NF, 3NF)', 'Purpose of reducing redundancy'],
        strongPoints: [],
        category: QuestionCategory.database,
        difficulty: QuestionDifficulty.easy,
        isAnswered: true,
        answeredAt: DateTime.now().subtract(const Duration(minutes: 3)),
        timeTakenSeconds: 30,
        hintUsed: true,
      ),
    ];

    final weakAreas = [
      WeakArea(
        topic: 'Database Concepts',
        scorePercentage: 20,
        questionsCount: 1,
        specificIssues: ['Unable to define normalization', 'No knowledge of normal forms'],
        recommendation: 'Study database normalization chapters and practice with examples.',
        isCritical: true,
      ),
      WeakArea(
        topic: 'Technical Communication',
        scorePercentage: 60,
        questionsCount: 1,
        specificIssues: ['Answer lacks technical depth'],
        recommendation: 'Practice explaining technical concepts with more detail.',
        isCritical: false,
      ),
    ];

    final strongAreas = [
      StrongArea(
        topic: 'Basic Understanding',
        scorePercentage: 70,
        questionsCount: 1,
        strengths: ['Aware of cross-platform concept'],
        encouragement: 'Build on this foundation with deeper technical knowledge.',
      ),
    ];

    final categoryPerformance = {
      QuestionCategory.technical: CategoryPerformance(
        category: QuestionCategory.technical,
        totalQuestions: 1,
        attemptedQuestions: 1,
        totalScore: 6,
        maxPossibleScore: 10,
        averageTimeSeconds: 45,
      ),
      QuestionCategory.database: CategoryPerformance(
        category: QuestionCategory.database,
        totalQuestions: 1,
        attemptedQuestions: 1,
        totalScore: 2,
        maxPossibleScore: 10,
        averageTimeSeconds: 30,
      ),
    };

    return VivaReport(
      id: 'report_001',
      sessionId: 'session_001',
      generatedAt: DateTime.now(),
      sessionDate: DateTime.now(),
      examinerMode: 'Strict',
      totalQuestions: 2,
      attemptedQuestions: 2,
      durationMinutes: 10,
      hintsUsed: 1,
      overallScore: 8,
      maxPossibleScore: 20,
      technicalScore: 65,
      communicationScore: 55,
      confidenceScore: 45,
      questionReports: questionReports,
      weakAreas: weakAreas,
      strongAreas: strongAreas,
      categoryPerformance: categoryPerformance,
      recommendations: [
        'Review database normalization concepts thoroughly',
        'Practice explaining technical answers with more depth',
        'Use the hint feature when stuck instead of saying "I don\'t know"',
        'Watch video tutorials on Flutter architecture',
      ],
      studyResources: [
        'Database Normalization Guide - W3Schools',
        'Flutter Performance Best Practices - Official Docs',
        'Viva Preparation Tips - YouTube Playlist',
      ],
      sessionNumber: 3,
      improvementSinceLastSession: 5,
      isPersonalBest: false,
    );
  }
}