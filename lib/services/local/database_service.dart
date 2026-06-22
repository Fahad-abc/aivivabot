import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/session_model.dart';
import '../../models/report_model.dart';

class DatabaseService {
  static const String _sessionsKey = 'viva_sessions';
  static const String _reportsKey = 'viva_reports';

  // ============================================================
  // SESSION METHODS
  // ============================================================

  Future<void> saveSession(VivaSession session) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final sessions = jsonDecode(sessionsJson) as List<dynamic>;
      sessions.add(session.toJson());
      await prefs.setString(_sessionsKey, jsonEncode(sessions));
    } catch (e) {
      print('Error saving session: $e');
    }
  }

  Future<List<VivaSession>> getAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final sessions = jsonDecode(sessionsJson) as List<dynamic>;
      return sessions.map((s) => VivaSession.fromJson(s)).toList();
    } catch (e) {
      print('Error getting sessions: $e');
      return <VivaSession>[];
    }
  }

  Future<VivaSession?> getSessionById(String id) async {
    try {
      final sessions = await getAllSessions();
      return sessions.cast<VivaSession?>().firstWhere(
        (s) => s!.id == id,
        orElse: () => null,
      );
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }

  Future<void> deleteSession(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getString(_sessionsKey) ?? '[]';
      final sessions = jsonDecode(sessionsJson) as List<dynamic>;
      sessions.removeWhere((s) => s['id'] == id);
      await prefs.setString(_sessionsKey, jsonEncode(sessions));
    } catch (e) {
      print('Error deleting session: $e');
    }
  }

  Future<void> deleteAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionsKey);
    } catch (e) {
      print('Error deleting all sessions: $e');
    }
  }

  // ============================================================
  // REPORT METHODS
  // ============================================================

  Future<void> saveReport(VivaReport report) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString(_reportsKey) ?? '[]';
      final reports = jsonDecode(reportsJson) as List<dynamic>;
      reports.add(report.toJson());
      await prefs.setString(_reportsKey, jsonEncode(reports));
    } catch (e) {
      print('Error saving report: $e');
    }
  }

  Future<List<VivaReport>> getAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString(_reportsKey) ?? '[]';
      final reports = jsonDecode(reportsJson) as List<dynamic>;
      return reports.map((r) => VivaReport.fromJson(r)).toList();
    } catch (e) {
      print('Error getting reports: $e');
      return <VivaReport>[];
    }
  }

  Future<VivaReport?> getReportById(String id) async {
    try {
      final reports = await getAllReports();
      return reports.cast<VivaReport?>().firstWhere(
        (r) => r!.id == id,
        orElse: () => null,
      );
    } catch (e) {
      print('Error getting report: $e');
      return null;
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reportsJson = prefs.getString(_reportsKey) ?? '[]';
      final reports = jsonDecode(reportsJson) as List<dynamic>;
      reports.removeWhere((r) => r['id'] == id);
      await prefs.setString(_reportsKey, jsonEncode(reports));
    } catch (e) {
      print('Error deleting report: $e');
    }
  }

  Future<void> deleteAllReports() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_reportsKey);
    } catch (e) {
      print('Error deleting all reports: $e');
    }
  }
}
