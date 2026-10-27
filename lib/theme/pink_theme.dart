import 'package:flutter/material.dart';

/// Palet warna feminin & pink aesthetic.
///
/// - [softBabyPink] / [blush] : dasar yang lembut & ramah
/// - [dustyRose] / [rose] / [deepRose] : jantung warna pink
/// - [lavender] / [lavenderDeep] : aksen penyeimbang
/// - [peach] : aksen hangat agar tidak monoton
abstract final class PinkPalette {
  static const softBabyPink = Color(0xFFFFE9F1);
  static const blush = Color(0xFFFFD7E4);
  static const dustyRose = Color(0xFFE7A2B7);
  static const rose = Color(0xFFF2789F);
  static const deepRose = Color(0xFFD4577E);
  static const lavender = Color(0xFFE7DDFF);
  static const lavenderDeep = Color(0xFFB7A4F1);
  static const lavenderInk = Color(0xFF5B4B8A);
  static const peach = Color(0xFFFFD9C2);
  static const cream = Color(0xFFFFFBFC);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF6E4453);
  static const inkSoft = Color(0xFFAA8090);
}

/// Border lengkung besar agar semua card terasa "glowing" & friendly.
const double kCuteRadius = 24;

BoxDecoration cuteCardDecoration({
  Color color = PinkPalette.white,
  double radius = kCuteRadius,
  Color glowColor = PinkPalette.dustyRose,
  double glowOpacity = 0.28,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: [
      BoxShadow(
        color: glowColor.withValues(alpha: glowOpacity),
        blurRadius: 26,
        offset: const Offset(0, 12),
      ),
    ],
  );
}

ThemeData buildPinkTheme() {
  const scheme = ColorScheme.light(
    primary: PinkPalette.rose,
    onPrimary: PinkPalette.white,
    primaryContainer: PinkPalette.blush,
    onPrimaryContainer: PinkPalette.deepRose,
    secondary: PinkPalette.lavenderDeep,
    onSecondary: PinkPalette.white,
    secondaryContainer: PinkPalette.lavender,
    onSecondaryContainer: PinkPalette.lavenderInk,
    surface: PinkPalette.cream,
    onSurface: PinkPalette.ink,
    error: Color(0xFFE2555F),
    onError: PinkPalette.white,
    outline: PinkPalette.dustyRose,
  );

  final baseText = ThemeData.light().textTheme;

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PinkPalette.softBabyPink,
    splashFactory: InkSparkle.splashFactory,
    textTheme: baseText.apply(
      bodyColor: PinkPalette.ink,
      displayColor: PinkPalette.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: PinkPalette.ink,
      centerTitle: true,
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: PinkPalette.ink,
      contentTextStyle: baseText.bodyMedium?.apply(color: PinkPalette.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCuteRadius),
      ),
    ),
  );
}