import 'dart:async';
import 'dart:math';
import 'package:booking_app/ui/auth/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _shimmerAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _particleAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
          ),
        );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeIn),
      ),
    );

    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _particleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _mainController.forward();

    Timer(const Duration(milliseconds: 3000), () async {
      if (!mounted) return;
      final auth = context.read<AuthManager>();
      if (!auth.isRestored) {
        await auth.restoredFuture;
      }
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B2E3C),
                  Color(0xFF0A3D2E),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _particleAnim,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleAnim.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Center(
              child: Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF00C896).withOpacity(0.18),
                        const Color(0xFF00C896).withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (_, __) => FadeTransition(
                    opacity: _logoFade,
                    child: SlideTransition(
                      position: _logoSlide,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: _buildLogo(),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                AnimatedBuilder(
                  animation: _mainController,
                  builder: (_, __) => FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: _buildTitle(),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                FadeTransition(
                  opacity: _taglineFade,
                  child: const Text(
                    'Rùa nhỏ chào bạn',
                    style: TextStyle(
                      color: Color(0xFF7ECDB0),
                      fontSize: 14,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => _buildProgressBar(),
                ),
              ],
            ),
          ),

          const Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Text(
              'v1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF3A5A4A),
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _shimmerAnim,
      builder: (_, child) => ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: const [
            Colors.transparent,
            Color(0xAAFFFFFF),
            Colors.transparent,
          ],
          stops: [
            (_shimmerAnim.value - 0.4).clamp(0.0, 1.0),
            _shimmerAnim.value.clamp(0.0, 1.0),
            (_shimmerAnim.value + 0.4).clamp(0.0, 1.0),
          ],
        ).createShader(bounds),
        blendMode: BlendMode.srcATop,
        child: child,
      ),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF0D2A1E),
          border: Border.all(color: const Color(0xFF00C896), width: 2.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C896).withOpacity(0.35),
              blurRadius: 28,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.directions_car_rounded,
              size: 52,
              color: Color(0xFF00C896),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00C896), Color(0xFF80FFD4)],
          ).createShader(bounds),
          child: const Text(
            'BOOKING CAR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: SizedBox(
              height: 3,
              child: LinearProgressIndicator(
                value: _progressAnim.value,
                backgroundColor: const Color(0xFF1E3A2F),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00C896),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${(_progressAnim.value * 100).toInt()}%',
            style: const TextStyle(
              color: Color(0xFF3E8A6A),
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  static final List<_Particle> _particles = List.generate(
    22,
    (i) => _Particle(i),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final t = (progress + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = size.height - (t * (size.height + 40)) + 20;
      final opacity = (sin(t * pi) * 0.5).clamp(0.0, 0.5);

      canvas.drawCircle(
        Offset(x, y),
        p.radius,
        Paint()
          ..color = Color(0xFF00C896).withOpacity(opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}

class _Particle {
  final double x;
  final double offset;
  final double radius;

  _Particle(int seed)
    : x = (seed * 137.508 % 100) / 100,
      offset = (seed * 61.803 % 100) / 100,
      radius = 1.5 + (seed % 4) * 0.8;
}
