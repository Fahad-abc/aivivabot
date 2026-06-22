import 'package:flutter/material.dart';

// ============================================================
// MAIN QUESTION MODEL
// ============================================================

class Question {
  // Basic Information
  final String id;
  final String text;
  final String? idealAnswer;
  final QuestionCategory category;
  final QuestionDifficulty difficulty;
  final QuestionType type;

  // Metadata
  final List<String> keywords;
  final List<String> followUpQuestions;
  final List<String> hints;
  final List<String> commonMistakes;

  // Scoring
  final int maxScore;
  final double weightage;

  // Status
  final DateTime createdAt;
  bool isAnswered;
  bool isBookmarked;

  // User Response (filled during session)
  String? userAnswer;
  int? userScore;
  String? userFeedback;
  DateTime? answeredAt;

  // Optional: For custom questions from FYP document
  final String? sourceDocument;
  final Map<String, dynamic>? customMetadata;

  Question({
    required this.id,
    required this.text,
    this.idealAnswer,
    required this.category,
    required this.difficulty,
    required this.type,
    this.keywords = const [],
    this.followUpQuestions = const [],
    this.hints = const [],
    this.commonMistakes = const [],
    this.maxScore = 10,
    this.weightage = 1.0,
    DateTime? createdAt,
    this.isAnswered = false,
    this.isBookmarked = false,
    this.userAnswer,
    this.userScore,
    this.userFeedback,
    this.answeredAt,
    this.sourceDocument,
    this.customMetadata,
  }) : createdAt = createdAt ?? DateTime.now();

  // ============================================================
  // COMPUTED PROPERTIES
  // ============================================================

  bool get isAnsweredCorrectly => userScore != null && userScore! >= (maxScore * 0.6);

  bool get isAnsweredPerfectly => userScore != null && userScore! >= (maxScore * 0.9);

  bool get isFailed => userScore != null && userScore! < (maxScore * 0.4);

  double get scorePercentage => userScore != null ? (userScore! / maxScore) * 100 : 0;

  String get scoreStatus {
    if (!isAnswered) return 'Not Attempted';
    if (isAnsweredPerfectly) return 'Excellent';
    if (isAnsweredCorrectly) return 'Good';
    if (isFailed) return 'Needs Improvement';
    return 'Average';
  }

  Color get scoreStatusColor {
    if (!isAnswered) return Colors.grey;
    if (isAnsweredPerfectly) return Colors.green;
    if (isAnsweredCorrectly) return const Color(0xFF2A5CFF);
    if (isFailed) return const Color(0xFFFF3B5C);
    return const Color(0xFFFFB800);
  }

  IconData get scoreStatusIcon {
    if (!isAnswered) return Icons.help_outline;
    if (isAnsweredPerfectly) return Icons.star;
    if (isAnsweredCorrectly) return Icons.check_circle;
    if (isFailed) return Icons.error_outline;
    return Icons.trending_up;
  }

  // ============================================================
  // METHODS
  // ============================================================

