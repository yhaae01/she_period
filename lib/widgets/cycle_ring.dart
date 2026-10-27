import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/pink_theme.dart';

/// Lingkaran siklus besar di tengah dashboard,
/// dikelilingi emoji lucu yang mengorbit pelan.
class CycleRing extends StatelessWidget {
  const CycleRing({
    super.key,
    required this.day,
    required this.length,
    required this.phaseLabel,
    this.size = 210,
  });

  final int day;
  final int length;
  final String phaseLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: CycleRingPainter(
              progress: (day / length).clamp(0.0, 1.0),
              length: length,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HARI KE',
                style: textTheme.labelSmall?.copyWith(
                  color: PinkPalette.inkSoft,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: day.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (context, value, _) => Text(
                  value.round().toString(),
                  style: textTheme.displayLarge?.copyWith(
                    color: PinkPalette.deepRose,
                    fontSize: 56,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'dari $length hari',
                style: textTheme.bodySmall?.copyWith(
                  color: PinkPalette.inkSoft,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: PinkPalette.blush,
                  borderRadius: BorderRadius.circular(kCuteRadius),
                ),
                child: Text(
                  phaseLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: PinkPalette.deepRose,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CycleRingPainter extends CustomPainter {
  CycleRingPainter({required this.progress, required this.length});

  final double progress;
  final int length;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // lintasan bulat penuh
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = PinkPalette.blush
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18,
    );

    // progres siklus dengan gradien pink -> lavender
    if (progress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            colors: [
              PinkPalette.rose,
              PinkPalette.dustyRose,
              PinkPalette.lavenderDeep,
            ],
            transform: GradientRotation(-math.pi / 2),
          ).createShader(rect),
      );
    }

    // titik hari di sekeliling
    for (var i = 0; i < length; i++) {
      final angle = -math.pi / 2 + (math.pi * 2 * i) / length;
      final pos = center +
          Offset(math.cos(angle), math.sin(angle)) * (radius - 20);
      final isPast = i + 1 <= progress * length;
      final isToday = i + 1 == (progress * length).round();

      if (isToday) {
        canvas.drawCircle(
          pos,
          6,
          Paint()
            ..color = PinkPalette.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          pos,
          6,
          Paint()
            ..color = PinkPalette.deepRose
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.5,
        );
      } else {
        canvas.drawCircle(
          pos,
          3,
          Paint()
            ..color = isPast ? PinkPalette.rose : PinkPalette.dustyRose
            ..style = PaintingStyle.fill,
        );
      }
    }

    // penanda ujung progres
    if (progress > 0 && progress < 1) {
      final angle = -math.pi / 2 + math.pi * 2 * progress;
      final head = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(head, 8, Paint()..color = PinkPalette.white);
      canvas.drawCircle(
        head,
        8,
        Paint()
          ..color = PinkPalette.deepRose
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }
  }

  @override
  bool shouldRepaint(CycleRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.length != length;
}

/// Emoji-emoji lucu yang mengorbit mengelilingi lingkaran siklus.
class OrbitingEmojis extends StatefulWidget {
  const OrbitingEmojis({
    super.key,
    required this.radius,
    required this.emojis,
    this.fontSize = 20,
    this.duration = const Duration(seconds: 26),
  });

  final double radius;
  final List<String> emojis;
  final double fontSize;
  final Duration duration;

  @override
  State<OrbitingEmojis> createState() => _OrbitingEmojisState();
}

class _OrbitingEmojisState extends State<OrbitingEmojis>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.radius + widget.fontSize;

    return SizedBox(
      width: box * 2,
      height: box * 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < widget.emojis.length; i++)
                _buildEmoji(
                  widget.emojis[i],
                  baseAngle: (math.pi * 2 * i) / widget.emojis.length +
                      t * math.pi * 2 * 0.35,
                  box: box,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmoji(String emoji, {required double baseAngle, required double box}) {
    final x = box + math.cos(baseAngle) * widget.radius;
    final y = box + math.sin(baseAngle) * widget.radius;

    return Positioned(
      left: x - widget.fontSize,
      top: y - widget.fontSize,
      child: Text(
        emoji,
        style: TextStyle(fontSize: widget.fontSize, height: 1),
      ),
    );
  }
}