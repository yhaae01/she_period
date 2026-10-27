import 'package:flutter/material.dart';

/// Micro-interaction: tombol "berdetak pelan" saat disentuh.
///
/// Tekan  -> mengecil ke [minScale] dengan cepat
/// Lepas -> memantul kembali ke ukuran normal dengan efek elastis
class BounceTap extends StatefulWidget {
  const BounceTap({
    super.key,
    required this.child,
    this.onTap,
    this.minScale = 0.9,
    this.hitTestBehavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double minScale;
  final HitTestBehavior hitTestBehavior;

  @override
  State<BounceTap> createState() => _BounceTapState();
}

class _BounceTapState extends State<BounceTap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
    value: 1,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _pressDown() {
    _controller.animateTo(
      widget.minScale,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeOutCubic,
    );
  }

  void _pressUp() {
    _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 520),
      curve: Curves.elasticOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.hitTestBehavior,
      onTapDown: (_) => _pressDown(),
      onTapUp: (_) => _pressUp(),
      onTapCancel: _pressUp,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _controller,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}