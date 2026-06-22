import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// HELP & TUTORIAL SCREEN - Advanced Professional Interface
// ============================================================

class HelpTutorialScreen extends StatefulWidget {
  const HelpTutorialScreen({super.key});

  @override
  State<HelpTutorialScreen> createState() => _HelpTutorialScreenState();
}

class _HelpTutorialScreenState extends State<HelpTutorialScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['Getting Started', 'FAQs', 'Tips', 'Contact'];

  final List<FaqItem> _faqs = [
    FaqItem(
      question: 'How do I start a viva session?',
      answer: 'Tap on "Start New Viva" from the dashboard, choose your examiner mode, adjust session settings, and tap "Start Viva". The AI examiner will begin asking questions.',
    ),
    FaqItem(
      question: 'Can I use voice instead of typing?',
      answer: 'Yes! VivaBot supports voice input. Just tap the microphone button and speak your answer naturally. The app will convert your speech to text.',
    ),
    FaqItem(
      question: 'What happens if I don\'t know an answer?',
      answer: 'You can ask for a hint, or the AI will provide guidance. After the session, you\'ll see the ideal answer so you can learn from it.',
    ),
    FaqItem(
      question: 'How is my performance evaluated?',
      answer: 'AI evaluates your answers based on technical accuracy, communication clarity, and confidence. You receive scores and personalized feedback.',
    ),
    FaqItem(
      question: 'Can I upload my FYP document?',
      answer: 'Yes! Upload your proposal or report to get custom questions tailored specifically to your project.',
    ),
    FaqItem(
      question: 'Is my data saved?',
      answer: 'Yes, all your sessions and reports are saved locally on your device. You can review your history anytime.',
    ),
  ];

  final List<TipItem> _tips = [
    TipItem(
      title: 'Practice Daily',
      description: 'Consistent practice improves confidence. Try to complete at least one viva session every day.',
      icon: Icons.calendar_today,
      color: Color(0xFF2A5CFF),
    ),
    TipItem(
      title: 'Review Ideal Answers',
      description: 'After each session, carefully review the ideal answers to understand what you missed.',
      icon: Icons.assignment_turned_in,
      color: Color(0xFF4CAF50),
    ),
    TipItem(
      title: 'Use Different Examiners',
      description: 'Switch between examiner modes to prepare for any type of viva questioning style.',
      icon: Icons.swap_horiz,
      color: Color(0xFFFF9800),
    ),
    TipItem(
      title: 'Focus on Weak Areas',
      description: 'Check your weak areas report and practice those topics specifically.',
      icon: Icons.trending_up,
      color: Color(0xFFF44336),
    ),
    TipItem(
      title: 'Speak Clearly',
      description: 'Enunciate your words clearly for better voice recognition accuracy.',
      icon: Icons.mic,
      color: Color(0xFF9C27B0),
    ),
    TipItem(
      title: 'Take Notes',
      description: 'Keep a notebook handy to jot down key points from ideal answers.',
      icon: Icons.note_add,
      color: Color(0xFF00BCD4),
    ),
  ];

  final List<ContactOption> _contactOptions = [
    ContactOption(
      title: 'Email Support',
      subtitle: 'Get response within 24 hours',
      icon: Icons.email_outlined,
      color: Color(0xFF2A5CFF),
      action: 'support@aivivabot.com',
      isEmail: true,
    ),
    ContactOption(
      title: 'Report an Issue',
      subtitle: 'Help us improve VivaBot',
      icon: Icons.bug_report_outlined,
      color: Color(0xFFF44336),
      action: 'Report Issue',
      isEmail: false,
    ),
    ContactOption(
      title: 'Feature Request',
      subtitle: 'Suggest new features',
      icon: Icons.lightbulb_outline,
      color: Color(0xFFFFB800),
      action: 'Request Feature',
      isEmail: false,
    ),
    ContactOption(
      title: 'Rate the App',
      subtitle: 'Share your feedback on Play Store',
      icon: Icons.star_outline,
      color: Color(0xFF4CAF50),
      action: 'Rate Now',
      isEmail: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
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
                _buildTabBar(isDark),
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
                            if (_selectedTab == 0) _buildGettingStartedSection(isDark),
                            if (_selectedTab == 1) _buildFaqSection(isDark),
                            if (_selectedTab == 2) _buildTipsSection(isDark),
                            if (_selectedTab == 3) _buildContactSection(isDark),
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
                  'Help & Tutorial',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                  ),
                ),
                Text(
                  'Learn how to use VivaBot effectively',
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

  Widget _buildTabBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
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
                    _tabs[index],
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

  Widget _buildGettingStartedSection(bool isDark) {
    final steps = [
      {'icon': Icons.person_add, 'title': 'Create Profile', 'desc': 'Set up your profile and FYP information'},
      {'icon': Icons.upload_file, 'title': 'Upload Document', 'desc': 'Upload your FYP report for custom questions'},
      {'icon': Icons.psychology, 'title': 'Choose Examiner', 'desc': 'Select your preferred examiner mode'},
      {'icon': Icons.mic, 'title': 'Start Viva', 'desc': 'Answer questions using voice or text'},
      {'icon': Icons.analytics, 'title': 'Review Report', 'desc': 'Check your performance and weak areas'},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2A5CFF),
                const Color(0xFF7000FF),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2A5CFF).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(Icons.school, color: Colors.white, size: 50),
              const SizedBox(height: 16),
              Text(
                'Welcome to VivaBot!',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your AI-powered viva preparation assistant',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Quick Start Guide',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0A0E27),
          ),
        ),
        const SizedBox(height: 16),
        ...steps.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final step = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1F3E).withOpacity(0.8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[200]!,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A5CFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A5CFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF0A0E27),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['desc'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: (isDark ? Colors.amber : Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.video_library,
                color: isDark ? Colors.amber[300] : Colors.blue[700],
                size: 30,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Demo Video',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.amber[300] : Colors.blue[700],
                      ),
                    ),
                    Text(
                      'See VivaBot in action',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_filled,
                color: isDark ? Colors.amber[300] : Colors.blue[700],
                size: 40,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSection(bool isDark) {
    return Column(
      children: [
        Container(
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
            children: _faqs.map((faq) => _buildFaqItem(faq, isDark)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqItem(FaqItem faq, bool isDark) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : const Color(0xFF0A0E27),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipsSection(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: _tips.length,
      itemBuilder: (context, index) {
        final tip = _tips[index];
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
                  : Colors.grey[200]!,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: tip.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tip.icon, color: tip.color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                tip.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                tip.description,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactSection(bool isDark) {
    return Column(
      children: [
        ..._contactOptions.map((option) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F3E).withOpacity(0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[200]!,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: option.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: option.color, size: 24),
            ),
            title: Text(
              option.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
            ),
            subtitle: Text(
              option.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
            onTap: () => _handleContact(option, isDark),
          ),
        )),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF2A5CFF).withOpacity(0.1),
                const Color(0xFF7000FF).withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.favorite,
                color: isDark ? Colors.pink[300] : Colors.pink[400],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Love VivaBot? Rate us 5 stars and help others prepare for their viva!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleContact(ContactOption option, bool isDark) {
    if (option.isEmail) {
      Clipboard.setData(ClipboardData(text: option.action));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email copied: ${option.action}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${option.action} feature coming soon!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class FaqItem {
  final String question;
  final String answer;

  FaqItem({required this.question, required this.answer});
}

class TipItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TipItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ContactOption {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String action;
  final bool isEmail;

  ContactOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.action,
    required this.isEmail,
  });
}