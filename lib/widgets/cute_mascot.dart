import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/cycle_phase.dart';
import '../theme/pink_theme.dart';

/// Maskot kelinci mungil yang ekspresinya berubah sesuai fase siklus:
/// - haid / PMS -> memakai selimut, mata sayu & mulut cemberut
/// - subur      -> mata senyum, tersenyum manis
/// - hidrasi    -> membawa botol minum, senyum terbuka
class CuteMascot extends StatefulWidget {
  const CuteMascot({super.key, required this.phase, this.size = 150});

  final CyclePhase phase;
  final double size;

  @override
  State<CuteMascot> createState() => _CuteMascotState();
}

class _CuteMascotState extends State<CuteMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
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
      builder: (context, _) {
        final t = _controller.value;
        // kedip 1x di setiap siklus animasi
        final blink = t > 0.92 && t < 0.955;
        // goyangan badan pelan & menggemaskan
        final bob = math.sin(t * math.pi * 4) * 3.5;

        return Transform.translate(
          offset: Offset(0, bob),
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: CuteBunnyPainter(phase: widget.phase, blink: blink),
          ),
        );
      },
    );
  }
}

enum _EyeStyle { open, happy, tired, grumpy }

enum _MouthStyle { smile, bigSmile, frown, pout }

class CuteBunnyPainter extends CustomPainter {
  CuteBunnyPainter({required this.phase, required this.blink});

  final CyclePhase phase;
  final bool blink;

  static const _fur = Color(0xFFFFFDFE);
  static const _furShade = Color(0xFFFFEAF2);
  static const _inner = Color(0xFFFFC9DB);
  static const _line = Color(0xFF6E4453);
  static const _cheek = Color(0xFFFFAFC7);

  _EyeStyle get _eyes => switch (phase) {
        CyclePhase.period => _EyeStyle.tired,
        CyclePhase.pms => _EyeStyle.grumpy,
        CyclePhase.ovulation => _EyeStyle.happy,
        CyclePhase.follicular => _EyeStyle.open,
        CyclePhase.luteal => _EyeStyle.open,
      };

  _MouthStyle get _mouth => switch (phase) {
        CyclePhase.period => _MouthStyle.pout,
        CyclePhase.pms => _MouthStyle.frown,
        CyclePhase.ovulation => _MouthStyle.bigSmile,
        CyclePhase.follicular => _MouthStyle.smile,
        CyclePhase.luteal => _MouthStyle.smile,
      };

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final headR = w * 0.28;
    final headC = Offset(cx, h * 0.56);

