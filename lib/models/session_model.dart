import 'package:flutter/material.dart';
import 'question_model.dart';

// ============================================================
// SESSION STATUS ENUM
// ============================================================

enum SessionStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  abandoned,
}

extension SessionStatusExtension on SessionStatus {
  String get displayName {
    switch (this) {
      case SessionStatus.notStarted:
        return 'Not Started';
      case SessionStatus.inProgress:
        return 'In Progress';
      case SessionStatus.paused:
        return 'Paused';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.abandoned:
        return 'Abandoned';
    }
  }

  Color get color {
    switch (this) {
      case SessionStatus.notStarted:
        return Colors.grey;
      case SessionStatus.inProgress:
        return const Color(0xFF2A5CFF);
      case SessionStatus.paused:
        return const Color(0xFFFFB800);
      case SessionStatus.completed:
        return const Color(0xFF4CAF50);
      case SessionStatus.abandoned:
        return const Color(0xFFFF3B5C);
    }
  }

  IconData get icon {
    switch (this) {
      case SessionStatus.notStarted:
        return Icons.fiber_new;
      case SessionStatus.inProgress:
        return Icons.play_circle;
      case SessionStatus.paused:
        return Icons.pause_circle;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.abandoned:
        return Icons.cancel;
    }
  }
}

// ============================================================
// EXAMINER MODE ENUM
// ============================================================

enum ExaminerMode {
  friendly,
  strict,
  technicalExpert,
  mixed,
}

extension ExaminerModeExtension on ExaminerMode {
  String get displayName {
    switch (this) {
      case ExaminerMode.friendly:
        return 'Friendly';
      case ExaminerMode.strict:
        return 'Strict';
      case ExaminerMode.technicalExpert:
        return 'Technical Expert';
      case ExaminerMode.mixed:
        return 'Mixed';
    }
  }

  String get description {
    switch (this) {
      case ExaminerMode.friendly:
        return 'Helpful hints, encouraging tone, lower pressure';
      case ExaminerMode.strict:
        return 'No hints, rapid follow-ups, real pressure';
      case ExaminerMode.technicalExpert:
        return 'Deep questions, code and algorithms, industry level';
      case ExaminerMode.mixed:
        return 'Random combination of all styles';
    }
  }

  Color get color {
    switch (this) {
      case ExaminerMode.friendly:
        return const Color(0xFF4CAF50);
      case ExaminerMode.strict:
        return const Color(0xFFFF3B5C);
      case ExaminerMode.technicalExpert:
        return const Color(0xFF7000FF);
      case ExaminerMode.mixed:
        return const Color(0xFF2A5CFF);
    }
  }

  IconData get icon {
    switch (this) {
      case ExaminerMode.friendly:
        return Icons.emoji_emotions;
      case ExaminerMode.strict:
        return Icons.gavel;
      case ExaminerMode.technicalExpert:
        return Icons.science;
      case ExaminerMode.mixed:
        return Icons.shuffle;
    }
  }

  String get difficultyBadge {
    switch (this) {
      case ExaminerMode.friendly:
        return 'Easy';
      case ExaminerMode.strict:
        return 'Hard';
      case ExaminerMode.technicalExpert:
        return 'Expert';
      case ExaminerMode.mixed:
        return 'Medium';
    }
  }
}

// ============================================================
// QUESTION ANSWER RECORD
// ============================================================

class QuestionAnswerRecord {
  final String questionId;
  final Question question;
  final String userAnswer;
  final int score;
  final String feedback;
  final DateTime answeredAt;

