import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

/// Render maskot Lottie 400x400 dan ambil pixel RGBA mentah.
Future<Uint8List> _render(WidgetTester tester, {required Duration elapsed}) async {
  final raw = await rootBundle.loadString('assets/lottie/bunny.json');
  final comp = await LottieComposition.fromBytes(
      Uint8List.fromList(utf8.encode(raw)));

  await tester.pumpWidget(
    MaterialApp(
      home: Center(
        child: RepaintBoundary(
          key: const Key('mascot-boundary'),
          child: SizedBox(
            width: 400,
            height: 400,
            child: Lottie(composition: comp),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(elapsed);

  final pixels = await tester.runAsync(() async {
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const Key('mascot-boundary')),
    );
    final image = await boundary.toImage(pixelRatio: 1);
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return byteData!.buffer.asUint8List();
  });
  return pixels!;
}

/// Hitung jumlah pixel "gelap" (mata) di dalam kotak area.
int _darkCount(Uint8List px, int x0, int x1, int y0, int y1) {
  var count = 0;
  for (var y = y0; y <= y1; y++) {
    for (var x = x0; x <= x1; x++) {
      final i = (y * 400 + x) * 4;
      if (px[i] < 160 && px[i + 1] < 140 && px[i + 2] < 160) count++;
    }
  }
  return count;
}

void main() {
  testWidgets('maskot lottie ter-render: kepala, mata, pipi, telinga',
      (tester) async {
    // --- fase mata terbuka (awal animasi)
    final open = await _render(tester, elapsed: const Duration(milliseconds: 50));

    int r(int x, int y) => open[(y * 400 + x) * 4];
    int g(int x, int y) => open[(y * 400 + x) * 4 + 1];
    int b(int x, int y) => open[(y * 400 + x) * 4 + 2];

    // kepala putih
    expect(r(200, 150), greaterThan(250));
    expect(g(200, 150), greaterThan(245));
    // telinga dalam pink
    expect(r(155, 80), greaterThan(245));
    expect(g(155, 80), inInclusiveRange(170, 230));
    expect(b(155, 80), greaterThan(190));
    // pipi merona (pink lembut di atas kepala putih)
    expect(r(138, 250), greaterThan(240));
    expect(g(138, 250), inInclusiveRange(180, 235));
    // highlight mata putih (menggantikan mata gelap -> urutan shapes benar)
    expect(r(157, 196), greaterThan(250));
    expect(g(157, 196), greaterThan(250));
    expect(b(157, 196), greaterThan(250));

    // mata terbuka: banyak pixel gelap di kotak mata
    final openDark = _darkCount(open, 148, 182, 190, 240);
    expect(openDark, greaterThan(600));

    // --- fase kedip (frame ~61 dari 90 @ 30fps = 2.03 detik)
    final closed = await _render(
        tester, elapsed: const Duration(milliseconds: 2033));
    final closedDark = _darkCount(closed, 148, 182, 190, 240);
    expect(closedDark, lessThan(450));
    expect(closedDark, greaterThan(0));
  });
}