import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../utils/roman_urdu_mapping.dart';

class TextToSpeechService {
  static final TextToSpeechService _instance = TextToSpeechService._internal();
  factory TextToSpeechService() => _instance;
  TextToSpeechService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  bool _isSpeaking = false;
  bool _isInitialized = false;
  String _currentLanguage = 'en-US';
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;

  // Getters
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  // Initialize TTS
  Future<void> init({String language = 'en-US'}) async {
    if (_isInitialized) return;

    _currentLanguage = language;

    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    // Set completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });

    // Set error handler
    _flutterTts.setErrorHandler((msg) {
      if (kDebugMode) {
        print('TTS Error: $msg');
      }
      _isSpeaking = false;
    });

    // Set start handler
    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
    });

    _isInitialized = true;
    if (kDebugMode) {
      print('✅ TTS initialized with language: $language');
    }
  }

  // Speak text - with Roman Urdu to Urdu script conversion
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    if (!_isInitialized) {
      await init(language: _currentLanguage);
    }

    // Stop any ongoing speech
    if (_isSpeaking) {
      await stop();
    }

    String textToSpeak = text;

    // Convert Roman Urdu to Urdu script if language is Urdu
    if (_currentLanguage == 'ur-PK') {
      textToSpeak = RomanUrduConverter.convert(text);
      if (kDebugMode) {
        print(' Converted: "$text" → "$textToSpeak"');
      }
    }

    if (kDebugMode) {
      print(' 🔊 TTS Speaking: $textToSpeak');
    }
    await _flutterTts.speak(textToSpeak);
  }

  // Stop speaking
  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  // Pause speaking
  Future<void> pause() async {
    if (_isSpeaking) {
      await _flutterTts.pause();
    }
  }

  Future<void> resume() async {
    await _flutterTts.speak('');
  }

  // Set language
  Future<void> setLanguage(String language) async {
    _currentLanguage = language;
    await _flutterTts.setLanguage(language);
  }

  // Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  // Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  // Get available voices
  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }

  // Set voice by identifier
  Future<void> setVoice(String voiceId) async {
    await _flutterTts.setVoice({"id": voiceId});
  }

  // Check if language is available
  Future<bool> isLanguageAvailable(String language) async {
    final languages = await _flutterTts.getLanguages;
    return (languages as List).contains(language);
  }

  // Dispose
  Future<void> dispose() async {
    await _flutterTts.stop();
    // In current flutter_tts, these return void and are not Futures.
    _flutterTts.setCompletionHandler(() {});
    _flutterTts.setErrorHandler((_) {});
  }
}
