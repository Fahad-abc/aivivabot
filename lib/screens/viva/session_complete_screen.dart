import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/screens/report/detailed_report_screen.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// SESSION COMPLETE SCREEN - WITH REAL DATA
// ============================================================

class SessionCompleteScreen extends StatefulWidget {
  const SessionCompleteScreen({super.key, this.sessionData});

  final Map<String, dynamic>? sessionData;

  @override
  State<SessionCompleteScreen> createState() => _SessionCompleteScreenState();
}

class _SessionCompleteScreenState extends State<SessionCompleteScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Real data from session provider
  int _overallScore = 0;
  int _maxScore = 0;
  int _answeredQuestions = 0;
  int _totalQuestions = 0;
  int _hintsUsed = 0;
  int _timeSpent = 0;
  int _duration = 0;
  String _weakArea = '';
  double _weakScore = 0.0;
  String _examinerMode = '';
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRealSessionData();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  void _loadRealSessionData() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final session = sessionProvider.currentSession;

    if (session != null) {
      setState(() {
        _overallScore = session.currentScore;
        _maxScore = session.maxPossibleScore;
        _answeredQuestions = session.answeredQuestionsCount;
        _totalQuestions = session.totalQuestionsTarget;
        _hintsUsed = session.hintsUsed;
        _timeSpent = session.sessionDurationMinutes;
        _duration = session.durationMinutes;
        _examinerMode = _getModeString(session.examinerMode);
        _correctAnswers = session.correctQuestions.length;
        _incorrectAnswers = session.failedQuestions.length;

        // Find weakest area from answers
        if (session.questionAnswers.isNotEmpty) {
          double lowestScore = 100.0;
          String weakestTopic = '';

          for (var qa in session.questionAnswers) {
            final scorePercent = (qa.score / qa.question.maxScore) * 100;
            if (scorePercent < lowestScore) {
              lowestScore = scorePercent;
              weakestTopic = qa.question.text.length > 30
                  ? '${qa.question.text.substring(0, 30)}...'
                  : qa.question.text;
            }
          }

          _weakArea = weakestTopic.isEmpty ? 'Review your answers' : weakestTopic;
          _weakScore = lowestScore == 100.0 ? 0.0 : lowestScore;
        } else {
          _weakArea = 'Complete more questions';
          _weakScore = 0.0;
        }
      });
    }
  }

  String _getModeString(mode) {
    switch (mode.toString()) {
      case 'ExaminerMode.friendly':
        return 'Friendly';
      case 'ExaminerMode.strict':
        return 'Strict';
      case 'ExaminerMode.technicalExpert':
        return 'Technical';
      case 'ExaminerMode.mixed':
        return 'Mixed';
      default:
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
    final scorePercentage = _maxScore > 0 ? (_overallScore / _maxScore) * 100 : 0.0;
    final isGoodScore = scorePercentage >= 70;
    final isMediumScore = scorePercentage >= 50 && scorePercentage < 70;

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildHeader(isDark),
                  ),
                  const SizedBox(height: 32),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildScoreCircle(isDark, scorePercentage, isGoodScore, isMediumScore),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildStatsGrid(isDark, scorePercentage),
                  ),
                  const SizedBox(height: 24),
                  if (_weakArea.isNotEmpty && _weakScore > 0)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildWeakAreaCard(isDark),
                    ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(isDark),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.emoji_events,
            color: Color(0xFFFFB800),
            size: 50,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Session Complete!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Great effort! Here\'s how you performed',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreCircle(bool isDark, double percentage, bool isGoodScore, bool isMediumScore) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoodScore
              ? [const Color(0xFF4CAF50), const Color(0xFF8BC34A)]
              : isMediumScore
              ? [const Color(0xFFFFB800), const Color(0xFFFF9800)]
              : [const Color(0xFFFF3B5C), const Color(0xFFFF5722)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isGoodScore
                ? const Color(0xFF4CAF50)
                : isMediumScore
                ? const Color(0xFFFFB800)
                : const Color(0xFFFF3B5C))
                .withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? const Color(0xFF1A1F3E)
              : Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${percentage.toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              Text(
                'Score',
                style: TextStyle(
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

  Widget _buildStatsGrid(bool isDark, double scorePercentage) {
    final accuracyPercentage = _totalQuestions > 0
        ? (_correctAnswers / _totalQuestions) * 100
        : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Questions',
          value: '$_answeredQuestions/$_totalQuestions',
          icon: Icons.quiz,
          color: const Color(0xFF2A5CFF),
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Correct/Incorrect',
          value: '$_correctAnswers/$_incorrectAnswers',
          icon: Icons.check_circle,
          color: const Color(0xFF00E096),
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Hints Used',
          value: '$_hintsUsed',
          icon: Icons.lightbulb,
          color: const Color(0xFFFFB800),
          isDark: isDark,
        ),
        _buildStatCard(
          title: 'Time Spent',
          value: '$_timeSpent/$_duration min',
          icon: Icons.timer,
          color: const Color(0xFF7000FF),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeakAreaCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF3B5C).withOpacity(0.15),
            const Color(0xFFFFB800).withOpacity(0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF3B5C).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.trending_down,
              color: Color(0xFFFF3B5C),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Area to Improve',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _weakArea,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _weakScore / 100,
                    minHeight: 6.0,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    color: const Color(0xFFFF3B5C),
                  ),
                ),
                Text(
                  'Score: ${_weakScore.toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFFF3B5C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _viewFullReport(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.analytics, size: 22),
                SizedBox(width: 8),
                Text(
                  'View Full Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => _startNewSession(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF2A5CFF),
              side: const BorderSide(color: Color(0xFF2A5CFF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.play_arrow, size: 20),
                SizedBox(width: 8),
                Text(
                  'Start New Session',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _goToDashboard(),
          child: Text(
            'Back to Dashboard',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  void _viewFullReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DetailedReportScreen()),
    );
  }

  void _startNewSession() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.resetCurrentSession();
    // Navigate to examiner selection
    Navigator.pushReplacementNamed(context, '/examiner-selection');
  }

  void _goToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }
}