import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class SpeechToTextService extends ChangeNotifier {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isAvailable = false;
  bool _isListening = false;
  bool _isPermanentlyDisabled = false;
  String _lastWords = '';
  double _soundLevel = 0.0;
  String _status = 'Initializing...';
  String _localeId = 'en_US';
  List<stt.LocaleName> _availableLocales = [];

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  bool get isPermanentlyDisabled => _isPermanentlyDisabled;
  String get lastWords => _lastWords;
  double get soundLevel => _soundLevel;
  String get status => _status;
  List<stt.LocaleName> get availableLocales => _availableLocales;
  String get localeId => _localeId;

  // Initialize Speech Recognition
  Future<bool> initialize() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );

      if (_isAvailable) {
        _availableLocales = await _speech.locales();
        _status = 'Ready';
      } else {
        _status = 'Speech recognition not available';
      }

      notifyListeners();
      return _isAvailable;
    } catch (e) {
      _status = 'Initialization error: $e';
      _isAvailable = false;
      notifyListeners();
      return false;
    }
  }

  // Start listening
  Future<void> startListening({
    String? localeId,
    Function(String)? onResult,
    Function(String)? onError,
  }) async {
    if (!_isAvailable) {
      _status = 'Speech recognition not available';
      if (onError != null) onError(_status);
      return;
    }

    if (_isListening) {
      await stopListening();
    }

    _lastWords = '';
    _soundLevel = 0.0;
    _status = 'Listening...';
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (result) => _onResult(result, onResult),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: localeId ?? _localeId,
        onSoundLevelChange: _onSoundLevelChange,
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
      );

      _isListening = true;
      notifyListeners();
    } catch (e) {
      _status = 'Error starting listening: $e';
      _isListening = false;
      if (onError != null) onError(_status);
      notifyListeners();
    }
  }

  // Stop listening
  Future<void> stopListening() async {
    if (!_isListening) return;

    _isListening = false;
    await _speech.stop();
    _status = 'Stopped';
    notifyListeners();
  }

  // Cancel listening
  Future<void> cancelListening() async {
    if (!_isListening) return;

    _isListening = false;
    await _speech.cancel();
    _status = 'Cancelled';
    notifyListeners();
  }

  // Clear last words
  void clearLastWords() {
    _lastWords = '';
    notifyListeners();
  }

  // Set locale
  Future<void> setLocale(String localeId) async {
    if (!_isAvailable) return;

    final isAvailable = _availableLocales.any((locale) => locale.localeId == localeId);
    if (isAvailable) {
      _localeId = localeId;
      notifyListeners();
    } else {
      _status = 'Locale $localeId not available';
      notifyListeners();
    }
  }

  // Get available locales display names
  List<Map<String, String>> getAvailableLocalesDisplay() {
    return _availableLocales.map((locale) {
      return {
        'localeId': locale.localeId,
        'name': locale.name,
      };
    }).toList();
  }

  // ============================================================
  // PRIVATE METHODS
  // ============================================================

  void _onStatus(String status) {
    if (kDebugMode) {
      print('Speech status: $status');
    }
    _status = status;

    if (status == 'notListening' && _isListening) {
      _isListening = false;
      notifyListeners();
    }

    notifyListeners();
  }

  void _onError(SpeechRecognitionError error) {
    if (kDebugMode) {
      print('Speech error: ${error.errorMsg}');
    }
    _status = 'Error: ${error.errorMsg}';
    _isListening = false;

    if (error.permanent) {
      _isPermanentlyDisabled = true;
    }

    notifyListeners();
  }

  void _onResult(SpeechRecognitionResult result, Function(String)? onResult) {
    _lastWords = result.recognizedWords;
    _status = result.finalResult ? 'Finished' : 'Listening...';

    if (result.finalResult) {
      _isListening = false;
    }

    if (onResult != null && _lastWords.isNotEmpty) {
      onResult(_lastWords);
    }

    notifyListeners();
  }

  void _onSoundLevelChange(double level) {
    _soundLevel = level;
    notifyListeners();
  }
}
