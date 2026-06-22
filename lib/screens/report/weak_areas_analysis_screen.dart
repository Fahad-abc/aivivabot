import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/models/session_model.dart';
import 'package:aivivabot/routes.dart';
import 'package:aivivabot/models/question_model.dart';

// ============================================================
// WEAK AREAS ANALYSIS SCREEN - WITH REAL DATA
// ============================================================

class WeakAreasAnalysisScreen extends StatefulWidget {
  const WeakAreasAnalysisScreen({super.key});

  @override
  State<WeakAreasAnalysisScreen> createState() => _WeakAreasAnalysisScreenState();
}

class _WeakAreasAnalysisScreenState extends State<WeakAreasAnalysisScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedFilter = 0; // 0: All, 1: Critical, 2: Moderate
  List<Map<String, dynamic>> _weakAreas = [];
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
    _analyzeWeakAreas();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _analyzeWeakAreas() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final completedSessions = sessionProvider.sessionHistory
        .where((s) => s.status == SessionStatus.completed)
        .toList();

    final Map<String, Map<String, dynamic>> topicAnalysis = {};

    for (var session in completedSessions) {
      for (var question in session.questions) {
        if (!question.isAnswered) continue;
        
        final score = question.userScore ?? 0;
        final maxScore = question.maxScore;
        final percentage = (score / maxScore) * 100;

        // Extract topic from question text (first few words or category)
        String topic = question.category.displayName;
        String shortTopic = question.text.length > 40
            ? '${question.text.substring(0, 40)}...'
            : question.text;

        if (!topicAnalysis.containsKey(topic)) {
          topicAnalysis[topic] = {
            'topic': shortTopic,
            'fullTopic': topic,
            'scores': <double>[],
            'questions': 0,
            'correctAnswers': 0,
            'mistakes': <String>[],
            'category': question.category.displayName,
          };
        }

        topicAnalysis[topic]!['scores'].add(percentage);
        topicAnalysis[topic]!['questions'] = (topicAnalysis[topic]!['questions'] as int) + 1;

        if (percentage >= 60) {
          topicAnalysis[topic]!['correctAnswers'] = (topicAnalysis[topic]!['correctAnswers'] as int) + 1;
        }

        // Collect mistakes for low scores
        if (percentage < 50) {
          (topicAnalysis[topic]!['mistakes'] as List<String>).add(question.text);
        }
      }
    }

    // Convert to list and calculate average scores
    _weakAreas = topicAnalysis.values.map((data) {
      final scores = data['scores'] as List<double>;
      final avgScore = scores.isEmpty ? 0 : scores.reduce((a, b) => a + b) / scores.length;
      final severity = avgScore < 40 ? 'critical' : (avgScore < 60 ? 'moderate' : 'mild');

      // Generate recommendations based on score
      String recommendation;
      if (avgScore < 40) {
        recommendation = 'Review fundamental concepts of ${data['fullTopic']}. Focus on understanding core principles and practice with examples.';
      } else if (avgScore < 60) {
        recommendation = 'Strengthen your knowledge in ${data['fullTopic']}. Study advanced concepts and practice more questions.';
      } else {
        recommendation = 'Good understanding but can improve further. Review edge cases and advanced scenarios.';
      }

      return {
        'topic': data['topic'],
        'fullTopic': data['fullTopic'],
        'score': avgScore.toInt(),
        'category': data['category'],
        'severity': severity,
        'questions': data['questions'],
        'correctAnswers': data['correctAnswers'],
        'mistakes': (data['mistakes'] as List<String>).take(3).toList(),
        'recommendation': recommendation,
        'resources': _getResourcesForTopic(data['fullTopic']),
      };
    }).where((area) => area['score'] < 70).toList(); // Only show weak areas (score < 70)

    // Sort by score (lowest first)
    _weakAreas.sort((a, b) => (a['score'] as int).compareTo(b['score'] as int));
  }

  List<String> _getResourcesForTopic(String topic) {
    final topicLower = topic.toLowerCase();
    if (topicLower.contains('database')) {
      return [
        '📚 Database Normalization Tutorial',
        '🎥 SQL and Database Design Course',
        '📝 Practice Database Exercises',
      ];
    } else if (topicLower.contains('flutter') || topicLower.contains('mobile')) {
      return [
        '⚡ Flutter Official Documentation',
        '📱 Flutter Performance Best Practices',
        '🎥 Widget Optimization Workshop',
      ];
    } else if (topicLower.contains('security') || topicLower.contains('api')) {
      return [
        '🔐 API Security Best Practices',
        '📖 JWT Authentication Guide',
        '🎥 OAuth2 Tutorial',
      ];
    } else if (topicLower.contains('architecture') || topicLower.contains('state')) {
      return [
        '📊 Software Architecture Patterns',
        '🎥 State Management Guide',
        '📝 Design Patterns Tutorial',
      ];
    } else {
      return [
        '📚 General Study Resources',
        '🎥 Video Tutorials',
        '📝 Practice Questions',
      ];
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredWeakAreas {
    if (_selectedFilter == 0) return _weakAreas;
    if (_selectedFilter == 1) return _weakAreas.where((w) => w['severity'] == 'critical').toList();
    if (_selectedFilter == 2) return _weakAreas.where((w) => w['severity'] == 'moderate').toList();
    return _weakAreas;
  }

  double get _averageWeakScore {
    if (_weakAreas.isEmpty) return 0;
    final total = _weakAreas.fold<int>(0, (sum, w) => sum + (w['score'] as int));
    return total / _weakAreas.length;
  }

  int get _totalCriticalAreas {
    return _weakAreas.where((w) => w['severity'] == 'critical').length;
  }

  int get _totalQuestionsInWeakAreas {
    return _weakAreas.fold<int>(0, (sum, w) => sum + (w['questions'] as int));
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

    if (_weakAreas.isEmpty) {
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
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.celebration, size: 80, color: Colors.green),
                        const SizedBox(height: 16),
                        Text(
                          'No Weak Areas Found!',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Great job! Keep up the good work.',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => AppRoutes.goBack(context),
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
                _buildStatsBar(isDark),
                _buildFilterButtons(isDark),
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
                            if (_totalCriticalAreas > 0) _buildPriorityMessage(isDark),
                            const SizedBox(height: 20),
                            ..._filteredWeakAreas.map((area) => _buildWeakAreaCard(area, isDark)),
                            const SizedBox(height: 20),
                            if (_weakAreas.isNotEmpty) _buildStudyPlanCard(isDark),
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
                  'Weak Areas Analysis',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Identify and improve your weak topics',
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

  Widget _buildStatsBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF3B5C).withValues(alpha: 0.2),
            const Color(0xFFFFB800).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF3B5C).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Weak Areas',
            value: '${_filteredWeakAreas.length}',
            icon: Icons.warning,
            color: const Color(0xFFFF3B5C),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          _buildStatItem(
            label: 'Critical',
            value: '$_totalCriticalAreas',
            icon: Icons.error,
            color: const Color(0xFFFF3B5C),
            isDark: isDark,
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[800] : Colors.grey[300],
          ),
          _buildStatItem(
            label: 'Avg Score',
            value: '${_averageWeakScore.toStringAsFixed(0)}%',
            icon: Icons.trending_down,
            color: const Color(0xFFFFB800),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
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

  Widget _buildFilterButtons(bool isDark) {
    final filters = ['All Areas', 'Critical', 'Moderate'];

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
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilter == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = index;
                });
                HapticFeedback.lightImpact();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2A5CFF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                ),
                child: Center(
                  child: Text(
                    filters[index],
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

  Widget _buildPriorityMessage(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.priority_high, color: Colors.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_totalCriticalAreas Critical Areas Need Attention',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
                Text(
                  'Focus on these topics first for quick improvement',
                  style: TextStyle(
                    fontSize: 12,
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

  Widget _buildWeakAreaCard(Map<String, dynamic> area, bool isDark) {
    final score = area['score'] as int;
    final severity = area['severity'] as String;
    final isCritical = severity == 'critical';
    final scoreColor = score >= 60 ? Colors.orange : Colors.red;
    final severityColor = isCritical ? Colors.red : Colors.orange;
    final progressValue = score / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withValues(alpha: 0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCritical
              ? Colors.red.withValues(alpha: 0.3)
              : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
        ),
        boxShadow: isCritical
            ? [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCritical
                  ? Colors.red.withValues(alpha: 0.1)
                  : (isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[100]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isCritical ? Icons.error_outline : Icons.warning_amber,
                    color: severityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area['topic'],
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                      ),
                      Text(
                        '${area['category']} • ${area['questions']} questions',
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
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$score%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mastery Level',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${(progressValue * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      color: scoreColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildStatChip(
                      label: '${area['correctAnswers']} Correct',
                      color: Colors.green,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: '${area['questions'] - area['correctAnswers']} Incorrect',
                      color: Colors.red,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if ((area['mistakes'] as List).isNotEmpty) ...[
                  Text(
                    'Questions to Review',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(area['mistakes'] as List).take(2).map((mistake) => Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, color: Colors.red, size: 6),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mistake,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                ],

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb, color: Color(0xFFFFB800), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          area['recommendation'],
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
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () => _showResourcesDialog(area, isDark),
                  child: Container(
                    padding: const EdgeInsets.all(12),
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
                    child: const Row(
                      children: [
                        Icon(Icons.menu_book, color: Color(0xFF2A5CFF), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'View Study Resources',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2A5CFF),
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF2A5CFF)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStudyPlanCard(bool isDark) {
    final topTopics = _weakAreas.take(3).toList();

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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2A5CFF).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.assignment,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalized Study Plan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Based on your weak areas analysis',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < topTopics.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPlanItem(
                day: 'Day ${i + 1}-${i + 2}',
                topic: topTopics[i]['fullTopic'],
                duration: '${2 + i} hours',
                isDark: isDark,
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2A5CFF),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Start Studying Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanItem({
    required String day,
    required String topic,
    required String duration,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  duration,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }

  void _showResourcesDialog(Map<String, dynamic> area, bool isDark) {
    final resources = area['resources'] as List;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Resources: ${area['topic']}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended learning materials to improve this topic',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ...resources.map((resource) => ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A5CFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.link, color: Color(0xFF2A5CFF), size: 18),
              ),
              title: Text(
                resource,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              trailing: const Icon(Icons.open_in_new, size: 16),
              onTap: () {
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A5CFF),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
