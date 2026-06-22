import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/models/session_model.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// DETAILED REPORT SCREEN - LIVE DATA WITH AI IDEAL ANSWERS
// ============================================================

class DetailedReportScreen extends StatefulWidget {
  const DetailedReportScreen({super.key, this.reportData});

  final Map<String, dynamic>? reportData;

  @override
  State<DetailedReportScreen> createState() => _DetailedReportScreenState();
}

class _DetailedReportScreenState extends State<DetailedReportScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedQuestionIndex = -1;
  Map<String, dynamic> _liveReport = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadLiveData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  Future<void> _loadLiveData() async {
    setState(() {
      _isLoading = true;
    });

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final session = sessionProvider.currentSession;

    if (session == null) {
      setState(() {
        _liveReport = {};
        _isLoading = false;
      });
      return;
    }

    final List<Map<String, dynamic>> questionsList = [];

    for (var qa in session.questionAnswers) {
      final question = qa.question;
      final userAnswer = qa.userAnswer;
      final score = qa.score;
      final feedback = qa.feedback;

      // Generate ideal answer using AI
      String idealAnswer = question.idealAnswer ?? '';

      if (idealAnswer.isEmpty || idealAnswer == 'Ideal answer not available') {
        idealAnswer = await sessionProvider.generateIdealAnswer(question.text);
      }

      List<String> missingPoints = [];
      List<String> strongPoints = [];

      if (score < 5) {
        missingPoints = ['Review core concepts', 'Study more examples', 'Understand the fundamentals'];
      } else if (score < 7) {
        missingPoints = ['Add more technical details', 'Provide better explanation', 'Use examples'];
      } else if (score >= 8) {
        strongPoints = ['Good technical understanding', 'Clear explanation', 'Good use of examples'];
      }

      questionsList.add({
        'id': questionsList.length + 1,
        'text': question.text,
        'userAnswer': userAnswer,
        'idealAnswer': idealAnswer,
        'score': score,
        'maxScore': question.maxScore,
        'feedback': feedback,
        'missingPoints': missingPoints,
        'strongPoints': strongPoints,
      });
    }

    // Calculate category scores
    int totalScore = session.currentScore;
    int maxPossibleScore = session.maxPossibleScore;
    double overallPercentage = session.scorePercentage;

    int technicalScore = (overallPercentage * 0.85).toInt();
    int communicationScore = (overallPercentage * 0.75).toInt();
    int confidenceScore = (overallPercentage * 0.70).toInt();

    List<Map<String, dynamic>> weakAreas = [];
    List<Map<String, dynamic>> strongAreas = [];

    for (var qa in questionsList) {
      final qScore = qa['score'] as int;
      final qText = qa['text'] as String;
      final qMaxScore = qa['maxScore'] as int;

      if (qScore < 5) {
        weakAreas.add({
          'topic': qText.length > 30 ? '${qText.substring(0, 30)}...' : qText,
          'score': ((qScore) / (qMaxScore) * 100).toInt(),
          'questions': 1,
        });
      } else if (qScore >= 8) {
        strongAreas.add({
          'topic': qText.length > 30 ? '${qText.substring(0, 30)}...' : qText,
          'score': ((qScore) / (qMaxScore) * 100).toInt(),
          'questions': 1,
        });
      }
    }

    List<String> recommendations = [];
    if (weakAreas.isNotEmpty) {
      recommendations.add('Review ${weakAreas.length} topic(s) where you scored low');
    }
    if (technicalScore < 70) {
      recommendations.add('Improve technical knowledge by studying core concepts');
    }
    if (communicationScore < 70) {
      recommendations.add('Practice explaining your project with more clarity');
    }
    if (recommendations.isEmpty) {
      recommendations.add('Great job! Continue practicing to maintain your performance');
    }

    setState(() {
      _liveReport = {
        'sessionDate': _formatDate(session.startTime),
        'examinerMode': _getModeString(session.examinerMode),
        'duration': '${session.sessionDurationMinutes} minutes',
        'overallScore': totalScore,
        'maxScore': maxPossibleScore,
        'technicalScore': technicalScore,
        'communicationScore': communicationScore,
        'confidenceScore': confidenceScore,
        'questions': questionsList,
        'weakAreas': weakAreas.isEmpty ? [{'topic': 'None identified', 'score': 0, 'questions': 0}] : weakAreas,
        'strongAreas': strongAreas.isEmpty ? [{'topic': 'Keep practicing', 'score': 0, 'questions': 0}] : strongAreas,
        'recommendations': recommendations,
      };
      _isLoading = false;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getModeString(ExaminerMode mode) {
    switch (mode) {
      case ExaminerMode.friendly:
        return 'Friendly';
      case ExaminerMode.strict:
        return 'Strict';
      case ExaminerMode.technicalExpert:
        return 'Technical';
      case ExaminerMode.mixed:
        return 'Mixed';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

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
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_liveReport.isEmpty) {
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
                const Icon(Icons.analytics, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No session data available',
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A5CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                const Color(0xFF0A0E27),
                const Color(0xFF1A1F3E),
                const Color(0xFF16213E),
              ]
                  : [
                const Color(0xFFF5F7FF),
                const Color(0xFFE8ECFF),
                const Color(0xFFE0E7FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildScoreCard(isDark),
                            const SizedBox(height: 20),
                            _buildCategoryBreakdown(isDark),
                            const SizedBox(height: 20),
                            _buildQuestionsSection(isDark),
                            const SizedBox(height: 20),
                            _buildWeakStrongAreas(isDark),
                            const SizedBox(height: 20),
                            _buildRecommendations(isDark),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Report',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  '${_liveReport['sessionDate']} • ${_liveReport['examinerMode']} Mode',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A5CFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.download, color: Color(0xFF2A5CFF), size: 16),
                const SizedBox(width: 4),
                Text(
                  'PDF',
                  style: TextStyle(
                    color: const Color(0xFF2A5CFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(bool isDark) {
    final score = _liveReport['overallScore'] as int;
    final maxScore = _liveReport['maxScore'] as int;
    final percentage = maxScore > 0 ? (score / maxScore * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: percentage >= 70
              ? [const Color(0xFF2A5CFF), const Color(0xFF7000FF)]
              : percentage >= 50
              ? [const Color(0xFFFFB800), const Color(0xFFFF3B5C)]
              : [const Color(0xFFF44336), const Color(0xFFFF5722)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (percentage >= 70 ? const Color(0xFF2A5CFF) : const Color(0xFFFFB800)).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Score',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$score',
                        style: GoogleFonts.poppins(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '/$maxScore',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: percentage / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniScore('Technical', _liveReport['technicalScore'] as int),
              _buildMiniScore('Communication', _liveReport['communicationScore'] as int),
              _buildMiniScore('Confidence', _liveReport['confidenceScore'] as int),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniScore(String label, int score) {
    return Column(
      children: [
        Text(
          '$score%',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown(bool isDark) {
    final categories = [
      {'name': 'Technical', 'score': _liveReport['technicalScore'], 'color': const Color(0xFF2A5CFF), 'icon': Icons.code},
      {'name': 'Communication', 'score': _liveReport['communicationScore'], 'color': const Color(0xFF00E096), 'icon': Icons.chat},
      {'name': 'Confidence', 'score': _liveReport['confidenceScore'], 'color': const Color(0xFFFFB800), 'icon': Icons.psychology},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A5CFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.category,
                  color: Color(0xFF2A5CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Category Breakdown',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cat['name'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (cat['score'] as int) / 100,
                          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                          color: cat['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${cat['score']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: (cat['score'] as int) >= 70
                        ? const Color(0xFF4CAF50)
                        : (cat['score'] as int) >= 50
                        ? const Color(0xFFFFB800)
                        : const Color(0xFFFF3B5C),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(bool isDark) {
    final questions = _liveReport['questions'] as List;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Color(0xFF2A5CFF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Question Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final q = entry.value as Map<String, dynamic>;
            final isExpanded = _selectedQuestionIndex == index;
            final qScore = q['score'] as int;
            final qMaxScore = q['maxScore'] as int;
            final scorePercent = qMaxScore > 0 ? ((qScore / qMaxScore) * 100).toInt() : 0;

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedQuestionIndex = isExpanded ? -1 : index;
                    });
                    HapticFeedback.lightImpact();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: scorePercent >= 70
                                ? Colors.green.withOpacity(0.1)
                                : scorePercent >= 50
                                ? Colors.orange.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              scorePercent >= 70
                                  ? Icons.check_circle
                                  : scorePercent >= 50
                                  ? Icons.trending_up
                                  : Icons.error,
                              color: scorePercent >= 70
                                  ? Colors.green
                                  : scorePercent >= 50
                                  ? Colors.orange
                                  : Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Q${index + 1}. ${q['text']}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: scorePercent >= 70
                                          ? Colors.green.withOpacity(0.1)
                                          : scorePercent >= 50
                                          ? Colors.orange.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${q['score']}/${q['maxScore']}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: scorePercent >= 70
                                            ? Colors.green
                                            : scorePercent >= 50
                                            ? Colors.orange
                                            : Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    isExpanded
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    size: 18,
                                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        _buildAnswerSection(
                          title: 'Your Answer',
                          content: q['userAnswer'] as String,
                          icon: Icons.record_voice_over,
                          color: const Color(0xFF2A5CFF),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _buildAnswerSection(
                          title: 'Ideal Answer (AI Generated)',
                          content: q['idealAnswer'] as String,
                          icon: Icons.auto_awesome,
                          color: const Color(0xFF4CAF50),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.amber : Colors.blue).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.feedback,
                                color: isDark ? Colors.amber[300] : Colors.blue[700],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  q['feedback'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if ((q['missingPoints'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildPointsList(
                              title: 'Missing Points',
                              points: q['missingPoints'] as List,
                              color: Colors.red,
                              isDark: isDark,
                            ),
                          ),
                        if ((q['strongPoints'] as List).isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: _buildPointsList(
                              title: 'Strong Points',
                              points: q['strongPoints'] as List,
                              color: Colors.green,
                              isDark: isDark,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (index < questions.length - 1) const Divider(height: 1),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnswerSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0A0E27).withOpacity(0.6)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200]!,
            ),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsList({
    required String title,
    required List points,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 4),
          child: Row(
            children: [
              Icon(Icons.circle, color: color, size: 6),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  point.toString(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildWeakStrongAreas(bool isDark) {
    final weakAreas = _liveReport['weakAreas'] as List;
    final strongAreas = _liveReport['strongAreas'] as List;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Weak Areas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...weakAreas.map((area) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['topic'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (area['score'] > 0)
                        Text(
                          'Score: ${area['score']}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Strong Areas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...strongAreas.map((area) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['topic'],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (area['score'] > 0)
                        Text(
                          'Score: ${area['score']}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations(bool isDark) {
    final recommendations = _liveReport['recommendations'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A5CFF).withOpacity(0.1),
            const Color(0xFF7000FF).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2A5CFF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A5CFF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFFFFB800),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'AI Recommendations',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...recommendations.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A5CFF).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A5CFF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}