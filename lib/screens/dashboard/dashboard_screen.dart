import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/models/session_model.dart';
import 'package:aivivabot/screens/report/detailed_report_screen.dart';
import 'package:aivivabot/routes.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  Future<void> _loadData() async {
    await Future.delayed(Duration.zero);
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.loadSessionHistory();
    if (mounted) {
      setState(() {});
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
    final authProvider = Provider.of<AuthProvider>(context);
    final sessionProvider = Provider.of<SessionProvider>(context);

    final completedSessionsCount = sessionProvider.completedSessions;
    final averageScore = sessionProvider.averageScore;
    final totalPracticeMinutes = sessionProvider.totalPracticeMinutes;
    final currentStreak = sessionProvider.currentStreak;

    final allSessionsList = sessionProvider.sessionHistory;
    final recentSessions = allSessionsList
        .where((s) => s.status == SessionStatus.completed)
        .toList()
        .reversed
        .take(3)
        .toList();

    final performanceTrend = _getPerformanceTrend(sessionProvider);
    final weakTopics = _getWeakTopics(sessionProvider);
    final bestScore = _getBestScore(sessionProvider);
    final totalQuestions = _getTotalQuestions(sessionProvider);

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
                _buildHeader(isDark, authProvider),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildWelcomeCard(isDark, authProvider, currentStreak),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildStatsSection(isDark, completedSessionsCount, averageScore, totalPracticeMinutes),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildQuickActions(isDark),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildRecentSessions(isDark, recentSessions),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildWeakAreasSection(isDark, weakTopics),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildProgressSection(isDark, performanceTrend, bestScore, averageScore, totalQuestions),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(isDark),
      ),
    );
  }

  Widget _buildHeader(bool isDark, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              Text(
                'Welcome back!',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => AppRoutes.navigateToSettings(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.settings_outlined,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showProfileDialog(),
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      authProvider.userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(bool isDark, AuthProvider authProvider, int streak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A5CFF),
            Color(0xFF7000FF),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A5CFF).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${authProvider.userName}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ready for your viva practice today?',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Streak: $streak days',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark, int sessions, double avgScore, int practiceMins) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Sessions',
            value: '$sessions',
            icon: Icons.play_circle_outline,
            gradient: const [Color(0xFF2A5CFF), Color(0xFF4A7CFF)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Avg Score',
            value: '${avgScore.toInt()}%',
            icon: Icons.star_outline,
            gradient: const [Color(0xFFFFB800), Color(0xFFFFD54F)],
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Practice',
            value: '${practiceMins}min',
            icon: Icons.timer_outlined,
            gradient: const [Color(0xFF00E096), Color(0xFF4ADE80)],
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradient,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
          ),
        ),
        const SizedBox(height: 12),

        // Row 1: Start Viva + Upload FYP
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Start Viva',
                subtitle: 'Begin practice',
                icon: Icons.play_circle_filled,
                color: const Color(0xFF2A5CFF),
                onTap: () => _checkAndStartViva(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Upload FYP',
                subtitle: 'Document upload',
                icon: Icons.upload_file,
                color: const Color(0xFF7000FF),
                onTap: () => AppRoutes.navigateToDocumentUpload(context),
                isDark: isDark,
              ),
            ),
          ],
        ),

        // Row 2: Reports + History
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Reports',
                subtitle: 'Performance analysis',
                icon: Icons.analytics,
                color: const Color(0xFF00E096),
                onTap: () => _viewDetailedReport(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'History',
                subtitle: 'View past sessions',
                icon: Icons.history,
                color: const Color(0xFFFFB800),
                onTap: () => _showHistoryDialog(),
                isDark: isDark,
              ),
            ),
          ],
        ),

        // Row 3: Weak Areas + Help
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Weak Areas',
                subtitle: 'Improve topics',
                icon: Icons.trending_up,
                color: const Color(0xFFFF3B5C),
                onTap: () => _showWeakAreasDialog(),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Help',
                subtitle: 'Tutorial & tips',
                icon: Icons.help_outline,
                color: const Color(0xFF2A5CFF),
                onTap: () => AppRoutes.navigateToHelp(context),
                isDark: isDark,
              ),
            ),
          ],
        ),

        // Row 4: Theory Quiz + Study Notes
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'Theory Quiz',
                subtitle: 'Test yourself',
                icon: Icons.quiz,
                color: const Color(0xFF9C27B0),
                onTap: () => AppRoutes.navigateToQuizTypeSelection(context),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                title: 'Study Notes',
                subtitle: 'AI generates notes',
                icon: Icons.note_alt,
                color: const Color(0xFF00E5FF),
                onTap: () => AppRoutes.navigateToNotes(context),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
      
    );
  }

  

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(bool isDark, List<VivaSession> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[200]!,
          ),
        ),
        child: const Center(
          child: Text('No sessions yet. Start a viva practice!'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Sessions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              TextButton(
                onPressed: () => _showHistoryDialog(),
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFF2A5CFF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...sessions.map((session) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildSessionCard(session, isDark),
        )),
      ],
    );
  }

  Widget _buildSessionCard(VivaSession session, bool isDark) {
    final score = session.scorePercentage.toInt();
    final formattedDate = '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}';

    return GestureDetector(
      onTap: () => _viewDetailedReport(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.mic, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.examinerMode.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: score >= 70
                    ? Colors.green.withValues(alpha: 0.1)
                    : score >= 50
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$score%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: score >= 70
                      ? Colors.green
                      : score >= 50
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeakAreasSection(bool isDark, List<Map<String, dynamic>> weakTopics) {
    if (weakTopics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Areas to Improve',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: weakTopics.map((topic) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          topic['topic'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF0A0E27),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${topic['score']}%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (topic['score'] as int) / 100,
                      backgroundColor: Colors.red.withValues(alpha: 0.2),
                      color: Colors.red,
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(bool isDark, List<double> trendData, int bestScore, double avgScore, int totalQuestions) {
    if (trendData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey[200]!,
          ),
        ),
        child: const Center(
          child: Text('Complete sessions to see performance trend'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Performance Trend',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTrendItem(
                    label: 'Best Score',
                    value: '$bestScore%',
                    icon: Icons.emoji_events,
                    color: const Color(0xFFFFB800),
                    isDark: isDark,
                  ),
                  _buildTrendItem(
                    label: 'Avg Score',
                    value: '${avgScore.toInt()}%',
                    icon: Icons.trending_up,
                    color: const Color(0xFF2A5CFF),
                    isDark: isDark,
                  ),
                  _buildTrendItem(
                    label: 'Total Qs',
                    value: '$totalQuestions',
                    icon: Icons.quiz,
                    color: const Color(0xFF00E096),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: trendData.asMap().entries.map((entry) {
                    final double heightValue = (entry.value / 100) * 80;
                    final double finalHeight = heightValue > 5 ? heightValue : 5;
                    return Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 30,
                              height: finalHeight,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'S${entry.key + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
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
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0, isDark),
              _buildNavItem(Icons.bar_chart, 'Stats', 1, isDark),
              _buildNavItem(Icons.person, 'Profile', 2, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
        if (index == 1) _viewDetailedReport();
        if (index == 2) _showProfileDialog();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF2A5CFF) : (isDark ? Colors.grey[500] : Colors.grey[400]),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? const Color(0xFF2A5CFF) : (isDark ? Colors.grey[500] : Colors.grey[400]),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  List<double> _getPerformanceTrend(SessionProvider provider) {
    final completedSessions = provider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

    if (completedSessions.length > 7) {
      return completedSessions.reversed.take(7).map((s) => s.scorePercentage).toList().reversed.toList();
    }
    return completedSessions.map((s) => s.scorePercentage).toList();
  }

  List<Map<String, dynamic>> _getWeakTopics(SessionProvider provider) {
    final weakTopics = <Map<String, dynamic>>[];
    final sessions = provider.sessionHistory;

    for (var session in sessions) {
      if (session.status == SessionStatus.completed) {
        for (var qa in session.questionAnswers) {
          final score = qa.score;
          final maxScore = qa.question.maxScore;
          final percentage = (score / maxScore) * 100;
          final percentageInt = percentage.toInt();

          if (percentage < 50) {
            final topic = qa.question.text.length > 40
                ? '${qa.question.text.substring(0, 40)}...'
                : qa.question.text;

            if (!weakTopics.any((t) => t['topic'] == topic)) {
              weakTopics.add({
                'topic': topic,
                'score': percentageInt,
              });
            }
          }
        }
      }
    }

    return weakTopics.take(3).toList();
  }

  int _getBestScore(SessionProvider provider) {
    final completedSessions = provider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

    if (completedSessions.isEmpty) return 0;

    double best = 0;
    for (var session in completedSessions) {
      if (session.scorePercentage > best) {
        best = session.scorePercentage;
      }
    }
    return best.toInt();
  }

  int _getTotalQuestions(SessionProvider provider) {
    int total = 0;
    final sessions = provider.sessionHistory;

    for (var session in sessions) {
      if (session.status == SessionStatus.completed) {
        total += session.answeredQuestionsCount;
      }
    }
    return total;
  }

  Future<void> _checkAndStartViva() async {
    final prefs = await SharedPreferences.getInstance();
    final isDocumentUploaded = prefs.getBool('isDocumentUploaded') ?? false;

    if (isDocumentUploaded) {
      if (mounted) AppRoutes.navigateToExaminerSelection(context);
    } else {
      _showDocumentRequiredDialog();
    }
  }

  void _showDocumentRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('FYP Document Required'),
        content: const Text(
          'Please upload your FYP document first. '
              'AI needs your project details to generate relevant questions.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppRoutes.navigateToDocumentUpload(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A5CFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Upload Now'),
          ),
        ],
      ),
    );
  }

  void _viewDetailedReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailedReportScreen(),
      ),
    );
  }

  void _showHistoryDialog() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final allSessions = sessionProvider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Session History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (allSessions.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No sessions completed yet'),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: allSessions.map((session) {
                      final formattedDate = '${session.startTime.day}/${session.startTime.month}/${session.startTime.year}';
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                          child: const Icon(Icons.mic, color: Color(0xFF2A5CFF)),
                        ),
                        title: Text(session.examinerMode.displayName),
                        subtitle: Text(formattedDate),
                        trailing: Text(
                          '${session.scorePercentage.toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _viewDetailedReport();
                        },
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeakAreasDialog() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final weakTopics = _getWeakTopics(sessionProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Areas to Improve',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (weakTopics.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('No weak areas identified! Keep up the good work!'),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: weakTopics.map((topic) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(topic['topic']),
                        trailing: Text(
                          '${topic['score']}%',
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  authProvider.userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.userFullName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              authProvider.userEmail,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateToProfileSetup(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateToSettings(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.signOut();
                if (context.mounted) {
                  AppRoutes.clearAndNavigateToLogin(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
