import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/session_model.dart';
import '../models/question_model.dart';
import '../services/api/gemini_service.dart';
import '../services/local/database_service.dart';
import '../services/speech/text_to_speech_service.dart';

class SessionProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final GeminiService _geminiService = GeminiService();
  final TextToSpeechService _tts = TextToSpeechService();

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  VivaSession? _currentSession;
  List<VivaSession> _sessionHistory = [];
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isAISpeaking = false;
  String? _currentQuestionText;
  int _currentQuestionNumber = 0;
  int _totalQuestions = 0;
  String? _errorMessage;
  String? _currentUserAnswer;
  String _liveTranscript = '';
  bool _isRecording = false;
  int _hintsUsed = 0;
  int _maxHints = 3;
  String _currentLanguage = 'english';
  bool _ttsInitialized = false;
  bool _isCompletingSession = false;
  String? _currentHint;
  String _documentContent = ''; // ✅ ADDED

  // Cache for ideal answers
  final Map<String, String> _idealAnswerCache = {};

  // Track answered question IDs to prevent duplicates
  final Set<String> _answeredQuestionIds = {};

  // ============================================================
  // GETTERS
  // ============================================================

  VivaSession? get currentSession => _currentSession;
  List<VivaSession> get sessionHistory => _sessionHistory;
  bool get isLoading => _isLoading;
  bool get isSpeaking => _isSpeaking;
  bool get isAISpeaking => _isAISpeaking;
  String? get currentQuestionText => _currentQuestionText;
  String? get errorMessage => _errorMessage;
  String? get currentHint => _currentHint;
  int get currentQuestionNumber => _currentQuestionNumber;
  int get totalQuestions => _totalQuestions;
  String? get currentUserAnswer => _currentUserAnswer;
  String get liveTranscript => _liveTranscript;
  bool get isRecording => _isRecording;
  String get currentLanguage => _currentLanguage;
  String get documentContent => _documentContent; // ✅ ADDED

  bool get hasMoreQuestions {
    if (_currentSession == null) return false;
    if (_isCompletingSession) return false;
    return _currentQuestionNumber <= _currentSession!.questions.length;
  }

  int get remainingHints => (_maxHints - _hintsUsed).clamp(0, _maxHints);
  int get hintsUsed => _hintsUsed;
  int get maxHints => _maxHints;

  double get scorePercentage {
    if (_currentSession == null) return 0;
    return _currentSession!.scorePercentage;
  }

  int get currentScore => _currentSession?.currentScore ?? 0;
  int get maxPossibleScore => _currentSession?.maxPossibleScore ?? 0;

  int get completedSessions {
    return _sessionHistory.where((s) => s.status == SessionStatus.completed).length;
  }

  double get averageScore {
    final completed = _sessionHistory.where((s) => s.status == SessionStatus.completed);
    if (completed.isEmpty) return 0;
    final total = completed.fold<double>(0, (sum, s) => sum + s.scorePercentage);
    return total / completed.length;
  }

  int get totalPracticeMinutes {
    return _sessionHistory.fold<int>(0, (sum, s) => sum + s.sessionDurationMinutes);
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));
      final hasSession = _sessionHistory.any((s) =>
      s.startTime.year == date.year &&
          s.startTime.month == date.month &&
          s.startTime.day == date.day);
      if (hasSession) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  // ============================================================
  // SETTERS
  // ============================================================

  void setDocumentContent(String content) {
    _documentContent = content;
    notifyListeners();
  }

  void setCurrentQuestion(String question) {
    _currentQuestionText = question;
    notifyListeners();
  }

  // ============================================================
  // TTS METHODS
  // ============================================================

  Future<void> _initTTS() async {
    if (_ttsInitialized) return;

    String ttsLanguage = 'en-US';
    if (_currentLanguage == 'roman_urdu') {
      ttsLanguage = 'ur-PK';
    }

    await _tts.init(language: ttsLanguage);

    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('voiceSpeed') ?? 1.0;
    final savedPitch = prefs.getDouble('voicePitch') ?? 1.0;
    await _tts.setSpeechRate(savedSpeed / 2.0);
    await _tts.setPitch(savedPitch);

    _ttsInitialized = true;
    print('TTS initialized: lang=$ttsLanguage, speed=$savedSpeed, pitch=$savedPitch');
  }

  Future<void> speakQuestion(String question) async {
    await _initTTS();
    _isAISpeaking = true;
    notifyListeners();

    await _tts.speak(question);

    _isAISpeaking = false;
    notifyListeners();
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
    _isAISpeaking = false;
    notifyListeners();
  }

  // ============================================================
  // SESSION LIFECYCLE
  // ============================================================

  Future<void> createSession({
    required String examinerMode,
    required int durationMinutes,
    required int totalQuestions,
    int maxHintsAllowed = 3,
    bool allowRetries = true,
    String? fypDocumentPath,
    Map<String, dynamic>? fypMetadata,
    List<Question>? customQuestions,
    String language = 'english',
  }) async {
    _isLoading = true;
    _maxHints = maxHintsAllowed;
    _currentLanguage = language;
    _answeredQuestionIds.clear();
    _isCompletingSession = false;
    notifyListeners();
    _clearError();

    try {
      final mode = _stringToExaminerMode(examinerMode);

      final questions = customQuestions ??
          await _geminiService.generateQuestions(
            mode: mode,
            count: totalQuestions,
            fypMetadata: fypMetadata,
            language: language,
          );

      _currentSession = VivaSession(
        id: 'session_${DateTime.now().millisecondsSinceEpoch}',
        startTime: DateTime.now(),
        status: SessionStatus.notStarted,
        examinerMode: mode,
        totalQuestionsTarget: totalQuestions,
        durationMinutes: durationMinutes,
        maxHintsAllowed: maxHintsAllowed,
        allowRetries: allowRetries,
        fypDocumentPath: fypDocumentPath,
        fypMetadata: fypMetadata,
        questions: questions,
      );

      _totalQuestions = totalQuestions;
      _currentQuestionNumber = 0;
      _currentQuestionText = _currentSession!.currentQuestion.text;
      _hintsUsed = 0;
      _idealAnswerCache.clear();

      await _initTTS();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  ExaminerMode _stringToExaminerMode(String mode) {
    switch (mode.toLowerCase()) {
      case 'friendly':
        return ExaminerMode.friendly;
      case 'strict':
        return ExaminerMode.strict;
      case 'technical':
        return ExaminerMode.technicalExpert;
      case 'mixed':
      default:
        return ExaminerMode.mixed;
    }
  }

  Future<void> startSession() async {
    if (_currentSession != null && _currentSession!.status == SessionStatus.notStarted) {
      _currentSession!.startSession();
      _currentQuestionNumber = 1;
      _currentQuestionText = _currentSession!.currentQuestion.text;

      await speakQuestion(_currentQuestionText!);

      notifyListeners();
    }
  }

  // ============================================================
  // SUBMIT ANSWER - COMPLETE FIXED VERSION
  // ============================================================

  Future<void> submitAnswer(String answer) async {
    if (_currentSession == null) {
      print('No current session');
      return;
    }

    if (_isCompletingSession) {
      print('Session already completing, ignoring submit');
      return;
    }

    final currentQuestionId = _currentSession!.currentQuestion.id;

    if (_answeredQuestionIds.contains(currentQuestionId)) {
      print('Question already answered, skipping duplicate submission');
      return;
    }

    print('========================================');
    print('Submitting answer for question $_currentQuestionNumber');
    print('Answer: ${answer.substring(0, answer.length > 50 ? 50 : answer.length)}...');

    _isLoading = true;
    notifyListeners();

    try {
      final evaluation = await _geminiService.evaluateAnswer(
        question: _currentSession!.currentQuestion,
        userAnswer: answer,
        language: _currentLanguage,
      );

      print('Score: ${evaluation.score} - Feedback: ${evaluation.feedback}');

      _answeredQuestionIds.add(currentQuestionId);

      _currentSession!.recordAnswer(
        currentQuestionId,
        answer,
        evaluation.score,
        evaluation.feedback,
      );

      _generateIdealAnswerForQuestion(_currentSession!.currentQuestion.text);

      final totalQuestionsCount = _currentSession!.questions.length;
      print('Current position: $_currentQuestionNumber / $totalQuestionsCount');

      if (_currentQuestionNumber >= totalQuestionsCount) {
        print('Session complete - no more questions');
        _isLoading = false;
        notifyListeners();
        await completeSession();
        return;
      }

      _currentHint = null;
      _currentSession!.moveToNextQuestion();
      _currentQuestionNumber++;
      _currentQuestionText = _currentSession!.currentQuestion.text;
      print('Moved to question $_currentQuestionNumber / $totalQuestionsCount');

      await speakQuestion(_currentQuestionText!);

      _isLoading = false;
      notifyListeners();
      print('========================================');

    } catch (e) {
      print('Submit answer error: $e');
      _setError(e.toString());
    }
  }

  // Alternative submit with feedback display
  Future<void> submitAnswerWithFeedback(String answer) async {
    if (_currentSession == null) return;

    if (_isCompletingSession) return;

    final currentQuestionId = _currentSession!.currentQuestion.id;

    if (_answeredQuestionIds.contains(currentQuestionId)) {
      print('Question already answered, skipping duplicate submission');
      return;
    }

    print('Submitting answer with feedback for question $_currentQuestionNumber');

    _isLoading = true;
    _isAISpeaking = true;
    notifyListeners();

    try {
      final evaluation = await _geminiService.evaluateAnswer(
        question: _currentSession!.currentQuestion,
        userAnswer: answer,
        language: _currentLanguage,
      );

      print('Score: ${evaluation.score} - Feedback: ${evaluation.feedback}');

      _answeredQuestionIds.add(currentQuestionId);

      _currentSession!.recordAnswer(
        currentQuestionId,
        answer,
        evaluation.score,
        evaluation.feedback,
      );

      final isAnswerWrong = evaluation.score < 6;

      if (isAnswerWrong) {
        _currentQuestionText = 'Wrong! ${evaluation.feedback}\n\nMoving to next question...';
        notifyListeners();
        await Future.delayed(const Duration(seconds: 2));
      }

      _generateIdealAnswerForQuestion(_currentSession!.currentQuestion.text);

      final totalQuestionsCount = _currentSession!.questions.length;

      if (_currentQuestionNumber < totalQuestionsCount) {
        _currentSession!.moveToNextQuestion();
        _currentQuestionNumber++;
        _currentQuestionText = _currentSession!.currentQuestion.text;
        print('Moved to question $_currentQuestionNumber');

        await speakQuestion(_currentQuestionText!);
      } else {
        await completeSession();
      }

      _isLoading = false;
      _isAISpeaking = false;
      notifyListeners();

    } catch (e) {
      _setError(e.toString());
    }
  }

  // ============================================================
  // GENERATE IDEAL ANSWER FOR REVIEW SCREEN
  // ============================================================

  Future<String> generateIdealAnswer(String questionText) async {
    if (_idealAnswerCache.containsKey(questionText)) {
      return _idealAnswerCache[questionText]!;
    }

    try {
      final idealAnswer = await _geminiService.generateIdealAnswer(
        questionText,
        language: _currentLanguage,
      );
      _idealAnswerCache[questionText] = idealAnswer;
      return idealAnswer;
    } catch (e) {
      print('Error generating ideal answer: $e');
      return 'Review your project documentation for the ideal answer.';
    }
  }

  Future<void> _generateIdealAnswerForQuestion(String questionText) async {
    try {
      final idealAnswer = await _geminiService.generateIdealAnswer(
        questionText,
        language: _currentLanguage,
      );
      _idealAnswerCache[questionText] = idealAnswer;
      notifyListeners();
    } catch (e) {
      print('Background ideal answer generation error: $e');
    }
  }

  String? getCachedIdealAnswer(String questionText) {
    return _idealAnswerCache[questionText];
  }

  Future<String?> requestHint() async {
    if (_currentSession == null) return null;
    if (_hintsUsed >= _maxHints) return null;

    _hintsUsed++;

    try {
      _currentHint = await _geminiService.getHint(_currentSession!.currentQuestion);
      notifyListeners();
      return _currentHint;
    } catch (e) {
      print('Hint error: $e');
      _currentHint = null;
      return null;
    }
  }

  Future<void> completeSession() async {
    if (_currentSession != null && !_isCompletingSession) {
      _isCompletingSession = true;
      await _tts.stop();
      _currentSession!.completeSession();

      final prefs = await SharedPreferences.getInstance();
      final autoSave = prefs.getBool('autoSaveSessions') ?? true;
      if (autoSave) {
        await _databaseService.saveSession(_currentSession!);
        _sessionHistory.add(_currentSession!);
        print('Session completed and saved');
      } else {
        print('Session completed (auto-save disabled)');
      }

      notifyListeners();
    }
  }

  Future<void> loadSessionHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _sessionHistory = await _databaseService.getAllSessions();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void resetCurrentSession() {
    _tts.stop();
    _currentSession = null;
    _currentQuestionText = null;
    _currentUserAnswer = null;
    _liveTranscript = '';
    _currentQuestionNumber = 0;
    _totalQuestions = 0;
    _isRecording = false;
    _isAISpeaking = false;
    _hintsUsed = 0;
    _idealAnswerCache.clear();
    _answeredQuestionIds.clear();
    _currentHint = null;
    _isCompletingSession = false;
    notifyListeners();
  }

  // ============================================================
  // VOICE METHODS
  // ============================================================

  void startListening() {
    _isRecording = true;
    _liveTranscript = '';
    notifyListeners();
  }

  void stopListening() {
    _isRecording = false;
    notifyListeners();
  }

  void updateTranscript(String text) {
    _liveTranscript = text;
    _currentUserAnswer = text;
    notifyListeners();
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    _isAISpeaking = false;
    _isCompletingSession = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
