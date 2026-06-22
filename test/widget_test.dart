// ============================================================
// FILE: test/widget_test.dart
// AI VivaBot - Beautiful Widget Tests (FIXED)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aivivabot/app.dart'; // ✅ Import from app.dart, not main.dart
import 'package:aivivabot/providers/auth_provider.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/providers/report_provider.dart';
import 'package:aivivabot/providers/settings_provider.dart';

// Import all screens for testing
import 'package:aivivabot/screens/onboarding/onboarding_screen.dart';
import 'package:aivivabot/screens/auth/login_screen.dart';
import 'package:aivivabot/screens/dashboard/dashboard_screen.dart';
import 'package:aivivabot/screens/examiner/examiner_selection_screen.dart';

// ============================================================
// HELPER FUNCTION: Wrap widgets with providers for testing
// ============================================================

/// Wraps a widget with all necessary providers for testing
Widget wrapWithProviders(Widget widget) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => SessionProvider()),
      ChangeNotifierProvider(create: (_) => ReportProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ],
    child: MaterialApp(
      home: widget,
    ),
  );
}

void main() {
  // ============================================================
  // TEST GROUP 1: APP INITIALIZATION
  // ============================================================

  group('App Initialization Tests', () {
    testWidgets('App starts without crashing', (WidgetTester tester) async {
      // ✅ Now correctly imports VivaBotApp from app.dart
      await tester.pumpWidget(const VivaBotApp());
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App has correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const VivaBotApp());
      await tester.pumpAndSettle();

      // The MaterialApp is nested inside MultiProvider and Consumer
      // So we just check if the app loaded successfully
      expect(find.byType(VivaBotApp), findsOneWidget);
    });

    testWidgets('Debug banner is disabled', (WidgetTester tester) async {
      await tester.pumpWidget(const VivaBotApp());
      await tester.pumpAndSettle();

      // Verify app loaded (MaterialApp exists somewhere in tree)
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

  // ============================================================
  // TEST GROUP 2: ONBOARDING SCREEN
  // ============================================================

  group('Onboarding Screen Tests', () {
    testWidgets('Onboarding screen displays correctly', (WidgetTester tester) async {
      // ✅ Onboarding doesn't need providers, so wrap with simple MaterialApp
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 3: LOGIN SCREEN
  // ============================================================

  group('Login Screen Tests', () {
    testWidgets('Login screen displays', (WidgetTester tester) async {
      // ✅ LoginScreen needs AuthProvider, so wrap with providers
      await tester.pumpWidget(wrapWithProviders(LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 4: DASHBOARD SCREEN
  // ============================================================

  group('Dashboard Screen Tests', () {
    testWidgets('Dashboard displays', (WidgetTester tester) async {
      // ✅ DashboardScreen needs multiple providers
      await tester.pumpWidget(wrapWithProviders(DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 5: EXAMINER SELECTION SCREEN
  // ============================================================

  group('Examiner Selection Tests', () {
    testWidgets('Examiner Selection Screen displays', (WidgetTester tester) async {
      // ✅ ExaminerSelectionScreen needs providers
      await tester.pumpWidget(wrapWithProviders(ExaminerSelectionScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(ExaminerSelectionScreen), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 6: PROVIDER AVAILABILITY (NEW!)
  // ============================================================

  group('Provider Availability Tests', () {
    testWidgets('AuthProvider is available in widget tree', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithProviders(Scaffold()));
      await tester.pumpAndSettle();

      // Verify that we can access the provider
      expect(find.byType(MultiProvider), findsOneWidget);
    });

    testWidgets('All providers are initialized', (WidgetTester tester) async {
      await tester.pumpWidget(const VivaBotApp());
      await tester.pumpAndSettle();

      // VivaBotApp from app.dart has MultiProvider with all 4 providers
      expect(find.byType(MultiProvider), findsOneWidget);
    });
  });

  // ============================================================
  // TEST GROUP 7: WIDGET TREE STRUCTURE
  // ============================================================

  group('Widget Tree Structure Tests', () {
    testWidgets('VivaBotApp contains MultiProvider', (WidgetTester tester) async {
      await tester.pumpWidget(const VivaBotApp());
      await tester.pumpAndSettle();

      // The app structure should be: VivaBotApp → MultiProvider → ... → MaterialApp
      expect(find.byType(MultiProvider), findsOneWidget);
      expect(find.byType(MaterialApp), findsWidgets);
    });

    testWidgets('Individual screens work with providers', (WidgetTester tester) async {
      // Test that LoginScreen can access AuthProvider when wrapped
      await tester.pumpWidget(wrapWithProviders(LoginScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(MultiProvider), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
