import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/routes.dart';  // ✅ ADD THIS - for AppRoutes
import 'package:aivivabot/screens/splash_screen.dart';
import 'package:aivivabot/screens/onboarding/onboarding_screen.dart';
import 'package:aivivabot/screens/auth/login_screen.dart';
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
import 'package:aivivabot/screens/quiz/quiz_type_selection_screen.dart';
import 'package:aivivabot/screens/quiz/quiz_screen.dart';

import 'package:aivivabot/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized: $e');
    } else {
      rethrow;
    }
  }

  print('🔥 Firebase initialized successfully!');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
      ],
      child: MaterialApp(
        title: 'AI VivaBot',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,  // ✅ USING AppRoutes
        routes: AppRoutes.routes,        // ✅ USING AppRoutes
        onGenerateRoute: AppRoutes.onGenerateRoute,  // ✅ ADD THIS - for Quiz navigation with arguments
      ),
    );
  }
}