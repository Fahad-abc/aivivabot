import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aivivabot/providers/session_provider.dart';
import 'package:aivivabot/models/session_model.dart';
import 'package:aivivabot/routes.dart';
import 'pause_menu_screen.dart';

// ============================================================
// VIVA SESSION SCREEN - With Speech-to-Text + Text-to-Speech
// ============================================================

class VivaSessionScreen extends StatefulWidget {
  const VivaSessionScreen({super.key, this.sessionConfig});

  final Map<String, dynamic>? sessionConfig;

  @override
  State<VivaSessionScreen> createState() => _VivaSessionScreenState();
}

class _VivaSessionScreenState extends State<VivaSessionScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isSubmitting = false;
  String _liveTranscript = "";
  bool _speechAvailable = false;
  String _selectedLocale = 'en_US';
  bool _isNavigating = false;
  bool _isLoading = true;
  String _documentContent = '';
  String _projectTitle = 'FYP Project';

  // Timer related
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDocumentContent();
    _initSpeech();
    _loadSession();
    _startTimer();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.repeat(reverse: true);
  }

  Future<void> _loadDocumentContent() async {
    final prefs = await SharedPreferences.getInstance();
    final doc = prefs.getString('documentContent') ?? '';
    final docName = prefs.getString('documentName') ?? 'FYP Project';

    print('📄 ===== VIVA SESSION =====');
    print('📄 Document Name: $docName');
    print('📄 Document Length: ${doc.length}');
    print('📄 First 300 chars: ${doc.substring(0, doc.length > 300 ? 300 : doc.length)}');
    print('📄 =========================');

    setState(() {
      _documentContent = doc.isNotEmpty ? doc : 'Flutter is a UI toolkit for building cross-platform apps.';
      _projectTitle = docName;
    });
  }

  void _loadSession() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    if (sessionProvider.currentSession == null) {
      sessionProvider.createSession(
        examinerMode: 'mixed',
        durationMinutes: 10,
        totalQuestions: 5,
      ).then((_) {
        if (mounted) {
          sessionProvider.startSession().then((_) {
            // ✅ Pass document content to session provider for question generation
            if (_documentContent.isNotEmpty) {
              sessionProvider.setDocumentContent(_documentContent);
            }
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
        }
      });
    } else if (sessionProvider.currentSession?.status == SessionStatus.notStarted) {
      sessionProvider.startSession().then((_) {
        if (_documentContent.isNotEmpty) {
          sessionProvider.setDocumentContent(_documentContent);
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      if (_documentContent.isNotEmpty) {
        sessionProvider.setDocumentContent(_documentContent);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final durationMinutes = sessionProvider.currentSession?.durationMinutes ?? 10;
    _remainingSeconds = durationMinutes * 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds <= 0 && mounted) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Time is up!')),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    if (_isListening) {
      _speech.stop();
    }
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechAvailable = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'notListening' && _isListening) {
          if (mounted) {
            setState(() {
              _isListening = false;
            });
          }
        }
      },
      onError: (error) {
        print('Speech error: $error');
        if (mounted) {
          setState(() {
            _isListening = false;
          });
        }
      },
    );

    if (!mounted) return;

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    final currentLanguage = sessionProvider.currentLanguage;

    final locales = await _speech.locales();
    print('Available locales: ${locales.map((l) => l.localeId).toList()}');

    if (currentLanguage == 'roman_urdu') {
      final hasUrdu = locales.any((l) => l.localeId.contains('ur') || l.localeId.contains('urd') || l.localeId == 'ur_PK');
      if (hasUrdu) {
        _selectedLocale = 'ur_PK';
        print('Using Urdu locale for speech recognition');
      } else {
        _selectedLocale = 'en_US';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Roman Urdu speech recognition not available. Using English.')),
          );
        }
      }
    } else {
      _selectedLocale = 'en_US';
      print('Using English locale for speech recognition');
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final sessionProvider = Provider.of<SessionProvider>(context);
    final currentSession = sessionProvider.currentSession;

    if (currentSession == null || _isLoading) {
      return _buildLoadingScreen(isDark);
    }

    final scorePercentage = sessionProvider.scorePercentage;
    final currentQuestionNumber = sessionProvider.currentQuestionNumber;
    final totalQuestions = sessionProvider.totalQuestions;
    final isAISpeaking = sessionProvider.isAISpeaking;
    final isSubmitting = sessionProvider.isLoading || _isSubmitting;

    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

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
                _buildTopBar(isDark, scorePercentage, minutes, seconds, currentQuestionNumber, totalQuestions),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildAISpeakerSection(isDark, isAISpeaking),
                        const SizedBox(height: 30),
                        _buildUserAnswerSection(isDark, isSubmitting),
                        const SizedBox(height: 30),
                        _buildActionButtons(isDark, isSubmitting),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(bool isDark) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0A0E27), const Color(0xFF1A1F3E)]
                : [const Color(0xFFF5F7FF), const Color(0xFFE8ECFF)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF2A5CFF),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _isLoading ? 'Generating Question...' : 'Loading Session...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'AI is analyzing your document',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark, double scorePercentage, int minutes, int seconds, int currentQ, int totalQ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.9)
            : Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2A5CFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${scorePercentage.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A5CFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00E096).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Q$currentQ/$totalQ',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF00E096),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB800).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _showPauseMenu(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.pause,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAISpeakerSection(bool isDark, bool isAISpeaking) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isAISpeaking ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A5CFF), Color(0xFF7000FF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2A5CFF).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isAISpeaking
                ? const Color(0xFF2A5CFF).withOpacity(0.1)
                : Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isAISpeaking ? const Color(0xFF2A5CFF) : Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isAISpeaking ? 'AI Examiner is speaking...' : 'Listening for your answer',
                style: TextStyle(
                  fontSize: 12,
                  color: isAISpeaking ? const Color(0xFF2A5CFF) : Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1A1F3E).withOpacity(0.8)
                : Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : const Color(0xFF2A5CFF).withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A5CFF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.question_mark,
                      color: Color(0xFF2A5CFF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Question ${_getCurrentQuestionNumber()}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _getCurrentQuestionText(),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0A0E27),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAnswerSection(bool isDark, bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A1F3E).withOpacity(0.8)
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : const Color(0xFF00E096).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E096).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mic,
                  color: Color(0xFF00E096),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Answer',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const Spacer(),
              if (_isListening)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Recording',
                        style: TextStyle(color: Colors.red, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              if (isSubmitting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0A0E27).withOpacity(0.6)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey[200]!,
              ),
            ),
            child: _isListening
                ? Column(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 30 + (_pulseAnimation.value * 5),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  _liveTranscript.isEmpty ? 'Listening...' : _liveTranscript,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0A0E27),
                    fontStyle: _liveTranscript.isEmpty ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : Text(
              _liveTranscript.isEmpty
                  ? 'Tap the microphone to answer'
                  : _liveTranscript,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF0A0E27),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, bool isSubmitting) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    final remainingHints = sessionProvider.remainingHints;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleListening,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _isListening
                    ? Colors.red
                    : const Color(0xFF2A5CFF),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : const Color(0xFF2A5CFF)).withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isListening ? 'Stop' : 'Speak',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: remainingHints > 0 && !isSubmitting ? _requestHint : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFFFB800),
              side: const BorderSide(color: Color(0xFFFFB800)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  remainingHints > 0 ? 'Hint ($remainingHints)' : 'No Hints',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isListening || isSubmitting ? null : _submitAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E096),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send, size: 20),
                SizedBox(width: 8),
                Text(
                  'Submit',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available on this device')),
        );
      }
      return;
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() {
          _isListening = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _liveTranscript = '';
        });
      }

      final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
      final currentLanguage = sessionProvider.currentLanguage;

      String localeId = 'en_US';
      if (currentLanguage == 'roman_urdu') {
        localeId = 'ur_PK';
      }

      print('Starting speech recognition with locale: $localeId');

      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _liveTranscript = result.recognizedWords;
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        ),
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        localeId: localeId,
      );

      if (mounted) {
        setState(() {
          _isListening = true;
        });
      }
    }
  }

  void _requestHint() async {
    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.requestHint();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hint requested!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _submitAnswer() async {
    if (_liveTranscript.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please speak your answer first'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (_isNavigating) {
      print('Already navigating, ignoring submit');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
    await sessionProvider.submitAnswer(_liveTranscript);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _liveTranscript = "";
      });

      if (!sessionProvider.hasMoreQuestions && !_isNavigating) {
        _isNavigating = true;
        _timer?.cancel();
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          AppRoutes.navigateToSessionComplete(context);
        }
      }
    }
  }

  void _showPauseMenu() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PauseMenuScreen(),
    ).then((result) {
      if (result == 'resume') {
        // Resume session
      } else if (result == 'hint') {
        _requestHint();
      } else if (result == 'end') {
        _timer?.cancel();
        AppRoutes.navigateToSessionComplete(context);
      }
    });
  }

  int _getCurrentQuestionNumber() {
    final sessionProvider = Provider.of<SessionProvider>(context);
    return sessionProvider.currentQuestionNumber;
  }

  String _getCurrentQuestionText() {
    final sessionProvider = Provider.of<SessionProvider>(context);
    return sessionProvider.currentQuestionText ?? '';
  }
}