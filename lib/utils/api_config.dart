import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // ✅ YOUR COMPUTER'S IP ADDRESS
  static const String _computerIp = '192.168.100.133';  // ← Your IP
  static const String _port = '8080';

  static String get baseUrl {
    // Web
    if (kIsWeb) {
      return 'http://localhost:$_port';
    }

    // Android Emulator
    if (Platform.isAndroid) {
      // Check if running on emulator
      return 'http://10.0.2.2:$_port';
    }

    // iOS Simulator
    if (Platform.isIOS) {
      return 'http://localhost:$_port';
    }

    // Physical Device (Mobile) - Use computer's IP
    return 'http://$_computerIp:$_port';
  }

  static String get chatEndpoint => '$baseUrl/api/chat';
}