import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/routes.dart';

// ============================================================
// ONBOARDING SCREEN - Very Beautiful & Professional Interface
// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Master Your Viva',
      description: 'Practice with AI-powered examiners that simulate real viva questions and follow-ups.',
      icon: Icons.psychology,
      gradientColors: [Color(0xFF2A5CFF), Color(0xFF4A7CFF)],
      secondaryColor: Color(0xFF2A5CFF),
    ),
    OnboardingData(
      title: 'Voice Conversation',
      description: 'Speak naturally and get real-time feedback. Our AI listens and evaluates your answers.',
      icon: Icons.mic,
      gradientColors: [Color(0xFF00E096), Color(0xFF2A5CFF)],
      secondaryColor: Color(0xFF00E096),
    ),
    OnboardingData(
      title: 'Learn from Mistakes',
      description: 'Review AI-generated ideal answers after each session to improve your knowledge.',
      icon: Icons.auto_awesome,
      gradientColors: [Color(0xFFFFB800), Color(0xFFFF3B5C)],
      secondaryColor: Color(0xFFFFB800),
    ),
    OnboardingData(
      title: 'Track Your Progress',
      description: 'Monitor your performance with detailed reports and weak area analysis.',
      icon: Icons.trending_up,
      gradientColors: [Color(0xFF7000FF), Color(0xFF2A5CFF)],
      secondaryColor: Color(0xFF7000FF),
    ),
  ];

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
    _pageController.dispose();
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
                _buildSkipButton(isDark),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                      HapticFeedback.lightImpact();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(
                        data: _pages[index],
                        isDark: isDark,
                      );
                    },
                  ),
                ),
                _buildBottomSection(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Align(
        alignment: Alignment.topRight,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: TextButton(
            onPressed: () => AppRoutes.navigateToLogin(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : const Color(0xFF2A5CFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isDark) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: _currentPage == index ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: _currentPage == index
                      ? LinearGradient(
                    colors: _pages[index].gradientColors,
                  )
                      : null,
                  color: _currentPage == index
                      ? null
                      : (isDark ? Colors.grey[800] : Colors.grey[300]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next/Get Started Button
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: _pages[_currentPage].gradientColors,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _pages[_currentPage].secondaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  if (isLastPage) {
                    AppRoutes.navigateToLogin(context);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: Text(
                  isLastPage ? 'Get Started' : 'Next',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ONBOARDING DATA MODEL
// ============================================================

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color secondaryColor;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.secondaryColor,
  });
}

// ============================================================
// ONBOARDING PAGE WIDGET - FIXED OVERFLOW
// ============================================================

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final bool isDark;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SingleChildScrollView(  // ✅ ADDED - Fixes overflow error
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Icon Container
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 160,  // ✅ Reduced from 180 to 160
                    height: 160, // ✅ Reduced from 180 to 160
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: data.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: data.secondaryColor.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      data.icon,
                      size: 75, // ✅ Reduced from 85 to 75
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32), // ✅ Reduced from 48 to 32

            // Title
            // Title
            Text(
              data.title,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16), // ✅ Reduced from 20 to 16

            // Description
            Text(
              data.description,
              style: TextStyle(
                fontSize: 14, // ✅ Reduced from 16 to 14
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24), // ✅ Reduced from 40 to 24

            // Features List (only show on last page)
            if (data.title == 'Track Your Progress')
              _buildFeaturesList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList(bool isDark) {
    final features = [
      {'icon': Icons.check_circle, 'text': 'AI-powered questioning'},
      {'icon': Icons.check_circle, 'text': 'Real-time voice feedback'},
      {'icon': Icons.check_circle, 'text': 'Detailed performance reports'},
      {'icon': Icons.check_circle, 'text': 'Personalized recommendations'},
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16), // ✅ Reduced from 20 to 16
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4), // ✅ Reduced from 6 to 4
            child: Row(
              children: [
                Icon(
                  feature['icon'] as IconData,
                  color: const Color(0xFF2A5CFF),
                  size: 16, // ✅ Reduced from 18 to 16
                ),
                const SizedBox(width: 12),
                Text(
                  feature['text'] as String,
                  style: TextStyle(
                    fontSize: 12, // ✅ Reduced from 13 to 12
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}