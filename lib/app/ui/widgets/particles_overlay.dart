import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesController {
  final _notifier = ValueNotifier<int>(0);
  void play() => _notifier.value++;
  void dispose() => _notifier.dispose();
}

class ParticlesOverlay extends StatefulWidget {
  final ParticlesController controller;
  final bool enabled;
  const ParticlesOverlay({super.key, required this.controller, required this.enabled});

  @override
  State<ParticlesOverlay> createState() => _ParticlesOverlayState();
}

class _ParticlesOverlayState extends State<ParticlesOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> _particles = [];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _particles.clear();
        _controller.reset();
      }
    });
    widget.controller._notifier.addListener(_emit);
  }

  void _emit() {
    if (!widget.enabled || _controller.isAnimating) return;
    final count = 35; // Reduced from 60 for better performance
    _particles = List.generate(count, (_) {
      final angle = (_rng.nextDouble() - 0.5) * 2.5; // Wider spread
      final speed = _rng.nextDouble() * 0.8 + 1.2; // Faster fall
      return _Particle(
        position: Offset(_rng.nextDouble(), -0.1), // Start slightly above
        velocity: Offset(
          sin(angle) * speed * 0.4, // Horizontal spread
          cos(angle).abs() * speed + 0.5, // Faster downward
        ),
        color: Colors.primaries[_rng.nextInt(Colors.primaries.length)],
        size: _rng.nextDouble() * 5 + 4, // Slightly larger
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 8,
      );
    });
    _controller.forward(from: 0);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.controller._notifier.removeListener(_emit);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _particles.isEmpty) return const SizedBox.shrink();
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlesPainter(_particles, _controller.value),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _Particle {
  final Offset position; // normalized (0..1, 0..1)
  final Offset velocity; // delta per t
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  _Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1
  _ParticlesPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false; // Better performance
    
    for (final p in particles) {
      final x = p.position.dx * size.width + p.velocity.dx * t * size.width;
      final y = p.position.dy * size.height + p.velocity.dy * t * size.height;
      
      // Fade out as they fall
      final opacity = (1 - (t * 1.2)).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(opacity);
      
      // Draw with rotation for more dynamic effect
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => oldDelegate.t != t;
}