import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../models/question_model.dart';
import '../models/session_model.dart';
import '../services/local/database_service.dart';

// ============================================================
// REPORT PROVIDER - Manages Viva Reports State
// ============================================================

class ReportProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  List<VivaReport> _reports = [];
  VivaReport? _currentReport;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGenerating = false;

  // ============================================================
  // GETTERS
  // ============================================================

  List<VivaReport> get reports => _reports;
  VivaReport? get currentReport => _currentReport;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  int get totalReports => _reports.length;

  List<VivaReport> get recentReports {
    final sorted = List<VivaReport>.from(_reports)
      ..sort((a, b) => b.sessionDate.compareTo(a.sessionDate));
    return sorted.take(5).toList();
  }

  List<VivaReport> get bestReports {
    final sorted = List<VivaReport>.from(_reports)
      ..sort((a, b) => b.overallScorePercentage.compareTo(a.overallScorePercentage));
    return sorted.take(3).toList();
  }

  double get averageOverallScore {
    if (_reports.isEmpty) return 0.0;
    final total = _reports.fold<double>(0.0, (sum, r) => sum + r.overallScorePercentage);
    return total / _reports.length;
  }

  double get averageTechnicalScore {
    if (_reports.isEmpty) return 0.0;
    final total = _reports.fold<double>(0.0, (sum, r) => sum + r.technicalScorePercentage);
    return total / _reports.length;
  }

  double get averageCommunicationScore {
    if (_reports.isEmpty) return 0.0;
    final total = _reports.fold<double>(0.0, (sum, r) => sum + r.communicationScorePercentage);
    return total / _reports.length;
  }

  double get averageConfidenceScore {
    if (_reports.isEmpty) return 0.0;
    final total = _reports.fold<double>(0.0, (sum, r) => sum + r.confidenceScorePercentage);
    return total / _reports.length;
  }

  int get totalQuestionsAnswered {
    return _reports.fold<int>(0, (sum, r) => sum + r.totalQuestions);
  }

  int get totalPracticeMinutes {
    return _reports.fold<int>(0, (sum, r) => sum + r.durationMinutes);
  }

  // ============================================================
  // REPORT GENERATION
  // ============================================================

  /// Generate report from completed session
  Future<VivaReport?> generateReportFromSession(VivaSession session) async {
    _setGenerating(true);
    _clearError();

    try {
      final report = await _createReportFromSession(session);
      if (report != null) {
        await saveReport(report);
        _currentReport = report;
        _setGenerating(false);
        notifyListeners();
        return report;
      }
      _setError('Failed to generate report');
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Create report from session data
  Future<VivaReport?> _createReportFromSession(VivaSession session) async {
    // Create question reports
    final questionReports = <QuestionReport>[];

    for (final question in session.questions) {
      if (question.isAnswered) {
        final questionReport = QuestionReport(
          questionId: question.id,
          questionText: question.text,
          userAnswer: question.userAnswer ?? '',
          idealAnswer: question.idealAnswer ?? '',
          score: question.userScore ?? 0,
          maxScore: question.maxScore,
          feedback: question.userFeedback ?? '',
          missingPoints: _extractMissingPoints(question),
          strongPoints: _extractStrongPoints(question),
          category: question.category,
          difficulty: question.difficulty,
          isAnswered: true,
          answeredAt: question.answeredAt ?? DateTime.now(),
          timeTakenSeconds: 30, // Calculate from actual time
          hintUsed: false,
        );
        questionReports.add(questionReport);
      }
    }

    // Calculate category performance
    final categoryPerformance = _calculateCategoryPerformance(questionReports);

    // Identify weak areas
    final weakAreas = _identifyWeakAreas(questionReports, categoryPerformance);

    // Identify strong areas
    final strongAreas = _identifyStrongAreas(questionReports, categoryPerformance);

    // Generate recommendations
    final recommendations = _generateRecommendations(weakAreas);

    // Generate study resources
    final studyResources = _generateStudyResources(weakAreas);

    // Calculate scores
    final totalScore = questionReports.fold<int>(0, (sum, q) => sum + q.score);
    final maxScore = questionReports.fold<int>(0, (sum, q) => sum + q.maxScore);
    final overallScore = maxScore > 0 ? (totalScore / maxScore) * 100.0 : 0.0;

    final report = VivaReport(
      id: 'report_${DateTime.now().millisecondsSinceEpoch}',
      sessionId: session.id,
      generatedAt: DateTime.now(),
      sessionDate: session.startTime,
      examinerMode: session.examinerMode.displayName,
      totalQuestions: session.totalQuestionsTarget,
      attemptedQuestions: session.answeredQuestionsCount,
      durationMinutes: session.sessionDurationMinutes,
      hintsUsed: session.hintsUsed,
      overallScore: totalScore,
      maxPossibleScore: maxScore,
      technicalScore: (overallScore * 0.7).toInt(),
      communicationScore: (overallScore * 0.6).toInt(),
      confidenceScore: (overallScore * 0.5).toInt(),
      questionReports: questionReports,
      weakAreas: weakAreas,
      strongAreas: strongAreas,
      categoryPerformance: categoryPerformance,
      recommendations: recommendations,
      studyResources: studyResources,
      sessionNumber: _reports.length + 1,
      improvementSinceLastSession: _calculateImprovement(overallScore),
      isPersonalBest: _isNewPersonalBest(overallScore),
    );

    return report;
  }

  // ============================================================
  // REPORT CRUD OPERATIONS
  // ============================================================

  /// Save report to database
  Future<void> saveReport(VivaReport report) async {
    try {
      await _databaseService.saveReport(report);
      _reports.add(report);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load all reports
  Future<void> loadReports() async {
    _setLoading(true);

    try {
      _reports = await _databaseService.getAllReports();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  /// Load report by ID
  Future<VivaReport?> loadReportById(String reportId) async {
    _setLoading(true);

    try {
      final report = await _databaseService.getReportById(reportId);
      if (report != null) {
        _currentReport = report;
      }
      _setLoading(false);
      notifyListeners();
      return report;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Delete report
  Future<bool> deleteReport(String reportId) async {
    _setLoading(true);

    try {
      await _databaseService.deleteReport(reportId);
      _reports.removeWhere((r) => r.id == reportId);
      if (_currentReport?.id == reportId) {
        _currentReport = null;
      }
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Delete all reports
  Future<bool> deleteAllReports() async {
    _setLoading(true);

    try {
      await _databaseService.deleteAllReports();
      _reports.clear();
      _currentReport = null;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================================
  // REPORT ANALYSIS
  // ============================================================

  /// Get reports by date range
  List<VivaReport> getReportsByDateRange(DateTime start, DateTime end) {
    return _reports.where((r) =>
    r.sessionDate.isAfter(start) && r.sessionDate.isBefore(end)
    ).toList();
  }

  /// Get reports by examiner mode
  List<VivaReport> getReportsByExaminerMode(String mode) {
    return _reports.where((r) => r.examinerMode == mode).toList();
  }

  /// Get performance trend over time
  List<double> getPerformanceTrend({int limit = 10}) {
    final sorted = List<VivaReport>.from(_reports)
      ..sort((a, b) => a.sessionDate.compareTo(b.sessionDate));
    final recent = sorted.take(limit).toList();
    return recent.map((r) => r.overallScorePercentage).toList();
  }

  /// Get category performance summary
  Map<String, double> getCategoryPerformanceSummary() {
    final summary = <String, double>{};
    final categoryScores = <String, List<double>>{};

    for (final report in _reports) {
      for (final entry in report.categoryPerformance.entries) {
        final categoryName = entry.key.displayName;
        final score = entry.value.scorePercentage;

        if (!categoryScores.containsKey(categoryName)) {
          categoryScores[categoryName] = [];
        }
        categoryScores[categoryName]!.add(score);
      }
    }

    for (final entry in categoryScores.entries) {
      final average = entry.value.reduce((a, b) => a + b) / entry.value.length;
      summary[entry.key] = average;
    }

    return summary;
  }

  /// Get weakest topics across all sessions
  List<WeakArea> getOverallWeakAreas() {
    final allWeakAreas = <WeakArea>[];
    for (final report in _reports) {
      allWeakAreas.addAll(report.weakAreas);
    }

    // Group by topic and calculate average
    final topicScores = <String, List<double>>{};
    for (final weak in allWeakAreas) {
      if (!topicScores.containsKey(weak.topic)) {
        topicScores[weak.topic] = [];
      }
      topicScores[weak.topic]!.add(weak.scorePercentage);
    }

    final weakAreasList = <WeakArea>[];
    for (final entry in topicScores.entries) {
      final averageScore = entry.value.reduce((a, b) => a + b) / entry.value.length;
      weakAreasList.add(WeakArea(
        topic: entry.key,
        scorePercentage: averageScore,
        questionsCount: entry.value.length,
        specificIssues: ['Needs improvement'],
        recommendation: 'Practice ${entry.key} concepts',
        isCritical: averageScore < 40,
      ));
    }

    weakAreasList.sort((a, b) => a.scorePercentage.compareTo(b.scorePercentage));
    return weakAreasList.take(5).toList();
  }

  // ============================================================
  // PDF EXPORT
  // ============================================================

  /// Export report as PDF
  Future<String?> exportReportAsPdf(VivaReport report) async {
    _setLoading(true);

    try {
      // TODO: Implement PDF generation
      // Use pdf and printing packages
      _setLoading(false);
      return null;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  /// Share report
  Future<bool> shareReport(VivaReport report) async {
    try {
      // TODO: Implement share functionality
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ============================================================
  // PRIVATE HELPER METHODS
  // ============================================================

  List<String> _extractMissingPoints(Question question) {
    final missing = <String>[];
    // TODO: Implement AI-based missing points extraction
    if (!(question.userAnswer?.toLowerCase().contains('performance') ?? false)) {
      missing.add('Performance considerations');
    }
    if (!(question.userAnswer?.toLowerCase().contains('architecture') ?? false)) {
      missing.add('Architecture explanation');
    }
    return missing;
  }

  List<String> _extractStrongPoints(Question question) {
    final strong = <String>[];
    if (question.userAnswer?.toLowerCase().contains('implementation') ?? false) {
      strong.add('Implementation understanding');
    }
    return strong;
  }

  Map<QuestionCategory, CategoryPerformance> _calculateCategoryPerformance(
      List<QuestionReport> questionReports,
      ) {
    final performance = <QuestionCategory, CategoryPerformance>{};

    final grouped = <QuestionCategory, List<QuestionReport>>{};
    for (final q in questionReports) {
      if (!grouped.containsKey(q.category)) {
        grouped[q.category] = [];
      }
      grouped[q.category]!.add(q);
    }

    for (final entry in grouped.entries) {
      final totalScore = entry.value.fold<int>(0, (sum, q) => sum + q.score);
      final maxScore = entry.value.fold<int>(0, (sum, q) => sum + q.maxScore);
      final avgTime = entry.value.fold<double>(0.0, (sum, q) => sum + q.timeTakenSeconds) / entry.value.length;

      performance[entry.key] = CategoryPerformance(
        category: entry.key,
        totalQuestions: entry.value.length,
        attemptedQuestions: entry.value.where((q) => q.isAnswered).length,
        totalScore: totalScore,
        maxPossibleScore: maxScore,
        averageTimeSeconds: avgTime,
      );
    }

    return performance;
  }

  List<WeakArea> _identifyWeakAreas(
      List<QuestionReport> questionReports,
      Map<QuestionCategory, CategoryPerformance> categoryPerformance,
      ) {
    final weakAreas = <WeakArea>[];

    for (final entry in categoryPerformance.entries) {
      if (entry.value.scorePercentage < 60) {
        weakAreas.add(WeakArea(
          topic: entry.key.displayName,
          scorePercentage: entry.value.scorePercentage,
          questionsCount: entry.value.totalQuestions,
          specificIssues: ['Low score in ${entry.key.displayName}'],
          recommendation: 'Review ${entry.key.displayName} fundamentals',
          isCritical: entry.value.scorePercentage < 40,
        ));
      }
    }

    weakAreas.sort((a, b) => a.scorePercentage.compareTo(b.scorePercentage));
    return weakAreas;
  }

  List<StrongArea> _identifyStrongAreas(
      List<QuestionReport> questionReports,
      Map<QuestionCategory, CategoryPerformance> categoryPerformance,
      ) {
    final strongAreas = <StrongArea>[];

    for (final entry in categoryPerformance.entries) {
      if (entry.value.scorePercentage >= 75) {
        strongAreas.add(StrongArea(
          topic: entry.key.displayName,
          scorePercentage: entry.value.scorePercentage,
          questionsCount: entry.value.totalQuestions,
          strengths: ['Good understanding of ${entry.key.displayName}'],
          encouragement: 'Keep up the good work!',
        ));
      }
    }

    strongAreas.sort((a, b) => b.scorePercentage.compareTo(a.scorePercentage));
    return strongAreas;
  }

  List<String> _generateRecommendations(List<WeakArea> weakAreas) {
    final recommendations = <String>[];

    for (final weak in weakAreas.take(3)) {
      recommendations.add('Focus on improving ${weak.topic} - ${weak.recommendation}');
    }

    recommendations.add('Practice with strict examiner mode for better preparation');
    recommendations.add('Review ideal answers after each session');

    return recommendations;
  }

  List<String> _generateStudyResources(List<WeakArea> weakAreas) {
    final resources = <String>[
      'Official documentation for your tech stack',
      'YouTube tutorials on viva preparation',
      'Practice with previous year viva questions',
    ];

    for (final weak in weakAreas.take(2)) {
      resources.add('Study guide for ${weak.topic}');
    }

    return resources;
  }

  int _calculateImprovement(double currentScore) {
    if (_reports.isEmpty) return 0;
    final lastScore = _reports.last.overallScorePercentage;
    return (currentScore - lastScore).toInt();
  }

  bool _isNewPersonalBest(double currentScore) {
    if (_reports.isEmpty) return true;
    final bestScore = _reports.map((r) => r.overallScorePercentage).reduce((a, b) => a > b ? a : b);
    return currentScore > bestScore;
  }

  // ============================================================
  // PRIVATE STATE METHODS
  // ============================================================

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setGenerating(bool generating) {
    _isGenerating = generating;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setLoading(false);
    _setGenerating(false);
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
