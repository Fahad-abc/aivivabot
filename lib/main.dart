import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/providers/settings_provider.dart';
import 'package:aivivabot/routes.dart';

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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'AI VivaBot',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF5F7FF),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF5F7FF),
                elevation: 0,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFF0A0E27),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF0A0E27),
                elevation: 0,
              ),
            ),
            themeMode: settings.themeMode,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}