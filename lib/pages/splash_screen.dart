import 'dart:async';

import 'package:flutter/material.dart';

import '../data/cycle_repository.dart';
import '../home_shell.dart';
import '../theme/pink_theme.dart';
import 'onboarding_page.dart';

/// Layar pembuka: logo + animasi loading manis selama ±2,5 detik,
/// lalu otomatis mengarahkan ke [OnboardingPage] (pertama kali dibuka)
/// atau ke [HomeShell] (sudah pernah setup).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.repository});

  final CycleRepository repository;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2500), _goNext);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    final Widget next = widget.repository.onboardingDone
        ? HomeShell(repository: widget.repository)
        : OnboardingPage(repository: widget.repository);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PinkPalette.blush,
              PinkPalette.softBabyPink,
              PinkPalette.cream,
            ],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutBack,
            builder: (context, value, child) => Opacity(
              opacity: value.clamp(0.0, 1.0),
              child: Transform.scale(scale: 0.85 + 0.15 * value, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // logo kelinci bulat dengan glow lembut
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PinkPalette.dustyRose.withValues(alpha: 0.45),
                        blurRadius: 32,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 156,
                      height: 156,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(
                        width: 156,
                        height: 156,
                        color: PinkPalette.blush,
                        alignment: Alignment.center,
                        child: const Text('🐰', style: TextStyle(fontSize: 64)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'ShePeriod',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: PinkPalette.deepRose,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Teman cantikmu selama siklus 🐰',
                  style: TextStyle(fontSize: 14, color: PinkPalette.inkSoft),
                ),
                const SizedBox(height: 32),
                // indikator loading pink
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: PinkPalette.rose,
                    backgroundColor: PinkPalette.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Menyiapkan yang terbaik untukmu…',
                  style: TextStyle(fontSize: 13, color: PinkPalette.inkSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}