    // ---- badan mungil
    final bodyPaint = Paint()
      ..color = _fur
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, h * 0.9), width: w * 0.56, height: h * 0.2),
      bodyPaint,
    );
    // kaki
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - w * 0.14, h * 0.95), width: w * 0.2, height: h * 0.1),
      bodyPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + w * 0.14, h * 0.95), width: w * 0.2, height: h * 0.1),
      bodyPaint,
    );

    // ---- telinga
    _drawEar(canvas, center: Offset(cx - w * 0.13, h * 0.24), tilt: -0.16, w: w, h: h);
    _drawEar(canvas, center: Offset(cx + w * 0.13, h * 0.24), tilt: 0.16, w: w, h: h);

    // ---- kepala
    final headRect = Rect.fromCircle(center: headC, radius: headR);
    final headPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.35, -0.45),
        radius: 0.95,
        colors: [_fur, _furShade],
      ).createShader(headRect);
    canvas.drawCircle(headC, headR, headPaint);

    // ---- kumis
    final whisker = Paint()
      ..color = PinkPalette.dustyRose.withValues(alpha: 0.75)
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (final dir in const [-1, 1]) {
      for (final dy in const [-0.02, 0.04]) {
        final start = Offset(cx + dir * headR * 0.55, headC.dy + headR * (0.16 + dy));
        final end = Offset(cx + dir * headR * 1.05, headC.dy + headR * (0.10 + dy * 2));
        canvas.drawLine(start, end, whisker);
      }
    }

    // ---- pipi merona
    final cheekPaint = Paint()..color = _cheek.withValues(alpha: 0.55);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - headR * 0.6, headC.dy + headR * 0.3),
        width: headR * 0.42,
        height: headR * 0.26,
      ),
      cheekPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + headR * 0.6, headC.dy + headR * 0.3),
        width: headR * 0.42,
        height: headR * 0.26,
      ),
      cheekPaint,
    );

    // ---- hidung
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, headC.dy + headR * 0.12),
        width: headR * 0.22,
        height: headR * 0.16,
      ),
      Paint()..color = PinkPalette.dustyRose,
    );

    // ---- mata
    final eyeY = headC.dy - headR * 0.16;
    final eyeDX = headR * 0.44;
    final eyeR = headR * 0.17;
    final eyeStyle = blink ? _EyeStyle.tired : _eyes;
    _drawEye(canvas, Offset(cx - eyeDX, eyeY), eyeR, eyeStyle, isLeft: true);
    _drawEye(canvas, Offset(cx + eyeDX, eyeY), eyeR, eyeStyle, isLeft: false);

    // ---- mulut
    _drawMouth(
      canvas,
      Offset(cx, headC.dy + headR * 0.42),
      headR * 0.26,
      _mouth,
    );

    // ---- selimut untuk fase haid / PMS
    if (phase.needsBlanket) {
      _drawBlanket(canvas, size);
    }

    // ---- botol minum untuk fase hidrasi
    if (phase.needsHydration) {
      _drawWaterBottle(canvas, Offset(cx + w * 0.33, h * 0.82), w * 0.15);
    }
  }

  void _drawEar(Canvas canvas, {required Offset center, required double tilt, required double w, required double h}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tilt);

    final earRect = Rect.fromCenter(center: Offset.zero, width: w * 0.16, height: h * 0.34);
    canvas.drawRRect(
      RRect.fromRectAndRadius(earRect, Radius.circular(w * 0.08)),
      Paint()..color = _fur,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, -h * 0.015), width: w * 0.08, height: h * 0.24),
        Radius.circular(w * 0.04),
      ),
      Paint()..color = _inner,
    );
    canvas.restore();
  }

  void _drawEye(
    Canvas canvas,
    Offset center,
    double r,
    _EyeStyle style, {
    required bool isLeft,
  }) {
    final line = Paint()
      ..color = _line
      ..strokeWidth = r * 0.55
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (style) {
      case _EyeStyle.open:
        canvas.drawCircle(center, r, Paint()..color = _line);
        canvas.drawCircle(
          center + Offset(-r * 0.32, -r * 0.34),
          r * 0.34,
          Paint()..color = PinkPalette.white,
        );
      case _EyeStyle.happy:
        // mata senyum berbentuk ^ ^
        final rect = Rect.fromCircle(center: center + Offset(0, r * 0.4), radius: r * 1.2);
        canvas.drawArc(rect, math.pi, math.pi, false, line);
      case _EyeStyle.tired:
        // mata sayu berbentuk u u
        final rect = Rect.fromCircle(center: center + Offset(0, -r * 0.35), radius: r * 1.15);
        canvas.drawArc(rect, 0, math.pi, false, line);
      case _EyeStyle.grumpy:
        canvas.drawCircle(center, r * 0.85, Paint()..color = _line);
        canvas.drawCircle(
          center + Offset(-r * 0.28, -r * 0.3),
          r * 0.3,
          Paint()..color = PinkPalette.white,
        );
        // alis miring ke arah hidung -> jengkel tapi tetap lucu
        final brow = Paint()
          ..color = _line
          ..strokeWidth = r * 0.3
          ..strokeCap = StrokeCap.round;
        final outerX = isLeft ? -r * 1.6 : r * 1.6;
        final innerX = -outerX;
        canvas.drawLine(
          center + Offset(outerX, -r * 2.1),
          center + Offset(innerX, -r * 1.5),
          brow,
        );
    }
  }

  void _drawMouth(Canvas canvas, Offset pos, double r, _MouthStyle style) {
    final line = Paint()
      ..color = _line
      ..strokeWidth = r * 0.32
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (style) {
      case _MouthStyle.smile:
        canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, -r * 0.25), radius: r),
          0,
          math.pi,
          false,
          line,
        );
      case _MouthStyle.bigSmile:
        // mulut terbuka lebar
        canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, -r * 0.4), radius: r * 1.1),
          0,
          math.pi,
          true,
          Paint()..color = _line,
        );
        canvas.drawOval(
          Rect.fromCenter(center: pos + Offset(0, r * 0.34), width: r * 0.9, height: r * 0.5),
          Paint()..color = _cheek,
        );
      case _MouthStyle.frown:
        canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.35), radius: r * 0.8),
          math.pi,
          math.pi,
          false,
          line,
        );
      case _MouthStyle.pout:
        canvas.drawArc(
          Rect.fromCircle(center: pos + Offset(0, r * 0.2), radius: r * 0.75),
          math.pi,
          math.pi,
          false,
          line,
        );
    }
  }

  void _drawBlanket(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Rect.fromLTWH(w * 0.13, h * 0.74, w * 0.74, h * 0.26);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(w * 0.17));

    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PinkPalette.lavender, Color(0xFFCDBEFF)],
        ).createShader(rect),
    );

    // tekstur titik-titik manis
    final dot = Paint()..color = PinkPalette.white.withValues(alpha: 0.65);
    for (final p in const [
      Offset(0.28, 0.82),
      Offset(0.5, 0.9),
      Offset(0.7, 0.8),
      Offset(0.38, 0.96),
      Offset(0.64, 0.97),
    ]) {
      canvas.drawCircle(Offset(w * p.dx, h * p.dy), w * 0.02, dot);
    }

    // garis lipatan selimut
    canvas.drawLine(
      Offset(w * 0.17, h * 0.79),
      Offset(w * 0.83, h * 0.79),
      Paint()
        ..color = PinkPalette.lavenderDeep.withValues(alpha: 0.7)
        ..strokeWidth = w * 0.018
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawWaterBottle(Canvas canvas, Offset center, double size) {
    final rect = Rect.fromCenter(center: center, width: size * 0.72, height: size * 1.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(size * 0.26)),
      Paint()..color = const Color(0xFFBFE7FF),
    );
    // tutup botol
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, rect.top - size * 0.12),
          width: size * 0.4,
          height: size * 0.26,
        ),
        Radius.circular(size * 0.1),
      ),
      Paint()..color = PinkPalette.rose,
    );
    // air di dalamnya
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + size * 0.06, rect.center.dy, rect.width - size * 0.12, rect.height * 0.42),
        Radius.circular(size * 0.16),
      ),
      Paint()..color = const Color(0xFF8FCBFF),
    );
    // sedotan
    canvas.drawLine(
      Offset(center.dx + size * 0.1, rect.top),
      Offset(center.dx + size * 0.34, rect.top - size * 0.42),
      Paint()
        ..color = PinkPalette.deepRose
        ..strokeWidth = size * 0.09
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CuteBunnyPainter oldDelegate) =>
      oldDelegate.phase != phase || oldDelegate.blink != blink;
}