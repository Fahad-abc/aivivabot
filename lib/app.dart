import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/providers/report_provider.dart';
import 'package:aivivabot/providers/settings_provider.dart';
import 'package:aivivabot/screens/onboarding/onboarding_screen.dart';
import 'package:aivivabot/screens/auth/login_screen.dart';
import 'package:aivivabot/screens/auth/signup_screen.dart';
import 'package:aivivabot/screens/auth/profile_setup_screen.dart';
import 'package:aivivabot/screens/dashboard/dashboard_screen.dart';
import 'package:aivivabot/screens/examiner/examiner_selection_screen.dart';
import 'package:aivivabot/screens/document/fyp_document_upload_screen.dart';
import 'package:aivivabot/screens/viva/viva_session_screen.dart';
import 'package:aivivabot/screens/viva/pause_menu_screen.dart';
import 'package:aivivabot/screens/viva/session_complete_screen.dart';
import 'package:aivivabot/screens/report/detailed_report_screen.dart';
import 'package:aivivabot/screens/report/weak_areas_analysis_screen.dart';
import 'package:aivivabot/screens/report/progress_over_time_screen.dart';
import 'package:aivivabot/screens/settings/settings_screen.dart';
import 'package:aivivabot/screens/help/help_tutorial_screen.dart';
import 'package:aivivabot/theme/app_theme.dart';

class VivaBotApp extends StatelessWidget {
  const VivaBotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'AI VivaBot',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settingsProvider.themeMode,
            initialRoute: '/onboarding',
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignUpScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
              '/dashboard': (context) => const DashboardScreen(),
              '/examiner-selection': (context) => const ExaminerSelectionScreen(),
              '/document-upload': (context) => const FypDocumentUploadScreen(),
              '/viva-session': (context) => const VivaSessionScreen(),
              '/pause-menu': (context) => const PauseMenuScreen(),
              '/session-complete': (context) => const SessionCompleteScreen(),
              '/detailed-report': (context) => const DetailedReportScreen(),
              '/weak-areas': (context) => const WeakAreasAnalysisScreen(),
              '/progress-over-time': (context) => const ProgressOverTimeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/help': (context) => const HelpTutorialScreen(),
            },
          );
        },
      ),
    );
  }
}