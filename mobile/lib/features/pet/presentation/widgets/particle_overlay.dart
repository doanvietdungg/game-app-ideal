import 'package:flutter/material.dart';

class ParticleItem {
  double x;
  double y;
  double vx;
  double vy;
  double opacity;
  final String emoji;

  ParticleItem({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.opacity = 1.0,
    required this.emoji,
  });
}

class ParticleOverlay extends StatefulWidget {
  final List<ParticleItem> particles;
  const ParticleOverlay({super.key, required this.particles});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _controller.addListener(_updateParticles);
  }

  void _updateParticles() {
    if (widget.particles.isEmpty) return;
    setState(() {
      for (var p in widget.particles) {
        p.x += p.vx;
        p.y += p.vy;
        p.opacity = (p.opacity - 0.03).clamp(0.0, 1.0);
      }
      widget.particles.removeWhere((p) => p.opacity <= 0.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.particles.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: widget.particles.map((p) {
          return Positioned(
            left: p.x,
            top: p.y,
            child: Opacity(
              opacity: p.opacity,
              child: Text(p.emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