  Question copyWith({
    String? id,
    String? text,
    String? idealAnswer,
    QuestionCategory? category,
    QuestionDifficulty? difficulty,
    QuestionType? type,
    List<String>? keywords,
    List<String>? followUpQuestions,
    List<String>? hints,
    List<String>? commonMistakes,
    int? maxScore,
    double? weightage,
    DateTime? createdAt,
    bool? isAnswered,
    bool? isBookmarked,
    String? userAnswer,
    int? userScore,
    String? userFeedback,
    DateTime? answeredAt,
    String? sourceDocument,
    Map<String, dynamic>? customMetadata,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      idealAnswer: idealAnswer ?? this.idealAnswer,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      type: type ?? this.type,
      keywords: keywords ?? this.keywords,
      followUpQuestions: followUpQuestions ?? this.followUpQuestions,
      hints: hints ?? this.hints,
      commonMistakes: commonMistakes ?? this.commonMistakes,
      maxScore: maxScore ?? this.maxScore,
      weightage: weightage ?? this.weightage,
      createdAt: createdAt ?? this.createdAt,
      isAnswered: isAnswered ?? this.isAnswered,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      userAnswer: userAnswer ?? this.userAnswer,
      userScore: userScore ?? this.userScore,
      userFeedback: userFeedback ?? this.userFeedback,
      answeredAt: answeredAt ?? this.answeredAt,
      sourceDocument: sourceDocument ?? this.sourceDocument,
      customMetadata: customMetadata ?? this.customMetadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'idealAnswer': idealAnswer,
      'category': category.name,
      'difficulty': difficulty.name,
      'type': type.name,
      'keywords': keywords,
      'followUpQuestions': followUpQuestions,
      'hints': hints,
      'commonMistakes': commonMistakes,
      'maxScore': maxScore,
      'weightage': weightage,
      'createdAt': createdAt.toIso8601String(),
      'isAnswered': isAnswered,
      'isBookmarked': isBookmarked,
      'userAnswer': userAnswer,
      'userScore': userScore,
      'userFeedback': userFeedback,
      'answeredAt': answeredAt?.toIso8601String(),
      'sourceDocument': sourceDocument,
      'customMetadata': customMetadata,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      idealAnswer: json['idealAnswer'],
      category: QuestionCategoryExtension.fromString(json['category']),
      difficulty: QuestionDifficultyExtension.fromString(json['difficulty']),
      type: QuestionTypeExtension.fromString(json['type']),
      keywords: List<String>.from(json['keywords'] ?? []),
      followUpQuestions: List<String>.from(json['followUpQuestions'] ?? []),
      hints: List<String>.from(json['hints'] ?? []),
      commonMistakes: List<String>.from(json['commonMistakes'] ?? []),
      maxScore: json['maxScore'] ?? 10,
      weightage: json['weightage']?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(json['createdAt']),
      isAnswered: json['isAnswered'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      userAnswer: json['userAnswer'],
      userScore: json['userScore'],
      userFeedback: json['userFeedback'],
      answeredAt: json['answeredAt'] != null ? DateTime.parse(json['answeredAt']) : null,
      sourceDocument: json['sourceDocument'],
      customMetadata: json['customMetadata'],
    );
  }

  String getFormattedAnswerForDisplay() {
    if (userAnswer == null || userAnswer!.isEmpty) {
      return 'No answer provided';
    }
    return userAnswer!;
  }

  String getScoreComment() {
    if (!isAnswered) return 'Answer this question to get feedback';
    if (isAnsweredPerfectly) return 'Perfect! You nailed this.';
    if (isAnsweredCorrectly) return 'Good answer! Small improvements possible.';
    if (isFailed) return 'Review the ideal answer and try again.';
    return 'Decent attempt. Check the ideal answer for details.';
  }
}

// ============================================================
// ENUMERATIONS
// ============================================================

enum QuestionCategory {
  technical,
  conceptual,
  implementation,
  architecture,
  database,
  api,
  frontend,
  backend,
  security,
  testing,
  deployment,
  general,
}

enum QuestionDifficulty {
  easy,
  medium,
  hard,
  expert,
}

enum QuestionType {
  openEnded,
  multipleChoice,
  trueFalse,
  fillBlank,
  codeBased,
  scenarioBased,
}

// ============================================================
// ENUM EXTENSIONS
// ============================================================

extension QuestionCategoryExtension on QuestionCategory {
  String get displayName {
    switch (this) {
      case QuestionCategory.technical:
        return 'Technical';
      case QuestionCategory.conceptual:
        return 'Conceptual';
      case QuestionCategory.implementation:
        return 'Implementation';
      case QuestionCategory.architecture:
        return 'Architecture';
      case QuestionCategory.database:
        return 'Database';
      case QuestionCategory.api:
        return 'API';
      case QuestionCategory.frontend:
        return 'Frontend';
      case QuestionCategory.backend:
        return 'Backend';
      case QuestionCategory.security:
        return 'Security';
      case QuestionCategory.testing:
        return 'Testing';
      case QuestionCategory.deployment:
        return 'Deployment';
      case QuestionCategory.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionCategory.technical:
        return Icons.computer;
      case QuestionCategory.conceptual:
        return Icons.lightbulb;
      case QuestionCategory.implementation:
        return Icons.code;
      case QuestionCategory.architecture:
        return Icons.account_tree;
      case QuestionCategory.database:
        return Icons.storage;
      case QuestionCategory.api:
        return Icons.api;
      case QuestionCategory.frontend:
        return Icons.web;
      case QuestionCategory.backend:
        return Icons.settings;
      case QuestionCategory.security:
        return Icons.security;
      case QuestionCategory.testing:
        return Icons.bug_report;
      case QuestionCategory.deployment:
        return Icons.cloud_upload;
      case QuestionCategory.general:
        return Icons.help;
    }
  }

  Color get color {
    switch (this) {
      case QuestionCategory.technical:
        return const Color(0xFF2A5CFF);
      case QuestionCategory.conceptual:
        return const Color(0xFF7000FF);
      case QuestionCategory.implementation:
        return const Color(0xFF00E096);
      case QuestionCategory.architecture:
        return const Color(0xFFFFB800);
      case QuestionCategory.database:
        return const Color(0xFFFF3B5C);
      case QuestionCategory.api:
        return const Color(0xFF00BCD4);
      case QuestionCategory.frontend:
        return const Color(0xFFFF9800);
      case QuestionCategory.backend:
        return const Color(0xFF9C27B0);
      case QuestionCategory.security:
        return const Color(0xFFF44336);
      case QuestionCategory.testing:
        return const Color(0xFF4CAF50);
      case QuestionCategory.deployment:
        return const Color(0xFF607D8B);
      case QuestionCategory.general:
        return const Color(0xFF9E9E9E);
    }
  }

  static QuestionCategory fromString(String value) {
    return QuestionCategory.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => QuestionCategory.general,
    );
  }
}