  QuestionAnswerRecord({
    required this.questionId,
    required this.question,
    required this.userAnswer,
    required this.score,
    required this.feedback,
    required this.answeredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'question': question.toJson(),
      'userAnswer': userAnswer,
      'score': score,
      'feedback': feedback,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory QuestionAnswerRecord.fromJson(Map<String, dynamic> json) {
    return QuestionAnswerRecord(
      questionId: json['questionId'],
      question: Question.fromJson(json['question']),
      userAnswer: json['userAnswer'],
      score: json['score'],
      feedback: json['feedback'],
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }
}

// ============================================================
// MAIN SESSION MODEL
// ============================================================

class VivaSession {
  // Basic Information
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  DateTime? lastPausedAt;
  SessionStatus status;
  ExaminerMode examinerMode;

  // Session Configuration
  final int totalQuestionsTarget;
  final int durationMinutes;
  final int maxHintsAllowed;
  final bool allowRetries;
  final String? fypDocumentPath;
  final Map<String, dynamic>? fypMetadata;

  // Questions
  final List<Question> questions;
  int currentQuestionIndex;

  // Session Statistics
  int hintsUsed;
  int retriesUsed;
  int totalPauseCount;
  int totalDurationSeconds;

  // Timing
  DateTime? currentQuestionStartTime;
  List<Duration> questionTimeSpent;

  // Performance (live)
  int currentScore;
  int maxPossibleScore;

  // User Progress
  final Map<String, dynamic> userResponses;
  final List<String> askedQuestionIds;

  // Question Answers Record List
  final List<QuestionAnswerRecord> _questionAnswersInternal;

  // Getter for questionAnswers
  List<QuestionAnswerRecord> get questionAnswers => List.unmodifiable(_questionAnswersInternal);

  // Session Metadata
  final String? deviceInfo;
  final String? appVersion;

  VivaSession({
    required this.id,
    required this.startTime,
    this.endTime,
    this.lastPausedAt,
    this.status = SessionStatus.notStarted,
    required this.examinerMode,
    required this.totalQuestionsTarget,
    required this.durationMinutes,
    this.maxHintsAllowed = 3,
    this.allowRetries = true,
    this.fypDocumentPath,
    this.fypMetadata,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.hintsUsed = 0,
    this.retriesUsed = 0,
    this.totalPauseCount = 0,
    this.totalDurationSeconds = 0,
    this.currentQuestionStartTime,
    List<Duration>? questionTimeSpent,
    this.currentScore = 0,
    this.maxPossibleScore = 0,
    this.userResponses = const {},
    this.askedQuestionIds = const [],
    List<QuestionAnswerRecord>? questionAnswers,
    this.deviceInfo,
    this.appVersion,
  }) : _questionAnswersInternal = questionAnswers ?? [],
        questionTimeSpent = questionTimeSpent ?? [];

  // ============================================================
  // COMPUTED PROPERTIES (GETTERS)
  // ============================================================

  bool get isActive => status == SessionStatus.inProgress;

  bool get isPaused => status == SessionStatus.paused;

  bool get isCompleted => status == SessionStatus.completed;

  bool get hasQuestions => questions.isNotEmpty;

  bool get hasMoreQuestions => currentQuestionIndex < questions.length;

  bool get isLastQuestion => currentQuestionIndex == questions.length - 1;

  Question get currentQuestion => questions[currentQuestionIndex];

  int get answeredQuestionsCount => _questionAnswersInternal.length;

  int get remainingQuestions => totalQuestionsTarget - answeredQuestionsCount;

  double get completionPercentage =>
      totalQuestionsTarget > 0 ? (answeredQuestionsCount / totalQuestionsTarget) * 100 : 0.0;

  double get scorePercentage =>
      maxPossibleScore > 0 ? (currentScore / maxPossibleScore) * 100 : 0.0;

  int get sessionDurationMinutes {
    if (endTime != null) {
      return endTime!.difference(startTime).inMinutes;
    }
    return DateTime.now().difference(startTime).inMinutes;
  }

  String get formattedDuration {
    final duration = endTime != null
        ? endTime!.difference(startTime)
        : DateTime.now().difference(startTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedRemainingTime {
    final elapsedMinutes = sessionDurationMinutes;
    final remaining = durationMinutes - elapsedMinutes;
    if (remaining <= 0) return '0:00';
    final minutes = remaining;
    final seconds = 0;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get isTimeAlmostUp => (durationMinutes - sessionDurationMinutes) <= 2;

  bool get isTimeUp => sessionDurationMinutes >= durationMinutes;

  bool get hasHintsRemaining => hintsUsed < maxHintsAllowed;

  int get remainingHints => maxHintsAllowed - hintsUsed;

  List<Question> get answeredQuestions =>
      questions.where((q) => q.isAnswered).toList();

  List<Question> get unansweredQuestions =>
      questions.where((q) => !q.isAnswered).toList();

  List<Question> get correctQuestions =>
      questions.where((q) => q.isAnsweredCorrectly).toList();

  List<Question> get perfectQuestions =>
      questions.where((q) => q.isAnsweredPerfectly).toList();

  List<Question> get failedQuestions =>
      questions.where((q) => q.isFailed).toList();

  double get averageScorePerQuestion =>
      answeredQuestionsCount > 0 ? currentScore / answeredQuestionsCount : 0.0;

  double get averageTimePerQuestion {
    if (questionTimeSpent.isEmpty) return 0.0;
    final totalSeconds = questionTimeSpent.fold<Duration>(
        Duration.zero, (sum, duration) => sum + duration);
    return totalSeconds.inSeconds / questionTimeSpent.length;
  }

  Map<QuestionCategory, CategorySessionStats> get categoryStats {
    final stats = <QuestionCategory, CategorySessionStats>{};

    for (final question in questions) {
      final cat = question.category;
      if (!stats.containsKey(cat)) {
        stats[cat] = CategorySessionStats(category: cat);
      }
      stats[cat]!.totalQuestions++;
      if (question.isAnswered) {
        stats[cat]!.attemptedQuestions++;
        stats[cat]!.totalScore += question.userScore ?? 0;
        stats[cat]!.maxPossibleScore += question.maxScore;
      }
    }
    return stats;
  }

  String get formattedDate {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  // ============================================================
  // METHODS
  // ============================================================

  void startSession() {
    status = SessionStatus.inProgress;
    maxPossibleScore = questions.fold<int>(0, (sum, q) => sum + q.maxScore);
  }

  void pauseSession() {
    if (status == SessionStatus.inProgress) {
      status = SessionStatus.paused;
      lastPausedAt = DateTime.now();
      totalPauseCount++;
    }
  }

  void resumeSession() {
    if (status == SessionStatus.paused && lastPausedAt != null) {
      status = SessionStatus.inProgress;
      lastPausedAt = null;
    }
  }

  void completeSession() {
    status = SessionStatus.completed;
    endTime = DateTime.now();
  }

  void abandonSession() {
    status = SessionStatus.abandoned;
    endTime = DateTime.now();
  }

  void moveToNextQuestion() {
    if (hasMoreQuestions) {
      currentQuestionIndex++;
      currentQuestionStartTime = DateTime.now();
    }
  }

  void recordAnswer(String questionId, String answer, int score, String feedback) {
    final questionIndex = questions.indexWhere((q) => q.id == questionId);
    if (questionIndex != -1) {
      final question = questions[questionIndex];

      // Check if already answered
      final existingIndex = _questionAnswersInternal.indexWhere((qa) => qa.questionId == questionId);

      if (existingIndex != -1) {
        // Update existing answer
        final updatedRecord = QuestionAnswerRecord(
          questionId: questionId,
          question: question,
          userAnswer: answer,
          score: score,
          feedback: feedback,
          answeredAt: DateTime.now(),
        );
        _questionAnswersInternal[existingIndex] = updatedRecord;
      } else {
        // Add new answer
        _questionAnswersInternal.add(QuestionAnswerRecord(
          questionId: questionId,
          question: question,
          userAnswer: answer,
          score: score,
          feedback: feedback,
          answeredAt: DateTime.now(),
        ));
      }

      final updatedQuestion = question.copyWith(
        userAnswer: answer,
        userScore: score,
        userFeedback: feedback,
        isAnswered: true,
        answeredAt: DateTime.now(),
      );
      questions[questionIndex] = updatedQuestion;

      currentScore += score;
      if (!maxPossibleScoreCalculated) {
        maxPossibleScore += question.maxScore;
      }

      if (currentQuestionStartTime != null) {
        final timeSpent = DateTime.now().difference(currentQuestionStartTime!);
        questionTimeSpent.add(timeSpent);
      }
    }
  }

  bool get maxPossibleScoreCalculated => maxPossibleScore > 0;

  void useHint() {
    if (hasHintsRemaining) {
      hintsUsed++;
    }
  }

  void recordRetry() {
    if (allowRetries) {
      retriesUsed++;
    }
  }

  VivaSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? lastPausedAt,
    SessionStatus? status,
    ExaminerMode? examinerMode,
    int? totalQuestionsTarget,
    int? durationMinutes,
    int? maxHintsAllowed,
    bool? allowRetries,
    String? fypDocumentPath,
    Map<String, dynamic>? fypMetadata,
    List<Question>? questions,
    int? currentQuestionIndex,
    int? hintsUsed,
    int? retriesUsed,
    int? totalPauseCount,
    int? totalDurationSeconds,
    DateTime? currentQuestionStartTime,
    List<Duration>? questionTimeSpent,
    int? currentScore,
    int? maxPossibleScore,
    Map<String, dynamic>? userResponses,
    List<String>? askedQuestionIds,
    List<QuestionAnswerRecord>? questionAnswers,
    String? deviceInfo,
    String? appVersion,
  }) {
    return VivaSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      lastPausedAt: lastPausedAt ?? this.lastPausedAt,
      status: status ?? this.status,
      examinerMode: examinerMode ?? this.examinerMode,
      totalQuestionsTarget: totalQuestionsTarget ?? this.totalQuestionsTarget,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      maxHintsAllowed: maxHintsAllowed ?? this.maxHintsAllowed,
      allowRetries: allowRetries ?? this.allowRetries,
      fypDocumentPath: fypDocumentPath ?? this.fypDocumentPath,
      fypMetadata: fypMetadata ?? this.fypMetadata,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      retriesUsed: retriesUsed ?? this.retriesUsed,
      totalPauseCount: totalPauseCount ?? this.totalPauseCount,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
      currentQuestionStartTime: currentQuestionStartTime ?? this.currentQuestionStartTime,
      questionTimeSpent: questionTimeSpent ?? this.questionTimeSpent,
      currentScore: currentScore ?? this.currentScore,
      maxPossibleScore: maxPossibleScore ?? this.maxPossibleScore,
      userResponses: userResponses ?? this.userResponses,
      askedQuestionIds: askedQuestionIds ?? this.askedQuestionIds,
      questionAnswers: questionAnswers ?? _questionAnswersInternal,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'lastPausedAt': lastPausedAt?.toIso8601String(),
      'status': status.name,
      'examinerMode': examinerMode.name,
      'totalQuestionsTarget': totalQuestionsTarget,
      'durationMinutes': durationMinutes,
      'maxHintsAllowed': maxHintsAllowed,
      'allowRetries': allowRetries,
      'fypDocumentPath': fypDocumentPath,
      'fypMetadata': fypMetadata,
      'questions': questions.map((q) => q.toJson()).toList(),
      'currentQuestionIndex': currentQuestionIndex,
      'hintsUsed': hintsUsed,
      'retriesUsed': retriesUsed,
      'totalPauseCount': totalPauseCount,
      'totalDurationSeconds': totalDurationSeconds,
      'currentQuestionStartTime': currentQuestionStartTime?.toIso8601String(),
      'questionTimeSpent': questionTimeSpent.map((d) => d.inSeconds).toList(),
      'currentScore': currentScore,
      'maxPossibleScore': maxPossibleScore,
      'userResponses': userResponses,
      'askedQuestionIds': askedQuestionIds,
      'questionAnswers': _questionAnswersInternal.map((qa) => qa.toJson()).toList(),
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
    };
  }

  factory VivaSession.fromJson(Map<String, dynamic> json) {
    return VivaSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      lastPausedAt: json['lastPausedAt'] != null ? DateTime.parse(json['lastPausedAt']) : null,
      status: SessionStatus.values.firstWhere(
            (e) => e.name == json['status'],
        orElse: () => SessionStatus.notStarted,
      ),
      examinerMode: ExaminerMode.values.firstWhere(
            (e) => e.name == json['examinerMode'],
        orElse: () => ExaminerMode.mixed,
      ),
      totalQuestionsTarget: json['totalQuestionsTarget'],
      durationMinutes: json['durationMinutes'],
      maxHintsAllowed: json['maxHintsAllowed'] ?? 3,
      allowRetries: json['allowRetries'] ?? true,
      fypDocumentPath: json['fypDocumentPath'],
      fypMetadata: json['fypMetadata'],
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      currentQuestionIndex: json['currentQuestionIndex'] ?? 0,
      hintsUsed: json['hintsUsed'] ?? 0,
      retriesUsed: json['retriesUsed'] ?? 0,
      totalPauseCount: json['totalPauseCount'] ?? 0,
      totalDurationSeconds: json['totalDurationSeconds'] ?? 0,
      currentQuestionStartTime: json['currentQuestionStartTime'] != null
          ? DateTime.parse(json['currentQuestionStartTime'])
          : null,
      questionTimeSpent: (json['questionTimeSpent'] as List?)
          ?.map((d) => Duration(seconds: d))
          .toList() ??
          [],
      currentScore: json['currentScore'] ?? 0,
      maxPossibleScore: json['maxPossibleScore'] ?? 0,
      userResponses: json['userResponses'] ?? {},
      askedQuestionIds: List<String>.from(json['askedQuestionIds'] ?? []),
      questionAnswers: (json['questionAnswers'] as List?)
          ?.map((qa) => QuestionAnswerRecord.fromJson(qa))
          .toList() ??
          [],
      deviceInfo: json['deviceInfo'],
      appVersion: json['appVersion'],
    );
  }

  String getFormattedStartTime() {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  String getFormattedDate() {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  String getSessionSummary() {
    return '''
Session ID: $id
Date: ${getFormattedDate()}
Mode: ${examinerMode.displayName}
Status: ${status.displayName}
Questions: $answeredQuestionsCount / $totalQuestionsTarget
Score: $currentScore / $maxPossibleScore (${scorePercentage.toStringAsFixed(1)}%)
Duration: $formattedDuration
Hints Used: $hintsUsed / $maxHintsAllowed
''';
  }
}

// ============================================================
// CATEGORY SESSION STATS
// ============================================================

class CategorySessionStats {
  final QuestionCategory category;
  int totalQuestions;
  int attemptedQuestions;
  int totalScore;
  int maxPossibleScore;

  CategorySessionStats({
    required this.category,
    this.totalQuestions = 0,
    this.attemptedQuestions = 0,
    this.totalScore = 0,
    this.maxPossibleScore = 0,
  });

  double get scorePercentage =>
      maxPossibleScore > 0 ? (totalScore / maxPossibleScore) * 100 : 0.0;

  double get completionRate =>
      totalQuestions > 0 ? (attemptedQuestions / totalQuestions) * 100 : 0.0;
}

// ============================================================
// SESSION HISTORY
// ============================================================

class SessionHistory {
  final List<VivaSession> sessions;
  final DateTime lastUpdated;

  SessionHistory({
    required this.sessions,
    required this.lastUpdated,
  });

  int get totalSessions => sessions.length;

  int get completedSessions =>
      sessions.where((s) => s.status == SessionStatus.completed).length;

  double get averageScore {
    final completed = sessions.where((s) => s.status == SessionStatus.completed);
    if (completed.isEmpty) return 0.0;
    final total = completed.fold<double>(
        0.0, (sum, s) => sum + s.scorePercentage);
    return total / completed.length;
  }

  int get totalPracticeTimeMinutes {
    return sessions.fold<int>(0, (sum, s) => sum + s.sessionDurationMinutes);
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final hasSessionOnDate = sessions.any((s) =>
      s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day);
      if (hasSessionOnDate) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  List<VivaSession> getRecentSessions({int limit = 5}) {
    final sorted = List<VivaSession>.from(sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(limit).toList();
  }

  Map<ExaminerMode, int> getModeDistribution() {
    final distribution = <ExaminerMode, int>{};
    for (final mode in ExaminerMode.values) {
      distribution[mode] = sessions.where((s) => s.examinerMode == mode).length;
    }
    return distribution;
  }

  Map<QuestionCategory, double> getCategoryPerformanceOverTime() {
    final performance = <QuestionCategory, double>{};
    final completed = sessions.where((s) => s.status == SessionStatus.completed);

    for (final category in QuestionCategory.values) {
      double totalPercentage = 0.0;
      int count = 0;

      for (final session in completed) {
        final stats = session.categoryStats[category];
        if (stats != null && stats.maxPossibleScore > 0) {
          totalPercentage += stats.scorePercentage;
          count++;
        }
      }

      if (count > 0) {
        performance[category] = totalPercentage / count;
      }
    }

    return performance;
  }

  Map<String, dynamic> toJson() {
    return {
      'sessions': sessions.map((s) => s.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory SessionHistory.fromJson(Map<String, dynamic> json) {
    return SessionHistory(
      sessions: (json['sessions'] as List)
          .map((s) => VivaSession.fromJson(s))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  factory SessionHistory.empty() {
    return SessionHistory(
      sessions: [],
      lastUpdated: DateTime.now(),
    );
  }
}

// ============================================================
// SAMPLE SESSION (for testing/demo)
// ============================================================

class SampleSessionGenerator {
  static VivaSession getSampleSession() {
    final questions = QuestionBank.getSampleQuestions();

    return VivaSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      startTime: DateTime.now(),
      status: SessionStatus.inProgress,
      examinerMode: ExaminerMode.strict,
      totalQuestionsTarget: questions.length,
      durationMinutes: 10,
      maxHintsAllowed: 3,
      allowRetries: true,
      questions: questions,
      currentQuestionIndex: 0,
      hintsUsed: 0,
      retriesUsed: 0,
      totalPauseCount: 0,
      totalDurationSeconds: 0,
      currentQuestionStartTime: DateTime.now(),
      currentScore: 0,
      maxPossibleScore: questions.fold<int>(0, (sum, q) => sum + q.maxScore),
    );
  }

  static VivaSession getCompletedSampleSession() {
    final session = getSampleSession();
    session.startSession();

    for (int i = 0; i < session.questions.length; i++) {
      final question = session.questions[i];
      final score = i == 0 ? 8 : (i == 1 ? 5 : 7);
      session.recordAnswer(
        question.id,
        'Sample answer for ${question.text}',
        score,
        'Good attempt but could be improved.',
      );
      if (i < session.questions.length - 1) {
        session.moveToNextQuestion();
      }
    }

    session.completeSession();
    return session;
  }
}