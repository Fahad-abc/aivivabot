import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Cinematic 3D animations
  late Animation<double> _cameraZoom;
  late Animation<double> _cameraRotateX;
  late Animation<double> _cameraRotateY;

  // Particle system
  late List<Particle> _particles;
  final Random _random = Random();

  // Typing animation
  String _displayText = '';
  final String _fullText = 'AI VivaBot';
  int _textIndex = 0;

  // Glow intensity
  double _glowIntensity = 0;
  bool _showFireworks = false;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _initAnimations();
    _startTypingAnimation();
    _navigateToNext();
  }

  void _initParticles() {
    _particles = [];
    for (int i = 0; i < 200; i++) {
      _particles.add(Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2 + _random.nextDouble() * 4,
        speedX: -0.02 + _random.nextDouble() * 0.04,
        speedY: -0.03 - _random.nextDouble() * 0.05,
        life: 0.2 + _random.nextDouble() * 0.8,
        color: Colors.blue,
      ));
    }
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Cinematic camera zoom
    _cameraZoom = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // 3D rotation X
    _cameraRotateX = Tween<double>(begin: 0.3, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // 3D rotation Y
    _cameraRotateY = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Glow pulse
    _controller.addListener(() {
      setState(() {
        _glowIntensity = 0.5 + sin(_controller.value * 3.14159 * 4) * 0.5;
        _updateParticles();
      });
    });

    _controller.forward();
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.x += p.speedX;
      p.y += p.speedY;
      p.life -= 0.003;

      if (p.life <= 0 || p.y < 0 || p.x < 0 || p.x > 1) {
        p.x = 0.5 + (_random.nextDouble() - 0.5) * 0.5;
        p.y = 0.8;
        p.life = 0.8;
        p.speedX = -0.03 + _random.nextDouble() * 0.06;
        p.speedY = -0.05 - _random.nextDouble() * 0.08;
      }
    }
  }

  void _startTypingAnimation() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_textIndex < _fullText.length) {
        setState(() {
          _displayText += _fullText[_textIndex];
          _textIndex++;
        });
      } else {
        timer.cancel();
        // Start fireworks effect at end
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _showFireworks = true;
          });
        });
      }
    });
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 8));
    if (mounted) {
      AppRoutes.navigateToOnboarding(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              Color(0xFF0A0A2A),
              Color(0xFF1A1A4A),
              Color(0xFF0A0A2A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 3D Cinematic Background
            AnimatedBuilder(
              animation: _cameraZoom,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_cameraRotateX.value)
                    ..rotateY(_cameraRotateY.value)
                    ..scale(_cameraZoom.value),
                  alignment: Alignment.center,
                  child: Container(
                    width: size.width,
                    height: size.height,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: [
                          Color(0xFF2A5CFF),
                          Color(0xFF0A0A2A),
                          Color(0xFF000000),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Particle System
            ..._particles.map((p) => Positioned(
              left: p.x * size.width,
              top: p.y * size.height,
              child: Container(
                width: p.size,
                height: p.size,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(p.life * 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(p.life * 0.5),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            )),

            // Fireworks Effect
            if (_showFireworks)
              ...List.generate(30, (index) {
                final angle = _random.nextDouble() * 2 * 3.14159;
                final distance = 50 + _random.nextDouble() * 100;
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + index * 50),
                  builder: (context, value, child) {
                    return Positioned(
                      left: size.width / 2 + cos(angle) * distance * value,
                      top: size.height / 2 + sin(angle) * distance * value,
                      child: Opacity(
                        opacity: 1 - value,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: [
                              Colors.red,
                              Colors.blue,
                              Colors.yellow,
                              Colors.green,
                              Colors.purple,
                            ][index % 5],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

            // Parallax Layer
            Positioned(
              top: -50,
              left: -50,
              child: AnimatedBuilder(
                animation: _cameraRotateX,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        20 * _cameraRotateX.value, 20 * _cameraRotateY.value),
                    child: Container(
                      width: size.width + 100,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Main Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 3D Glowing Logo
                  AnimatedBuilder(
                    // FIX: Changed from _glowIntensity to _controller
                    animation: _controller,
                    builder: (context, child) {
                      return Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.blue.withOpacity(0.8),
                              Colors.blue.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.4, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue
                                  .withOpacity(0.5 + _glowIntensity * 0.3),
                              blurRadius: 40 + _glowIntensity * 30,
                              spreadRadius: 10 + _glowIntensity * 5,
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF2A5CFF),
                                Color(0xFF7000FF),
                                Colors.white,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(_glowIntensity),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.auto_awesome,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 50),

                  // Cinematic Typing Text
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      _displayText,
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: [
                              Colors.white,
                              const Color(0xFF2A5CFF),
                              const Color(0xFF7000FF),
                              Colors.white,
                            ],
                            stops: const [0.0, 0.3, 0.7, 1.0],
                          ).createShader(const Rect.fromLTWH(0, 0, 300, 50)),
                        shadows: [
                          Shadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Glowing Subtitle
                  AnimatedBuilder(
                    // FIX: Changed from _glowIntensity to _controller
                    animation: _controller,
                    builder: (context, child) {
                      return Text(
                        'Your AI-Powered Viva Assistant',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white
                              .withOpacity(0.7 + _glowIntensity * 0.2),
                          letterSpacing: 2,
                          shadows: [
                            Shadow(
                              color:
                              Colors.blue.withOpacity(_glowIntensity * 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Loading Bar
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _controller.value,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      color: Colors.white,
                      minHeight: 2,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double life;
  Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speedX,
    required this.speedY,
    required this.life,
    required this.color,
  });
}