import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// EXAMINER SELECTION SCREEN - WITH LANGUAGE SELECTION
// ============================================================

class ExaminerSelectionScreen extends StatefulWidget {
  const ExaminerSelectionScreen({super.key});

  @override
  State<ExaminerSelectionScreen> createState() => _ExaminerSelectionScreenState();
}

class _ExaminerSelectionScreenState extends State<ExaminerSelectionScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  String _selectedMode = 'strict';
  int _selectedDuration = 10;
  int _selectedHints = 3;
  bool _allowRetries = true;
  int _totalQuestions = 5;
  bool _isStarting = false;
  String _selectedLanguage = 'english'; // 'english' or 'roman_urdu'

  final List<ExaminerMode> _examinerModes = [
    ExaminerMode(
      id: 'friendly',
      name: 'Friendly Examiner',
      icon: Icons.emoji_emotions,
      description: 'Helpful hints, encouraging tone, lower pressure',
      difficulty: 'Easy',
      difficultyColor: Colors.green,
      gradient: [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
      features: ['🤝 Helpful hints', '💬 Encouraging tone', '😊 Lower pressure', '📖 Detailed explanations'],
    ),
    ExaminerMode(
      id: 'strict',
      name: 'Strict Examiner',
      icon: Icons.gavel,
      description: 'No hints, rapid follow-ups, real pressure',
      difficulty: 'Hard',
      difficultyColor: Colors.red,
      gradient: [const Color(0xFFF44336), const Color(0xFFFF5722)],
      features: ['🚫 No hints available', '⚡ Rapid follow-ups', '🎯 Real pressure', '⏱️ Strict timing'],
    ),
    ExaminerMode(
      id: 'technical',
      name: 'Technical Expert',
      icon: Icons.science,
      description: 'Deep questions, code and algorithms, industry level',
      difficulty: 'Expert',
      difficultyColor: const Color(0xFF7000FF),
      gradient: [const Color(0xFF7000FF), const Color(0xFF9C27B0)],
      features: ['🔬 Deep technical questions', '💻 Code and algorithms', '🏭 Industry level', '🎓 Research oriented'],
    ),
    ExaminerMode(
      id: 'mixed',
      name: 'Mixed Mode',
      icon: Icons.shuffle,
      description: 'Random combination of all styles',
      difficulty: 'Medium',
      difficultyColor: const Color(0xFF2A5CFF),
      gradient: [const Color(0xFF2A5CFF), const Color(0xFF2196F3)],
      features: ['🎲 Random question styles', '🔄 Adaptive difficulty', '✨ Varied experience', '🎯 Complete preparation'],
    ),
  ];

  final List<Map<String, dynamic>> _languages = [
    {'id': 'english', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
    {'id': 'roman_urdu', 'name': 'Roman Urdu', 'flag': '🇵🇰', 'native': 'رومن اردو'},
  ];

  final List<int> _durations = [5, 10, 15, 20, 30, 45, 60];
  final List<int> _hintOptions = [0, 1, 2, 3, 5];
  final List<int> _questionCountOptions = [3, 5, 7, 10, 15];

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildTitleSection(isDark),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildModesGrid(isDark),
                        ),
                        const SizedBox(height: 32),
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildSettingsCard(isDark),
                        ),
                        const SizedBox(height: 32),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildStartButton(isDark),
                        ),
                        const SizedBox(height: 40),
                      ],
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
                  'Choose Examiner',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Select your viva style and language',
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

  Widget _buildTitleSection(bool isDark) {
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
            color: const Color(0xFF2A5CFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Your Examiner',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Each examiner has a unique style and difficulty level',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModesGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _examinerModes.length,
      itemBuilder: (context, index) {
        final mode = _examinerModes[index];
        final isSelected = _selectedMode == mode.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedMode = mode.id;
            });
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: mode.gradient,
              )
                  : null,
              color: isSelected
                  ? null
                  : (isDark
                  ? const Color(0xFF1A1F3E).withOpacity(0.8)
                  : Colors.white),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark
                    ? Colors.white.withOpacity(0.1)
                    : mode.gradient.first.withOpacity(0.3)),
                width: isSelected ? 0 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: mode.gradient.first.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
                  : [],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : mode.gradient.first.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          mode.icon,
                          color: isSelected ? Colors.white : mode.gradient.first,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mode.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0A0E27)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : mode.difficultyColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          mode.difficulty,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : mode.difficultyColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white.withOpacity(0.9)
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsCard(bool isDark) {
    final selectedMode = _examinerModes.firstWhere((m) => m.id == _selectedMode);
    final selectedLanguage = _languages.firstWhere((l) => l['id'] == _selectedLanguage);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF2A5CFF).withOpacity(0.2),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF2A5CFF),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Session Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Language Setting
          _buildSettingRow(
            title: 'Language',
            icon: Icons.language,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0E27).withOpacity(0.6)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: _selectedLanguage,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  fontSize: 14,
                ),
                items: _languages.map((lang) {
                  return DropdownMenuItem(
                    value: lang['id'] as String,
                    child: Row(
                      children: [
                        Text(lang['flag'] as String),
                        const SizedBox(width: 8),
                        Text(lang['name'] as String),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ),
            isDark: isDark,
          ),

          // Question Count Setting
          _buildSettingRow(
            title: 'Total Questions',
            icon: Icons.quiz,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0E27).withOpacity(0.6)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: _totalQuestions,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  fontSize: 14,
                ),
                items: _questionCountOptions.map((count) {
                  return DropdownMenuItem(
                    value: count,
                    child: Text('$count questions'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _totalQuestions = value!;
                  });
                },
              ),
            ),
            isDark: isDark,
          ),

          // Duration Setting
          _buildSettingRow(
            title: 'Duration',
            icon: Icons.timer_outlined,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0E27).withOpacity(0.6)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: _selectedDuration,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  fontSize: 14,
                ),
                items: _durations.map((duration) {
                  return DropdownMenuItem(
                    value: duration,
                    child: Text('$duration minutes'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDuration = value!;
                  });
                },
              ),
            ),
            isDark: isDark,
          ),

          // Hints Setting
          _buildSettingRow(
            title: 'Hints Allowed',
            icon: Icons.lightbulb_outline,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0A0E27).withOpacity(0.6)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<int>(
                value: _selectedHints,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1A1F3E) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  fontSize: 14,
                ),
                items: _hintOptions.map((hints) {
                  return DropdownMenuItem(
                    value: hints,
                    child: Text(hints == 0 ? 'No hints' : '$hints hints'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedHints = value!;
                  });
                },
              ),
            ),
            isDark: isDark,
          ),

          // Retry Setting
          _buildSettingRow(
            title: 'Allow Retries',
            icon: Icons.refresh,
            child: Switch(
              value: _allowRetries,
              onChanged: (value) {
                setState(() {
                  _allowRetries = value;
                });
              },
              activeColor: const Color(0xFF2A5CFF),
            ),
            isDark: isDark,
          ),

          // Features Preview
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: selectedMode.gradient.map((c) => c.withOpacity(0.1)).toList(),
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: selectedMode.gradient.first,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selectedMode.name} Features',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selectedMode.gradient.first,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: selectedMode.features.map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: selectedMode.gradient.first.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required IconData icon,
    required Widget child,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2A5CFF), size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildStartButton(bool isDark) {
    final selectedMode = _examinerModes.firstWhere((m) => m.id == _selectedMode);
    final selectedLanguage = _languages.firstWhere((l) => l['id'] == _selectedLanguage);

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isStarting ? null : _startViva,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A5CFF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isStarting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled, color: Colors.white, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Start Viva in ${selectedLanguage['name']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startViva() async {
    setState(() {
      _isStarting = true;
    });

    try {
      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);

      // Reset any existing session
      sessionProvider.resetCurrentSession();

      // Create new session with selected settings and language
      await sessionProvider.createSession(
        examinerMode: _selectedMode,
        durationMinutes: _selectedDuration,
        totalQuestions: _totalQuestions,
        maxHintsAllowed: _selectedHints,
        allowRetries: _allowRetries,
        language: _selectedLanguage, // ✅ Pass language to session provider
      );

      // Navigate to viva session screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.vivaSession);
      }
    } catch (e) {
      print('Error starting viva: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }
}

// ============================================================
// EXAMINER MODE MODEL
// ============================================================

class ExaminerMode {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  final String difficulty;
  final Color difficultyColor;
  final List<Color> gradient;
  final List<String> features;

  ExaminerMode({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.difficulty,
    required this.difficultyColor,
    required this.gradient,
    required this.features,
  });
}