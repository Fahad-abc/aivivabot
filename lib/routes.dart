import 'package:flutter/material.dart';
import 'package:aivivabot/screens/splash_screen.dart';
import 'package:aivivabot/screens/onboarding/onboarding_screen.dart';
import 'package:aivivabot/screens/auth/login_screen.dart';
import 'package:aivivabot/screens/auth/profile_setup_screen.dart';
import 'package:aivivabot/screens/auth/signup_screen.dart';
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
import 'package:aivivabot/screens/quiz/quiz_type_selection_screen.dart';
import 'package:aivivabot/screens/quiz/quiz_screen.dart';
import 'package:aivivabot/screens/notes/notes_screen.dart';  // ✅ ADDED

// ============================================================
// APP ROUTES - Navigation Routes Configuration
// ============================================================

class AppRoutes {
  // Route Names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String profileSetup = '/profile-setup';
  static const String dashboard = '/dashboard';
  static const String examinerSelection = '/examiner-selection';
  static const String documentUpload = '/document-upload';
  static const String vivaSession = '/viva-session';
  static const String pauseMenu = '/pause-menu';
  static const String sessionComplete = '/session-complete';
  static const String detailedReport = '/detailed-report';
  static const String weakAreas = '/weak-areas';
  static const String progressOverTime = '/progress-over-time';
  static const String settings = '/settings';
  static const String help = '/help';

  // Quiz Routes
  static const String quizTypeSelection = '/quiz-type-selection';
  static const String quiz = '/quiz';

  // Notes Route (NEW)
  static const String notes = '/notes';

  // Route Map
  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      onboarding: (context) => const OnboardingScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignUpScreen(),
      profileSetup: (context) => const ProfileSetupScreen(),
      dashboard: (context) => const DashboardScreen(),
      examinerSelection: (context) => const ExaminerSelectionScreen(),
      documentUpload: (context) => const FypDocumentUploadScreen(),
      vivaSession: (context) => const VivaSessionScreen(),
      pauseMenu: (context) => const PauseMenuScreen(),
      sessionComplete: (context) => const SessionCompleteScreen(),
      detailedReport: (context) => const DetailedReportScreen(),
      weakAreas: (context) => const WeakAreasAnalysisScreen(),
      progressOverTime: (context) => const ProgressOverTimeScreen(),
      settings: (context) => const SettingsScreen(),
      help: (context) => const HelpTutorialScreen(),
      quizTypeSelection: (context) => const QuizTypeSelectionScreen(),
      notes: (context) => const NotesScreen(),  // ✅ ADDED
    };
  }

  // onGenerateRoute for passing arguments to QuizScreen
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case quiz:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => QuizScreen(
            quizType: args?['quizType'] ?? 'short',
            questionCount: args?['questionCount'] ?? 10,
            documentContent: args?['documentContent'] ?? '',
          ),
        );
      default:
        return null;
    }
  }

  // ============================================================
  // NAVIGATION HELPER METHODS
  // ============================================================

  static void navigateToSplash(BuildContext context) {
    Navigator.pushReplacementNamed(context, splash);
  }

  static void navigateToOnboarding(BuildContext context) {
    Navigator.pushReplacementNamed(context, onboarding);
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, login);
  }

  static void navigateToProfileSetup(BuildContext context) {
    Navigator.pushReplacementNamed(context, profileSetup);
  }

  static void navigateToSignUp(BuildContext context) {
    Navigator.pushReplacementNamed(context, signup);
  }

  static void navigateToDashboard(BuildContext context) {
    Navigator.pushReplacementNamed(context, dashboard);
  }

  static void navigateToExaminerSelection(BuildContext context) {
    Navigator.pushNamed(context, examinerSelection);
  }

  static void navigateToDocumentUpload(BuildContext context) {
    Navigator.pushNamed(context, documentUpload);
  }

  static void navigateToVivaSession(BuildContext context, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(context, vivaSession, arguments: arguments);
  }

  static void navigateToPauseMenu(BuildContext context) {
    Navigator.pushNamed(context, pauseMenu);
  }

  static void navigateToSessionComplete(BuildContext context, {Map<String, dynamic>? arguments}) {
    Navigator.pushReplacementNamed(context, sessionComplete, arguments: arguments);
  }

  static void navigateToDetailedReport(BuildContext context, {Map<String, dynamic>? arguments}) {
    Navigator.pushNamed(context, detailedReport, arguments: arguments);
  }

  static void navigateToWeakAreas(BuildContext context) {
    Navigator.pushNamed(context, weakAreas);
  }

  static void navigateToProgressOverTime(BuildContext context) {
    Navigator.pushNamed(context, progressOverTime);
  }

  static void navigateToSettings(BuildContext context) {
    Navigator.pushNamed(context, settings);
  }

  static void navigateToHelp(BuildContext context) {
    Navigator.pushNamed(context, help);
  }

  // ============================================================
  // QUIZ NAVIGATION METHODS
  // ============================================================

  static void navigateToQuizTypeSelection(BuildContext context) {
    Navigator.pushNamed(context, quizTypeSelection);
  }

  static Future<void> navigateToQuiz(
      BuildContext context, {
        required String quizType,
        required int questionCount,
        required String documentContent,
      }) async {
    await Navigator.pushNamed(
      context,
      quiz,
      arguments: {
        'quizType': quizType,
        'questionCount': questionCount,
        'documentContent': documentContent,
      },
    );
  }

  // ============================================================
  // NOTES NAVIGATION METHOD (NEW)
  // ============================================================

  static void navigateToNotes(BuildContext context) {
    Navigator.pushNamed(context, notes);
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void goBackWithResult(BuildContext context, dynamic result) {
    Navigator.pop(context, result);
  }

  static void clearAndNavigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, login, (route) => false);
  }

  static void clearAndNavigateToDashboard(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, dashboard, (route) => false);
  }
}