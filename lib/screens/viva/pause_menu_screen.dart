import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// PAUSE MENU SCREEN - WITH REAL SESSION DATA
// ============================================================

class PauseMenuScreen extends StatefulWidget {
  const PauseMenuScreen({super.key, this.sessionData});

  final Map<String, dynamic>? sessionData;

  @override
  State<PauseMenuScreen> createState() => _PauseMenuScreenState();
}

class _PauseMenuScreenState extends State<PauseMenuScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Real session data
  int _completedQuestions = 0;
  int _totalQuestions = 0;
  int _currentScore = 0;
  int _maxScore = 0;
  int _timeElapsed = 0;
  int _totalDuration = 0;
  int _hintsUsed = 0;
  int _maxHints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadRealSessionData();
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
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
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
        _completedQuestions = session.answeredQuestionsCount;
        _totalQuestions = session.totalQuestionsTarget;
        _currentScore = session.currentScore;
        _maxScore = session.maxPossibleScore;
        _timeElapsed = session.sessionDurationMinutes;
        _totalDuration = session.durationMinutes;
        _hintsUsed = session.hintsUsed;
        _maxHints = session.maxHintsAllowed;
        _isLoading = false;
      });
    } else if (widget.sessionData != null) {
      // Fallback to passed data if available
      setState(() {
        _completedQuestions = widget.sessionData!['completedQuestions'] ?? 0;
        _totalQuestions = widget.sessionData!['totalQuestions'] ?? 0;
        _currentScore = widget.sessionData!['currentScore'] ?? 0;
        _maxScore = widget.sessionData!['maxScore'] ?? 0;
        _timeElapsed = widget.sessionData!['timeElapsed'] ?? 0;
        _totalDuration = widget.sessionData!['totalDuration'] ?? 0;
        _hintsUsed = widget.sessionData!['hintsUsed'] ?? 0;
        _maxHints = widget.sessionData!['maxHints'] ?? 3;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Blur Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                    const Color(0xFF0A0E27).withValues(alpha: 0.95),
                    const Color(0xFF1A1F3E).withValues(alpha: 0.95),
                  ]
                      : [
                    const Color(0xFFF5F7FF).withValues(alpha: 0.95),
                    const Color(0xFFE8ECFF).withValues(alpha: 0.95),
                  ],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

            // Content
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Column(
                        children: [
                          SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildPauseCard(isDark),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: _buildActionButtons(isDark),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPauseCard(bool isDark) {
    final progressPercentage = _totalQuestions > 0
        ? (_completedQuestions / _totalQuestions) * 100
        : 0.0;
    final currentScorePercent = _maxScore > 0
        ? (_currentScore / _maxScore) * 100
        : 0.0;
    final timePercentage = _totalDuration > 0
        ? (_timeElapsed / _totalDuration) * 100
        : 0.0;

    return Container(
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : const Color(0xFF2A5CFF).withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A5CFF),
                  Color(0xFF7000FF),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause_circle_filled,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Session Paused',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Take a breath, you\'re doing great!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress Section
                _buildProgressSection(
                  title: 'Session Progress',
                  value: '$_completedQuestions/$_totalQuestions',
                  percentage: progressPercentage,
                  color: const Color(0xFF2A5CFF),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Score Section
                _buildProgressSection(
                  title: 'Current Score',
                  value: '$_currentScore/$_maxScore',
                  percentage: currentScorePercent,
                  color: currentScorePercent >= 70
                      ? const Color(0xFF4CAF50)
                      : currentScorePercent >= 50
                      ? const Color(0xFFFFB800)
                      : const Color(0xFFFF3B5C),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Time Section
                _buildProgressSection(
                  title: 'Time Elapsed',
                  value: '$_timeElapsed/$_totalDuration min',
                  percentage: timePercentage,
                  color: const Color(0xFF00E096),
                  isDark: isDark,
                ),
                const SizedBox(height: 20),

                // Hints Section
                _buildHintsSection(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String title,
    required String value,
    required double percentage,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8.0,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildHintsSection(bool isDark) {
    final remainingHints = _maxHints - _hintsUsed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0E27).withValues(alpha: 0.6)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Color(0xFFFFB800),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hints Available',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(_maxHints, (index) {
                      final isUsed = index < _hintsUsed;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isUsed
                              ? (isDark ? Colors.grey[700] : Colors.grey[300])
                              : const Color(0xFF2A5CFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            isUsed ? Icons.check : Icons.lightbulb_outline,
                            color: isUsed
                                ? (isDark ? Colors.grey[500] : Colors.grey[500])
                                : Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$remainingHints left',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2A5CFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    final remainingHints = _maxHints - _hintsUsed;

    return Column(
      children: [
        // Resume Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _resumeSession(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5CFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_arrow, size: 24),
                SizedBox(width: 8),
                Text(
                  'Resume Session',
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

        // Hint Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: remainingHints > 0 ? () => _requestHint() : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFB800),
              side: const BorderSide(color: Color(0xFFFFB800)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  remainingHints > 0 ? 'Request a Hint' : 'No Hints Left',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Review Questions Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => _reviewQuestions(),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00E096),
              side: const BorderSide(color: Color(0xFF00E096)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 20),
                SizedBox(width: 8),
                Text(
                  'Review Questions',
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

        // End Session Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => _showEndSessionDialog(isDark),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.exit_to_app, size: 20),
                SizedBox(width: 8),
                Text(
                  'End Session',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _resumeSession() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    // Since sessionProvider doesn't have resumeSession, we just pop with 'resume'
    // and handle it in the calling screen if needed, or simply pop if state is managed elsewhere.
    Navigator.pop(context, 'resume');
  }

  void _requestHint() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    sessionProvider.requestHint();
    Navigator.pop(context, 'hint');
  }

  void _reviewQuestions() {
    Navigator.pop(context, 'review');
    Navigator.pushNamed(context, AppRoutes.detailedReport);
  }

  void _showEndSessionDialog(bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session? Your progress will be saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
              await sessionProvider.completeSession();
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, 'end'); // Close pause menu
                Navigator.pushReplacementNamed(context, AppRoutes.sessionComplete);
              }
            },
            child: const Text('End Session', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
