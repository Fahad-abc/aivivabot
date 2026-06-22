import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/quiz_service.dart';
import '../../services/pdf_service.dart';

class QuizScreen extends StatefulWidget {
  final String quizType;
  final int questionCount;
  final String documentContent;

  const QuizScreen({
    super.key,
    required this.quizType,
    required this.questionCount,
    required this.documentContent,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _questions = [];
  List<String> _userAnswers = [];
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  bool _quizCompleted = false;
  int _currentIndex = 0;
  int _selectedOption = -1;
  String _userName = 'Student';
  late TextEditingController _answerController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _answerController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
    _loadUserName();
    _loadQuestions();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('userName') ?? 'Student';
      });
    }
  }

  Future<void> _loadQuestions() async {
    try {
      if (widget.quizType == 'short') {
        _questions = await QuizService.generateShortQuestions(
          documentContent: widget.documentContent,
          count: widget.questionCount,
        );
      } else {
        _questions = await QuizService.generateMCQs(
          documentContent: widget.documentContent,
          count: widget.questionCount,
        );
      }

      if (mounted) {
        _userAnswers = List.filled(_questions.length, '');
        _results = List.filled(_questions.length, {});

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading questions: $e')),
        );
      }
    }
  }

  Future<void> _submitAnswer() async {
    if (widget.quizType == 'short') {
      _userAnswers[_currentIndex] = _answerController.text;
      if (_userAnswers[_currentIndex].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please write your answer')),
        );
        return;
      }
    } else {
      if (_selectedOption == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an option')),
        );
        return;
      }
      _userAnswers[_currentIndex] = String.fromCharCode(65 + _selectedOption);
    }

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = -1;
        _answerController.clear();
      });
    } else {
      await _evaluateAllAnswers();
    }
  }

  Future<void> _evaluateAllAnswers() async {
    // Show beautiful submitting dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 4,
                      color: Color(0xFF2A5CFF),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Submitting Quiz...',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2A5CFF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI is evaluating your answers',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.grey[200],
                      color: const Color(0xFF2A5CFF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Evaluate all answers
    for (int i = 0; i < _questions.length; i++) {
      if (widget.quizType == 'short') {
        final result = await QuizService.evaluateShortAnswer(
          question: _questions[i]['question'],
          userAnswer: _userAnswers[i],
          idealAnswer: _questions[i]['idealAnswer'],
        );
        _results[i] = {
          'score': result['score'],
          'feedback': result['feedback'],
          'userAnswer': _userAnswers[i],
          'idealAnswer': _questions[i]['idealAnswer'],
          'question': _questions[i]['question'],
        };
      } else {
        final isCorrect = _userAnswers[i] == _questions[i]['correct'];
        _results[i] = {
          'score': isCorrect ? 10 : 0,
          'feedback': isCorrect ? 'Correct! 🎉' : _questions[i]['explanation'],
          'userAnswer': _userAnswers[i],
          'correctAnswer': _questions[i]['correct'],
          'question': _questions[i]['question'],
          'options': _questions[i]['options'],
        };
      }
    }

    // Close dialog
    if (mounted) {
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
      _quizCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3E)]
                  : [const Color(0xFFF5F7FF), const Color(0xFFE8ECFF)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: Color(0xFF2A5CFF),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Generating AI Questions...',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This may take a few seconds',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to generate questions',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your document and try again',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_quizCompleted) {
      return _buildResultScreen(isDark);
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3E), const Color(0xFF16213E)]
                : [const Color(0xFF667eea), const Color(0xFF764ba2), const Color(0xFFf093fb)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => _showExitDialog(),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.quizType == 'short' ? Icons.edit_note : Icons.quiz,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              widget.quizType == 'short' ? 'Short Answer' : 'Multiple Choice',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${_currentIndex + 1}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  '${((_currentIndex + 1) / _questions.length * 100).toInt()}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: (_currentIndex + 1) / _questions.length,
                                backgroundColor: Colors.white.withValues(alpha: 0.3),
                                color: Colors.white,
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Question Card
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          question['question'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0A0E27),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Answer Area
                  Expanded(
                    flex: 3,
                    child: widget.quizType == 'short'
                        ? _buildShortAnswerInput(isDark)
                        : _buildMCQOptions(question['options'], isDark),
                  ),

                  const SizedBox(height: 16),

                  // Next/Submit Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD54F), Color(0xFFFFB800)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _submitAnswer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentIndex == _questions.length - 1 ? 'Submit Quiz' : 'Next Question',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0A0E27),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentIndex == _questions.length - 1 ? Icons.check_circle : Icons.arrow_forward,
                            color: const Color(0xFF0A0E27),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShortAnswerInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note, color: Color(0xFF2A5CFF), size: 20),
              const SizedBox(width: 8),
              Text(
                'Your Answer',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2A5CFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _answerController,
              maxLines: null,
              expands: true,
              onChanged: (value) => _userAnswers[_currentIndex] = value,
              style: const TextStyle(fontSize: 16, color: Color(0xFF0A0E27)),
              decoration: InputDecoration(
                hintText: 'Type your answer here...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMCQOptions(List<dynamic> options, bool isDark) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final letter = String.fromCharCode(65 + index);
        final isSelected = _selectedOption == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedOption = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                colors: [Color(0xFF2A5CFF), Color(0xFF764ba2)],
              )
                  : null,
              color: !isSelected ? Colors.white : null,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Colors.grey[200]!,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : const Color(0xFF2A5CFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultScreen(bool isDark) {
    int totalScore = _results.fold(0, (sum, r) => sum + (r['score'] as int));
    int maxScore = _results.length * 10;
    int percentage = (totalScore / maxScore * 100).toInt();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
              Color(0xFFf093fb),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Close Button
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Score Circle
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: percentage.toDouble()),
                  duration: const Duration(seconds: 1),
                  builder: (context, value, child) {
                    return Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: value >= 70
                              ? [Colors.green, Colors.green.shade700]
                              : value >= 50
                              ? [Colors.orange, Colors.orange.shade700]
                              : [Colors.red, Colors.red.shade700],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (value >= 70
                                ? Colors.green
                                : value >= 50
                                ? Colors.orange
                                : Colors.red)
                                .withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${value.toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '$totalScore / $maxScore',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Text(
                  _getGradeMessage(percentage),
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _getAdviceMessage(percentage),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Section Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.quiz, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Question-wise Analysis',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Results List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    final score = result['score'] as int;
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: score >= 7
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  gradient: score >= 7
                                      ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                                      : const LinearGradient(colors: [Colors.red, Colors.orange]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['question'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0A0E27),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: score >= 7
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$score/10',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: score >= 7 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📝 Your Answer:',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  result['userAnswer'],
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF0A0E27)),
                                ),
                                if (result.containsKey('idealAnswer')) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '✅ Ideal Answer:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    result['idealAnswer'],
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.lightbulb, size: 14, color: Color(0xFF2A5CFF)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        result['feedback'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF2A5CFF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _quizCompleted = false;
                            _currentIndex = 0;
                            _selectedOption = -1;
                            _userAnswers = List.filled(_questions.length, '');
                            _results = List.filled(_questions.length, {});
                            _answerController.clear();
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _downloadReport(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2A5CFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Download Report'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getGradeMessage(int percentage) {
    if (percentage >= 90) return '🎉 Excellent! Outstanding performance!';
    if (percentage >= 80) return '🌟 Very Good! Keep it up!';
    if (percentage >= 70) return '👍 Good! You passed!';
    if (percentage >= 60) return '📚 Satisfactory. Need improvement.';
    if (percentage >= 50) return '⚠️ Fair. Study more!';
    return '❌ Poor performance. Review thoroughly!';
  }

  String _getAdviceMessage(int percentage) {
    if (percentage >= 90) return 'You have mastered this topic!';
    if (percentage >= 80) return 'Great job! A little more practice and you\'ll be an expert.';
    if (percentage >= 70) return 'Good effort! Review the incorrect answers.';
    if (percentage >= 60) return 'Keep practicing! Focus on weak areas.';
    if (percentage >= 50) return 'Don\'t give up! Review the material and try again.';
    return 'Consider re-reading your document and try the quiz again.';
  }

  // UPDATED: Web-compatible PDF download
  void _downloadReport() async {
    int totalScore = _results.fold(0, (sum, r) => sum + (r['score'] as int));
    int maxScore = _results.length * 10;
    int percentage = (totalScore / maxScore * 100).toInt();

    try {
      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );

      // For Web - use bytes method
      if (kIsWeb) {
        final pdfBytes = await PdfService.generateQuizReportBytes(
          userName: _userName,
          quizType: widget.quizType,
          totalScore: totalScore,
          maxScore: maxScore,
          percentage: percentage,
          results: _results,
        );

        // Download PDF in browser
        PdfService.downloadPDF(pdfBytes, 'quiz_report_${DateTime.now().millisecondsSinceEpoch}.pdf');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PDF downloaded! Check your Downloads folder'), backgroundColor: Colors.green),
          );
        }
      } else {
        // For Mobile/Desktop - use file path method
        final filePath = await PdfService.generateQuizReport(
          userName: _userName,
          quizType: widget.quizType,
          totalScore: totalScore,
          maxScore: maxScore,
          percentage: percentage,
          results: _results,
          appLogo: '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Report saved!'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Share',
                onPressed: () => PdfService.shareReport(filePath),
                textColor: Colors.white,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost. Are you sure you want to exit?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}