extension QuestionDifficultyExtension on QuestionDifficulty {
  String get displayName {
    switch (this) {
      case QuestionDifficulty.easy:
        return 'Easy';
      case QuestionDifficulty.medium:
        return 'Medium';
      case QuestionDifficulty.hard:
        return 'Hard';
      case QuestionDifficulty.expert:
        return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case QuestionDifficulty.easy:
        return const Color(0xFF4CAF50);
      case QuestionDifficulty.medium:
        return const Color(0xFFFFB800);
      case QuestionDifficulty.hard:
        return const Color(0xFFFF3B5C);
      case QuestionDifficulty.expert:
        return const Color(0xFF7000FF);
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionDifficulty.easy:
        return Icons.sentiment_satisfied;
      case QuestionDifficulty.medium:
        return Icons.trending_up;
      case QuestionDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
      case QuestionDifficulty.expert:
        return Icons.psychology;
    }
  }

  int get points {
    switch (this) {
      case QuestionDifficulty.easy:
        return 10;
      case QuestionDifficulty.medium:
        return 20;
      case QuestionDifficulty.hard:
        return 30;
      case QuestionDifficulty.expert:
        return 50;
    }
  }

  static QuestionDifficulty fromString(String value) {
    return QuestionDifficulty.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => QuestionDifficulty.medium,
    );
  }
}

extension QuestionTypeExtension on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.openEnded:
        return 'Open Ended';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalse:
        return 'True/False';
      case QuestionType.fillBlank:
        return 'Fill in Blank';
      case QuestionType.codeBased:
        return 'Code Based';
      case QuestionType.scenarioBased:
        return 'Scenario Based';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionType.openEnded:
        return Icons.chat;
      case QuestionType.multipleChoice:
        return Icons.checklist;
      case QuestionType.trueFalse:
        return Icons.thumbs_up_down;
      case QuestionType.fillBlank:
        return Icons.text_fields;
      case QuestionType.codeBased:
        return Icons.code;
      case QuestionType.scenarioBased:
        return Icons.account_tree;
    }
  }

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => QuestionType.openEnded,
    );
  }
}

// ============================================================
// SAMPLE QUESTIONS (for testing/demo)
// ============================================================

class QuestionBank {
  static List<Question> getSampleQuestions() {
    return [
      Question(
        id: 'q1',
        text: 'Why did you choose Flutter for your project?',
        idealAnswer: 'Flutter was chosen because it allows cross-platform development with a single codebase, provides near-native performance through the Skia rendering engine, and offers a rich set of customizable widgets that speed up development.',
        category: QuestionCategory.technical,
        difficulty: QuestionDifficulty.medium,
        type: QuestionType.openEnded,
        keywords: ['cross-platform', 'single codebase', 'performance', 'widgets', 'Skia'],
        followUpQuestions: [
          'What are the limitations of Flutter?',
          'How does Flutter compare to React Native?',
          'Explain the Flutter rendering pipeline.',
        ],
        hints: [
          'Think about cross-platform benefits',
          'Consider performance aspects',
          'Mention the widget system',
        ],
        commonMistakes: [
          'Saying only "it\'s easy" without technical depth',
          'Missing performance comparison with native',
        ],
        weightage: 1.5,
      ),
      Question(
        id: 'q2',
        text: 'What is database normalization?',
        idealAnswer: 'Normalization is the process of organizing database tables to reduce data redundancy and improve data integrity through normal forms like 1NF, 2NF, and 3NF.',
        category: QuestionCategory.database,
        difficulty: QuestionDifficulty.easy,
        type: QuestionType.openEnded,
        keywords: ['redundancy', 'integrity', 'normal forms', '1NF', '2NF', '3NF'],
        followUpQuestions: [
          'What is the difference between 2NF and 3NF?',
          'When would you denormalize?',
          'Explain the problems normalization solves.',
        ],
        hints: [
          'Think about duplicate data',
          'Consider data consistency',
        ],
        commonMistakes: [
          'Confusing normalization with indexing',
          'Not mentioning normal forms',
        ],
      ),
      Question(
        id: 'q3',
        text: 'How does Firebase Authentication work?',
        idealAnswer: 'Firebase Authentication provides backend services to authenticate users using email/password, phone numbers, or federated identity providers like Google, Facebook, and Apple. It handles secure token generation and session management.',
        category: QuestionCategory.api,
        difficulty: QuestionDifficulty.hard,
        type: QuestionType.openEnded,
        keywords: ['authentication', 'JWT', 'providers', 'session', 'security'],
        followUpQuestions: [
          'How do you implement email verification?',
          'What is Firebase Security Rules?',
          'How do you handle token refresh?',
        ],
        hints: [
          'Think about identity providers',
          'Consider token-based authentication',
        ],
        commonMistakes: [
          'Not mentioning token security',
          'Confusing with Firebase database',
        ],
        weightage: 2.0,
      ),
    ];
  }
}