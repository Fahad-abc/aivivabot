import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aivivabot/routes.dart';
import 'package:aivivabot/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _brainPulseController;
  late AnimationController _dataStreamController;
  late AnimationController _hudController;
  late AnimationController _orbitController;
  late AnimationController _energyWaveController;

  late Animation<double> _fadeIn;
  late Animation<double> _titleSlideUp;
  late Animation<double> _brainScale;
  late Animation<double> _breathScale;

  final Random _random = Random();
  final List<_DataStream> _dataStreams = [];
  final List<_NeuralNode> _neuralNodes = [];
  final List<_CircuitTrace> _circuitTraces = [];
  final List<_HudElement> _hudElements = [];
  final List<_ServerRack> _serverRacks = [];

  String _loadingText = 'Initializing Neural Networks...';

  final List<String> _loadingMessages = [
    'Initializing Neural Networks...',
    'Calibrating Speech Recognition...',
    'Loading Knowledge Base...',
    'Syncing Learning Analytics...',
    'Connecting to AI Core...',
    'System Ready',
  ];

  @override
  void initState() {
    super.initState();
    _initDataStreams();
    _initNeuralNodes();
    _initCircuitTraces();
    _initHudElements();
    _initServerRacks();
    _initAnimations();
    _startLoadingSequence();
  }

  void _initDataStreams() {
    for (int i = 0; i < 25; i++) {
      _dataStreams.add(_DataStream(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        speed: 0.2 + _random.nextDouble() * 0.6,
        opacity: 0.1 + _random.nextDouble() * 0.3,
        length: 0.1 + _random.nextDouble() * 0.3,
        width: 0.5 + _random.nextDouble() * 1.5,
      ));
    }
  }

  void _initNeuralNodes() {
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final radius = 0.06 + _random.nextDouble() * 0.20;
      _neuralNodes.add(_NeuralNode(
        x: 0.5 + cos(angle) * radius,
        y: 0.42 + sin(angle) * radius,
        size: 1.5 + _random.nextDouble() * 2.5,
        pulsePhase: _random.nextDouble() * 2 * pi,
        connections: [],
      ));
    }
    for (int i = 0; i < _neuralNodes.length; i++) {
      final count = 1 + _random.nextInt(3);
      for (int j = 0; j < count; j++) {
        final target = _random.nextInt(_neuralNodes.length);
        if (target != i && !_neuralNodes[i].connections.contains(target)) {
          _neuralNodes[i].connections.add(target);
        }
      }
    }
  }

  void _initCircuitTraces() {
    for (int i = 0; i < 12; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final startR = 0.13 + _random.nextDouble() * 0.04;
      final endR = 0.24 + _random.nextDouble() * 0.10;
      _circuitTraces.add(_CircuitTrace(
        startX: 0.5 + cos(angle) * startR,
        startY: 0.42 + sin(angle) * startR,
        endX: 0.5 + cos(angle + (_random.nextDouble() - 0.5) * 0.4) * endR,
        endY: 0.42 + sin(angle + (_random.nextDouble() - 0.5) * 0.4) * endR,
        midX: 0.5 + cos(angle + (_random.nextDouble() - 0.3) * 0.6) * (startR + endR) / 2,
        midY: 0.42 + sin(angle + (_random.nextDouble() - 0.3) * 0.6) * (startR + endR) / 2,
        opacity: 0.3 + _random.nextDouble() * 0.5,
      ));
    }
  }

  void _initHudElements() {
    final hudData = [
      _HudData(Icons.mic, 'Speech Recognition', 2 * pi / 3),
      _HudData(Icons.menu_book, 'Knowledge Base', 4 * pi / 3),
      _HudData(Icons.analytics, 'Learning Analytics', 0),
    ];
    for (int i = 0; i < hudData.length; i++) {
      _hudElements.add(_HudElement(
        icon: hudData[i].icon,
        label: hudData[i].label,
        angle: hudData[i].angle,
        floatOffset: _random.nextDouble() * 2 * pi,
      ));
    }
  }

  void _initServerRacks() {
    for (int i = 0; i < 8; i++) {
      _serverRacks.add(_ServerRack(
        x: i < 4 ? 0.02 + _random.nextDouble() * 0.08 : 0.90 + _random.nextDouble() * 0.08,
        y: 0.05 + _random.nextDouble() * 0.85,
        height: 0.06 + _random.nextDouble() * 0.12,
        width: 0.025 + _random.nextDouble() * 0.015,
        ledOn: _random.nextBool(),
        blinkSpeed: 0.5 + _random.nextDouble() * 2,
      ));
    }
  }

  void _initAnimations() {
    _mainController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    _brainPulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _dataStreamController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _hudController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _orbitController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _energyWaveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.5, curve: Curves.easeIn)),
    );

    _titleSlideUp = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack)),
    );

    _brainScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.5, curve: Curves.elasticOut)),
    );

    _breathScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 1),
    ]).animate(
      CurvedAnimation(parent: _brainPulseController, curve: Curves.easeInOut),
    );

    _mainController.addListener(() {
      setState(() {});
    });

    _mainController.forward();
  }

  void _startLoadingSequence() {
    int step = 0;
    Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted || step >= _loadingMessages.length) {
        timer.cancel();
        return;
      }
      setState(() {
        _loadingText = _loadingMessages[step];
      });
      step++;
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        AppRoutes.navigateToOnboarding(context);
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _brainPulseController.dispose();
    _dataStreamController.dispose();
    _hudController.dispose();
    _orbitController.dispose();
    _energyWaveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.darkBackground,
              AppColors.darkSurfaceAlt,
              AppColors.darkBackground,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Server rack silhouettes (background layer)
            ..._buildServerRacks(size),

            // Scrolling data streams
            AnimatedBuilder(
              animation: _dataStreamController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _DataStreamPainter(
                    streams: _dataStreams,
                    time: _dataStreamController.value,
                  ),
                );
              },
            ),

            // Circuit traces
            AnimatedBuilder(
              animation: _brainPulseController,
              builder: (context, _) {
                final pulse = sin(_brainPulseController.value * 2 * pi) * 0.5 + 0.5;
                return CustomPaint(
                  size: size,
                  painter: _CircuitTracePainter(
                    traces: _circuitTraces,
                    pulseValue: pulse,
                  ),
                );
              },
            ),

            // Neural network nodes
            AnimatedBuilder(
              animation: _brainPulseController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _NeuralNetworkPainter(
                    nodes: _neuralNodes,
                    time: _brainPulseController.value,
                  ),
                );
              },
            ),

            // Central brain outer glow
            AnimatedBuilder(
              animation: _brainPulseController,
              builder: (context, _) {
                final pulse = sin(_brainPulseController.value * 2 * pi) * 0.5 + 0.5;
                return Positioned(
                  left: size.width / 2 - 130,
                  top: size.height * 0.42 - 130,
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withOpacity(0.2 + pulse * 0.25),
                          blurRadius: 70 + pulse * 50,
                          spreadRadius: 25 + pulse * 25,
                        ),
                        BoxShadow(
                          color: AppColors.infoCyan.withOpacity(0.08 + pulse * 0.12),
                          blurRadius: 100,
                          spreadRadius: 50,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Expanding energy rings
            AnimatedBuilder(
              animation: _energyWaveController,
              builder: (context, _) {
                final wave = _energyWaveController.value;
                return CustomPaint(
                  size: size,
                  painter: _EnergyWavePainter(
                    center: Offset(size.width / 2, size.height * 0.42),
                    wave: wave,
                    pulse: sin(_brainPulseController.value * 2 * pi) * 0.5 + 0.5,
                  ),
                );
              },
            ),

            // Central AI brain logo
            AnimatedBuilder(
              animation: _brainPulseController,
              builder: (context, _) {
                final pulse = sin(_brainPulseController.value * 2 * pi) * 0.5 + 0.5;
                return Positioned(
                  left: size.width / 2 - 65,
                  top: size.height * 0.42 - 65,
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, _) {
                      return Transform.scale(
                        scale: _brainScale.value,
                        child: _BrainLogo(
                          size: 130,
                          pulse: pulse,
                          orbitAngle: _orbitController.value * 2 * pi,
                          breathScale: _breathScale.value,
                          energyScale: 1.0 + sin(_energyWaveController.value * 2 * pi) * 0.02,
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            // HUD floating elements
            ..._buildHudElements(size),

            // Connection lines from brain to HUD
            AnimatedBuilder(
              animation: _hudController,
              builder: (context, _) {
                return CustomPaint(
                  size: size,
                  painter: _HudConnectionPainter(
                    hudElements: _hudElements,
                    time: _hudController.value,
                    brainCenter: Offset(size.width / 2, size.height * 0.42),
                    hudRadius: size.width * 0.35,
                  ),
                );
              },
            ),

            // Title and subtitle (positioned at bottom area)
            AnimatedBuilder(
              animation: _mainController,
              builder: (context, _) {
                return Opacity(
                  opacity: _fadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, _titleSlideUp.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: size.height * 0.72),
                        Text(
                          'AI VIVA BOT',
                          style: GoogleFonts.orbitron(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 8,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: AppColors.primaryBlue,
                                blurRadius: 25,
                              ),
                              Shadow(
                                color: AppColors.infoCyan,
                                blurRadius: 50,
                              ),
                              Shadow(
                                color: AppColors.primaryBlue,
                                blurRadius: 80,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'The Advanced Academic Assessment Assistant',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryBlue.withOpacity(0.4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Loading bar
            Positioned(
              bottom: 40 + MediaQuery.of(context).padding.bottom,
              left: 40,
              right: 40,
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, _) {
                  final glow = sin(_mainController.value * 2 * pi) * 0.5 + 0.5;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _loadingText,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _mainController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.infoCyan,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.infoCyan.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${(_mainController.value * 100).toInt()}% Complete',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.infoCyan.withOpacity(0.8 + glow * 0.2),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildServerRacks(Size size) {
    final List<Widget> widgets = [];
    for (final rack in _serverRacks) {
      final blink = sin(_mainController.value * rack.blinkSpeed * 2 * pi) > 0;
      widgets.add(Positioned(
        left: rack.x * size.width,
        top: rack.y * size.height,
        child: Container(
          width: rack.width * size.width,
          height: rack.height * size.height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: Colors.white.withOpacity(0.04),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              (rack.height * size.height / 14).floor().clamp(2, 8),
              (_) => Container(
                width: rack.width * size.width * 0.6,
                height: 2,
                decoration: BoxDecoration(
                  color: blink && rack.ledOn
                      ? AppColors.successGreen.withOpacity(0.4)
                      : AppColors.primaryBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ));
    }
    return widgets;
  }

  List<Widget> _buildHudElements(Size size) {
    final centerX = size.width / 2;
    final centerY = size.height * 0.42;
    final hudRadius = size.width * 0.35;

    return _hudElements.asMap().entries.map((entry) {
      final index = entry.key;
      final hud = entry.value;
      final angle = hud.angle + sin(_hudController.value * 2 * pi + hud.floatOffset) * 0.08;
      final x = centerX + cos(angle) * hudRadius;
      final y = centerY + sin(angle) * hudRadius;
      final floatY = sin(_hudController.value * 2 * pi * 0.7 + hud.floatOffset) * 5;

      return Positioned(
        left: x - 95,
        top: y - 25 + floatY,
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, _) {
            final appearDelay = 0.3 + index * 0.15;
            final hudOpacity = ((_mainController.value - appearDelay) / 0.3).clamp(0.0, 1.0);
            return Opacity(
              opacity: hudOpacity,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - hudOpacity)),
                child: _HudCard(
                  icon: hud.icon,
                  label: hud.label,
                  pulse: sin(_hudController.value * 2 * pi + hud.floatOffset) * 0.5 + 0.5,
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }
}

// ============================================================
// DATA STREAM PAINTER
// ============================================================

class _DataStreamPainter extends CustomPainter {
  final List<_DataStream> streams;
  final double time;

  _DataStreamPainter({required this.streams, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final stream in streams) {
      final yPos = (stream.y + time * stream.speed) % 1.2 - 0.1;
      paint.color = AppColors.infoCyan.withOpacity(stream.opacity * 0.5);
      paint.strokeWidth = stream.width;
      paint.style = PaintingStyle.stroke;

      final startY = yPos * size.height;
      final endY = startY + stream.length * size.height;

      canvas.drawLine(
        Offset(stream.x * size.width, startY),
        Offset(stream.x * size.width, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DataStreamPainter old) => old.time != time;
}

// ============================================================
// CIRCUIT TRACE PAINTER
// ============================================================

class _CircuitTracePainter extends CustomPainter {
  final List<_CircuitTrace> traces;
  final double pulseValue;

  _CircuitTracePainter({
    required this.traces,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final trace in traces) {
      final start = Offset(trace.startX * size.width, trace.startY * size.height);
      final end = Offset(trace.endX * size.width, trace.endY * size.height);
      final mid = Offset(trace.midX * size.width, trace.midY * size.height);
      final ctrl1 = Offset(mid.dx, start.dy + (mid.dy - start.dy) * 0.3);
      final ctrl2 = Offset(mid.dx, end.dy - (end.dy - mid.dy) * 0.3);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(ctrl1.dx, ctrl1.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);

      paint.color = AppColors.primaryBlue.withOpacity(trace.opacity * (0.4 + pulseValue * 0.5));
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitTracePainter old) => old.pulseValue != pulseValue;
}

// ============================================================
// NEURAL NETWORK PAINTER
// ============================================================

class _NeuralNetworkPainter extends CustomPainter {
  final List<_NeuralNode> nodes;
  final double time;

  _NeuralNetworkPainter({
    required this.nodes,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final nodePaint = Paint()..style = PaintingStyle.fill;
    final glowPaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length; i++) {
      for (final conn in nodes[i].connections) {
        if (conn < nodes.length) {
          final start = Offset(nodes[i].x * size.width, nodes[i].y * size.height);
          final end = Offset(nodes[conn].x * size.width, nodes[conn].y * size.height);
          final pulse = sin(time * 2 * pi + nodes[i].pulsePhase) * 0.5 + 0.5;
          linePaint.color = AppColors.primaryBlue.withOpacity(0.15 + pulse * 0.25);
          canvas.drawLine(start, end, linePaint);
        }
      }
    }

    for (final node in nodes) {
      final pulse = sin(time * 2 * pi + node.pulsePhase) * 0.5 + 0.5;
      final center = Offset(node.x * size.width, node.y * size.height);
      final radius = node.size * (0.8 + pulse * 0.4);

      glowPaint.color = AppColors.infoCyan.withOpacity(0.08 * pulse);
      canvas.drawCircle(center, radius * 3, glowPaint);

      nodePaint.color = AppColors.primaryBlue.withOpacity(0.5 + pulse * 0.4);
      canvas.drawCircle(center, radius, nodePaint);

      nodePaint.color = Colors.white.withOpacity(0.7);
      canvas.drawCircle(center, radius * 0.35, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuralNetworkPainter old) => old.time != time;
}

// ============================================================
// HUD CONNECTION PAINTER
// ============================================================

class _HudConnectionPainter extends CustomPainter {
  final List<_HudElement> hudElements;
  final double time;
  final Offset brainCenter;
  final double hudRadius;

  _HudConnectionPainter({
    required this.hudElements,
    required this.time,
    required this.brainCenter,
    required this.hudRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < hudElements.length; i++) {
      final hud = hudElements[i];
      final angle = hud.angle + sin(time * 2 * pi + hud.floatOffset) * 0.08;
      final endX = brainCenter.dx + cos(angle) * hudRadius;
      final endY = brainCenter.dy + sin(angle) * hudRadius;

      final pulse = sin(time * 2 * pi + hud.floatOffset) * 0.5 + 0.5;
      paint.color = AppColors.infoCyan.withOpacity(0.08 + pulse * 0.12);

      canvas.drawLine(brainCenter, Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HudConnectionPainter old) => old.time != time;
}

// ============================================================
// AI BRAIN LOGO WIDGET
// ============================================================

class _BrainLogo extends StatelessWidget {
  final double size;
  final double pulse;
  final double orbitAngle;
  final double breathScale;
  final double energyScale;

  const _BrainLogo({
    required this.size,
    required this.pulse,
    required this.orbitAngle,
    required this.breathScale,
    required this.energyScale,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: breathScale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.35 + pulse * 0.45),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.4 * pulse),
              blurRadius: 25,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated outer dashed ring (rotating)
            Transform.rotate(
              angle: orbitAngle,
              child: CustomPaint(
                size: Size(size, size),
                painter: _OrbitRingPainter(pulse: pulse, orbitAngle: orbitAngle),
              ),
            ),
            // Middle ring
            Container(
              width: size * 0.82,
              height: size * 0.82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.infoCyan.withOpacity(0.15 + pulse * 0.25),
                  width: 1,
                ),
              ),
            ),
            // Glow ring
            Container(
              width: size * 0.66,
              height: size * 0.66,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.12 + pulse * 0.18),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.8],
                ),
              ),
            ),
            // Brain icon container with energy pulse
            Transform.scale(
              scale: energyScale,
              child: Container(
                width: size * 0.48,
                height: size * 0.48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkSurfaceAlt,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.6 * pulse),
                      blurRadius: 25,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.psychology,
                  size: size * 0.32,
                  color: Colors.white.withOpacity(0.85 + pulse * 0.15),
                ),
              ),
            ),
            // Orbiting neural dots
            ...List.generate(10, (i) {
              final dotAngle = orbitAngle + (i / 10) * 2 * pi;
              final dotDist = size * 0.44 + sin(orbitAngle * 2 + i) * 2;
              final dotPulse = sin(orbitAngle * 3 + i * 1.2) * 0.5 + 0.5;
              final dotSize = 3 + dotPulse * 3;
              return Positioned(
                left: size / 2 + cos(dotAngle) * dotDist - dotSize / 2,
                top: size / 2 + sin(dotAngle) * dotDist - dotSize / 2,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.infoCyan.withOpacity(0.2 + dotPulse * 0.6),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.infoCyan.withOpacity(0.5 * dotPulse),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              );
            }),
            // Inner connection lines between dots
            ...List.generate(5, (i) {
              final a1 = orbitAngle + (i / 5) * 2 * pi;
              final a2 = orbitAngle + ((i + 2) / 5) * 2 * pi;
              final d = size * 0.44;
              final x1 = size / 2 + cos(a1) * d;
              final y1 = size / 2 + sin(a1) * d;
              final x2 = size / 2 + cos(a2) * d;
              final y2 = size / 2 + sin(a2) * d;
              final linePulse = sin(orbitAngle * 2 + i) * 0.5 + 0.5;
              return Positioned.fill(
                child: CustomPaint(
                  painter: _DotLinePainter(
                    x1: x1, y1: y1, x2: x2, y2: y2,
                    opacity: 0.1 + linePulse * 0.2,
                    pulse: pulse,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ORBIT RING PAINTER
// ============================================================

class _OrbitRingPainter extends CustomPainter {
  final double pulse;
  final double orbitAngle;

  _OrbitRingPainter({required this.pulse, required this.orbitAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.infoCyan.withOpacity(0.15 + pulse * 0.25);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final dashWidth = 6.0;
    final dashSpace = 8.0;
    final circumference = 2 * pi * radius;
    final totalDash = dashWidth + dashSpace;
    final count = (circumference / totalDash).floor();
    final offset = (orbitAngle * radius) % totalDash;

    for (int i = 0; i < count; i++) {
      final startAngle = (i * totalDash + offset) / radius;
      final endAngle = (i * totalDash + offset + dashWidth) / radius;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, endAngle - startAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter old) =>
      old.pulse != pulse || old.orbitAngle != orbitAngle;
}

// ============================================================
// DOT LINE PAINTER
// ============================================================

class _DotLinePainter extends CustomPainter {
  final double x1, y1, x2, y2, opacity, pulse;

  _DotLinePainter({
    required this.x1, required this.y1,
    required this.x2, required this.y2,
    required this.opacity, required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = AppColors.infoCyan.withOpacity(opacity);
    canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
  }

  @override
  bool shouldRepaint(covariant _DotLinePainter old) =>
      old.opacity != opacity || old.pulse != pulse;
}

// ============================================================
// ENERGY WAVE PAINTER
// ============================================================

class _EnergyWavePainter extends CustomPainter {
  final Offset center;
  final double wave;
  final double pulse;

  _EnergyWavePainter({required this.center, required this.wave, required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Two expanding rings with different phases
    for (int i = 0; i < 2; i++) {
      final phase = (wave + i * 0.3) % 1.0;
      final radius = phase * size.width * 0.5;
      final opacity = (1.0 - phase) * 0.3 * pulse;

      paint.color = AppColors.primaryBlue.withOpacity(opacity);
      canvas.drawCircle(center, radius, paint);

      paint.color = AppColors.infoCyan.withOpacity(opacity * 0.5);
      paint.strokeWidth = 0.5;
      canvas.drawCircle(center, radius + 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnergyWavePainter old) =>
      old.wave != wave || old.pulse != pulse;
}

// ============================================================
// HUD CARD WIDGET
// ============================================================

class _HudCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double pulse;

  const _HudCard({
    required this.icon,
    required this.label,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceAlt.withOpacity(0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.15 + pulse * 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.08 * pulse),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBlue.withOpacity(0.12 + pulse * 0.1),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.infoCyan.withOpacity(0.7 + pulse * 0.3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.75 + pulse * 0.25),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATA MODELS
// ============================================================

class _DataStream {
  final double x, y, speed, opacity, length, width;
  _DataStream({
    required this.x, required this.y, required this.speed,
    required this.opacity, required this.length, required this.width,
  });
}

class _NeuralNode {
  final double x, y, size, pulsePhase;
  final List<int> connections;
  _NeuralNode({
    required this.x, required this.y, required this.size,
    required this.pulsePhase, required this.connections,
  });
}

class _CircuitTrace {
  final double startX, startY, endX, endY, midX, midY, opacity;
  _CircuitTrace({
    required this.startX, required this.startY,
    required this.endX, required this.endY,
    required this.midX, required this.midY, required this.opacity,
  });
}

class _HudElement {
  final IconData icon;
  final String label;
  final double angle, floatOffset;
  _HudElement({
    required this.icon, required this.label,
    required this.angle, required this.floatOffset,
  });
}

class _HudData {
  final IconData icon;
  final String label;
  final double angle;
  _HudData(this.icon, this.label, this.angle);
}

class _ServerRack {
  final double x, y, height, width, blinkSpeed;
  final bool ledOn;
  _ServerRack({
    required this.x, required this.y, required this.height,
    required this.width, required this.ledOn, required this.blinkSpeed,
  });
}
