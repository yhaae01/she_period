import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/cycle_phase.dart';
import '../theme/pink_theme.dart';
import 'cute_mascot.dart';

/// Maskot kelinci beranimasi (Lottie) dengan aksesori lucu yang
/// berubah sesuai fase siklus.
///
/// Jika asset gagal dimuat, otomatis jatuh ke maskot CustomPaint.
class LottieMascot extends StatelessWidget {
  const LottieMascot({super.key, required this.phase, this.size = 150});

  final CyclePhase phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Lottie.asset(
            'assets/lottie/bunny.json',
            width: size,
            height: size,
            repeat: true,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                CuteMascot(phase: phase, size: size),
          ),
          Positioned(
            right: size * 0.02,
            top: size * 0.04,
            child: _PhaseAccessory(emoji: phase.accessory, size: size * 0.3),
          ),
        ],
      ),
    );
  }
}

/// Gelembung aksesori yang berdenyut pelan di dekat telinga kelinci.
class _PhaseAccessory extends StatefulWidget {
  const _PhaseAccessory({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  State<_PhaseAccessory> createState() => _PhaseAccessoryState();
}

class _PhaseAccessoryState extends State<_PhaseAccessory>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final scale = 1 + math.sin(t * math.pi * 2) * 0.08;
        final lift = math.sin(t * math.pi * 2 + 1) * 3;

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PinkPalette.white,
          shape: BoxShape.circle,
          border: Border.all(color: PinkPalette.blush, width: 2),
          boxShadow: [
            BoxShadow(
              color: PinkPalette.dustyRose.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          widget.emoji,
          style: TextStyle(fontSize: widget.size * 0.55),
        ),
      ),
    );
  }
}