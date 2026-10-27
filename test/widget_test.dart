import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:she_period/main.dart';

void main() {
  testWidgets('Dashboard menampilkan sapaan, ring, dan interaksi lucu',
      (WidgetTester tester) async {
    // ukuran layar seperti ponsel
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MyApp());

    // sapaan harian, maskot, & lingkaran siklus
    expect(find.textContaining('Halo Cantik'), findsOneWidget);
    expect(find.textContaining('hari ini gimana perasaannya'), findsOneWidget);
    expect(find.text('dari 28 hari'), findsOneWidget);
    expect(find.textContaining('Siklus 28 hari'), findsOneWidget);
    expect(find.textContaining('Temanmu hari ini'), findsOneWidget);

    // tombol CTA
    expect(find.text('Catat Hari Ini 💗'), findsOneWidget);

    // pilih mood
    await tester.ensureVisible(find.text('😢'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('😢'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Mood hari ini: Sedih'), findsOneWidget);

    // pilih gejala kram
    await tester.ensureVisible(find.text('🩸 Kram'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('🩸 Kram'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('Kram 💗'), findsOneWidget);

    // simpan catatan -> muncul snackbar
    await tester.ensureVisible(find.text('Catat Hari Ini 💗'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Catat Hari Ini 💗'));
    await tester.pump();
    expect(find.textContaining('Tersimpan'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}