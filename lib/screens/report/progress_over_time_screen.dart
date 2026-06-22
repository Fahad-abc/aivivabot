import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/models/session_model.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// PROGRESS OVER TIME SCREEN - WITH REAL DATA
// ============================================================

class ProgressOverTimeScreen extends StatefulWidget {
  const ProgressOverTimeScreen({super.key});

  @override
  State<ProgressOverTimeScreen> createState() => _ProgressOverTimeScreenState();
}

class _ProgressOverTimeScreenState extends State<ProgressOverTimeScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedTimeRange = 0; // 0: Weekly, 1: Monthly, 2: Yearly

  List<Map<String, dynamic>> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
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

  Future<void> _loadData() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.loadSessionHistory();
    _updateChartData();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateChartData() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final completedSessions = sessionProvider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList()
        .reversed
        .toList();

    if (_selectedTimeRange == 0) {
      // Weekly - last 7 sessions or weeks
      _chartData = completedSessions.take(7).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final session = entry.value;
        return {
          'label': 'W${index + 1}',
          'score': session.scorePercentage.toInt(),
          'date': _formatDate(session.startTime),
          'session': session,
        };
      }).toList();
    } else if (_selectedTimeRange == 1) {
      // Monthly - group by month
      final monthlyData = <String, Map<String, dynamic>>{};
      for (var session in completedSessions) {
        final monthKey = '${session.startTime.year}-${session.startTime.month}';
        final monthName = _getMonthName(session.startTime.month);

        if (!monthlyData.containsKey(monthKey)) {
          monthlyData[monthKey] = {
            'label': monthName,
            'scores': [],
            'sessions': 0,
            'month': session.startTime.month,
            'year': session.startTime.year,
          };
        }
        monthlyData[monthKey]!['scores'].add(session.scorePercentage);
        monthlyData[monthKey]!['sessions'] = (monthlyData[monthKey]!['sessions'] as int) + 1;
      }

      _chartData = monthlyData.values.map((data) {
        final scores = data['scores'] as List<double>;
        final avgScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
        return {
          'label': data['label'],
          'score': avgScore.toInt(),
          'sessions': data['sessions'],
          'month': data['month'],
          'year': data['year'],
        };
      }).toList().reversed.take(6).toList().reversed.toList();
    } else {
      // Yearly - group by year
      final yearlyData = <String, Map<String, dynamic>>{};
      for (var session in completedSessions) {
        final yearKey = '${session.startTime.year}';

        if (!yearlyData.containsKey(yearKey)) {
          yearlyData[yearKey] = {
            'label': yearKey,
            'scores': [],
            'sessions': 0,
            'year': session.startTime.year,
          };
        }
        yearlyData[yearKey]!['scores'].add(session.scorePercentage);
        yearlyData[yearKey]!['sessions'] = (yearlyData[yearKey]!['sessions'] as int) + 1;
      }

      _chartData = yearlyData.values.map((data) {
        final scores = data['scores'] as List<double>;
        final avgScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
        return {
          'label': data['label'],
          'score': avgScore.toInt(),
          'sessions': data['sessions'],
          'year': data['year'],
        };
      }).toList().reversed.toList();
    }

    // Reverse for chronological order
    if (_selectedTimeRange != 0) {
      _chartData = _chartData.reversed.toList();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final sessionProvider = Provider.of<SessionProvider>(context);
    final completedSessions = sessionProvider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

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
                _buildTimeRangeSelector(isDark),
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
                            const SizedBox(height: 20),
                            _buildStatsSummary(isDark, completedSessions),
                            const SizedBox(height: 20),
                            if (_chartData.isNotEmpty)
                              _buildChart(isDark)
                            else
                              _buildEmptyState(isDark),
                            const SizedBox(height: 20),
                            if (_chartData.isNotEmpty)
                              _buildInsights(isDark, completedSessions),
                            const SizedBox(height: 20),
                            _buildMilestones(isDark, completedSessions.length),
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

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.insights, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No sessions completed yet',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a viva session to see your progress',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => AppRoutes.goBack(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
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
                  'Progress Over Time',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Track your viva performance journey',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRangeSelector(bool isDark) {
    final ranges = ['Weekly', 'Monthly', 'Yearly'];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: List.generate(ranges.length, (index) {
          final isSelected = _selectedTimeRange == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeRange = index;
                  _updateChartData();
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: Text(
                    ranges[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark, List<VivaSession> sessions) {
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(child: Text('No data available')),
      );
    }

    final scores = sessions.map((s) => s.scorePercentage).toList();
    final avgScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final firstScore = sessions.first.scorePercentage;
    final lastScore = sessions.last.scorePercentage;
    final improvement = lastScore - firstScore;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Average Score',
            value: '${avgScore.toInt()}%',
            icon: Icons.trending_up,
            color: const Color(0xFF2A5CFF),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Best Score',
            value: '${maxScore.toInt()}%',
            icon: Icons.emoji_events,
            color: const Color(0xFFFFB800),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Improvement',
            value: improvement >= 0 ? '+${improvement.toInt()}%' : '${improvement.toInt()}%',
            icon: improvement >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
            color: improvement >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF3B5C),
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
    required Color color,
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
              : color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0A0E27),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(bool isDark) {
    if (_chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final scores = _chartData.map((d) => d['score'] as int).toList();
    final maxScoreValue = scores.isEmpty ? 100 : scores.reduce((a, b) => a > b ? a : b);
    final minScoreValue = scores.isEmpty ? 0 : scores.reduce((a, b) => a < b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
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
                  color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.show_chart,
                  color: Color(0xFF2A5CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Performance Chart',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildYAxisLabel('100', isDark),
                    _buildYAxisLabel('75', isDark),
                    _buildYAxisLabel('50', isDark),
                    _buildYAxisLabel('25', isDark),
                    _buildYAxisLabel('0', isDark),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _chartData.asMap().entries.map((entry) {
                      final data = entry.value;
                      final score = data['score'] as int;
                      final barHeight = (score / 100) * 200;
                      final label = data['label'] as String;
                      final isHighest = score == maxScoreValue;
                      final isLowest = score == minScoreValue;

                      return Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '$score%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isHighest
                                    ? const Color(0xFFFFB800)
                                    : isLowest
                                    ? const Color(0xFFFF3B5C)
                                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: barHeight,
                              width: 30,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: isHighest
                                      ? [const Color(0xFFFFB800), const Color(0xFFFFD54F)]
                                      : [const Color(0xFF2A5CFF), const Color(0xFF7000FF)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isHighest ? const Color(0xFFFFB800) : const Color(0xFF2A5CFF)).withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYAxisLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
    );
  }

  Widget _buildInsights(bool isDark, List<VivaSession> sessions) {
    if (sessions.isEmpty || _chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final scores = _chartData.map((d) => d['score'] as int).toList();
    final bestIndex = scores.indexOf(scores.reduce((a, b) => a > b ? a : b));
    final worstIndex = scores.indexOf(scores.reduce((a, b) => a < b ? a : b));

    final bestData = _chartData[bestIndex];
    final worstData = _chartData[worstIndex];

    final firstScore = sessions.first.scorePercentage;
    final lastScore = sessions.last.scorePercentage;
    final improvement = lastScore - firstScore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2A5CFF).withValues(alpha: 0.1),
            const Color(0xFF7000FF).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2A5CFF).withValues(alpha: 0.2),
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
                  color: const Color(0xFF2A5CFF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Color(0xFF2A5CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Insights',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInsightItem(
            icon: Icons.trending_up,
            title: 'Overall Trend',
            value: improvement >= 0 ? 'Improving' : 'Needs Attention',
            subtitle: '${improvement >= 0 ? '+' : ''}${improvement.toInt()}% change',
            color: improvement >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFFF3B5C),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.emoji_events,
            title: 'Best Performance',
            value: bestData['label'],
            subtitle: 'Score: ${bestData['score']}%',
            color: const Color(0xFFFFB800),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.warning,
            title: 'Area to Improve',
            value: worstData['label'],
            subtitle: 'Score: ${worstData['score']}%',
            color: const Color(0xFFFF3B5C),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0A0E27).withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
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
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestones(bool isDark, int totalSessions) {
    final milestones = [
      {'icon': Icons.rocket_launch, 'title': 'First Session', 'achieved': totalSessions >= 1, 'color': const Color(0xFF2A5CFF)},
      {'icon': Icons.star, 'title': '5 Sessions Completed', 'achieved': totalSessions >= 5, 'color': const Color(0xFFFFB800)},
      {'icon': Icons.emoji_events, 'title': '80% Score Achieved', 'achieved': _hasHighScore(), 'color': const Color(0xFF4CAF50)},
      {'icon': Icons.psychology, 'title': '10 Sessions Completed', 'achieved': totalSessions >= 10, 'color': const Color(0xFF2A5CFF)},
      {'icon': Icons.auto_awesome, 'title': '20 Sessions Master', 'achieved': totalSessions >= 20, 'color': const Color(0xFF7000FF)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
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
                  color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.flag,
                  color: Color(0xFF2A5CFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Milestones & Achievements',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...milestones.map((milestone) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (milestone['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    milestone['icon'] as IconData,
                    color: milestone['achieved'] as bool
                        ? milestone['color'] as Color
                        : Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone['title'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: milestone['achieved'] as bool
                              ? (isDark ? Colors.white : const Color(0xFF0A0E27))
                              : (isDark ? Colors.grey[600] : Colors.grey[500]),
                        ),
                      ),
                    ],
                  ),
                ),
                if (milestone['achieved'] as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Achieved',
                          style: TextStyle(color: Colors.green, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  bool _hasHighScore() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final sessions = sessionProvider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

    for (var session in sessions) {
      if (session.scorePercentage >= 80) {
        return true;
      }
    }
    return false;
  }
}
