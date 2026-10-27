import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/main.dart';
import 'package:she_period/widgets/cute_mascot.dart';

void main() {
  testWidgets('Dashboard: sapaan, ring, catatan, lalu pindah ke kalender',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await CycleRepository.load();

    // ukuran layar seperti ponsel
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MyApp(repository: repository));

    // sapaan harian, maskot, & lingkaran siklus
    expect(find.textContaining('Halo Cantik'), findsOneWidget);
    expect(find.textContaining('hari ini gimana perasaannya'), findsOneWidget);
    expect(find.text('dari 28 hari'), findsOneWidget);
    expect(find.textContaining('Siklus 28 hari'), findsOneWidget);
    expect(find.textContaining('Temanmu hari ini'), findsOneWidget);
    expect(find.text('Catat Hari Ini 💗'), findsOneWidget);

    // maskot memakai animasi Lottie (asset berhasil dimuat, bukan fallback)
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(Lottie), findsOneWidget);
    expect(find.byType(CuteMascot), findsNothing);

    // kartu prediksi otomatis tampil
    expect(find.text('Perkiraan Otomatis ✨'), findsOneWidget);
    expect(find.textContaining('Haid terakhir (HPHT)'), findsOneWidget);
    expect(find.textContaining('Perkiraan selesai haid'), findsOneWidget);
    expect(find.textContaining('Perkiraan hari ovulasi'), findsOneWidget);
    expect(find.textContaining('Perkiraan masa subur'), findsOneWidget);
    expect(find.textContaining('Prediksi haid berikutnya'), findsOneWidget);
    expect(find.textContaining('hari lagi'), findsWidgets);

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

    // simpan catatan -> tersimpan di repository + snackbar
    await tester.ensureVisible(find.text('Catat Hari Ini 💗'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Catat Hari Ini 💗'));
    await tester.pump();
    expect(find.textContaining('Tersimpan'), findsOneWidget);
    expect(repository.noteOf(repository.today)?.mood, 3);
    expect(repository.noteOf(repository.today)?.symptoms, contains(0));
    await tester.pump(const Duration(seconds: 1));

    // buka date picker HPHT & pilih tanggal 1 di bulan yang tampil
    await tester.ensureVisible(find.text('Pilih tanggal haid terakhir 📅'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Pilih tanggal haid terakhir 📅'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byType(DatePickerDialog), findsOneWidget);

    final dialog = find.byType(DatePickerDialog);
    await tester.tap(
      find.descendant(of: dialog, matching: find.text('1')),
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(
      find.descendant(of: dialog, matching: find.text('Oke')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // HPHT tersimpan permanen & prediksi ikut berubah
    expect(repository.periodStart.day, 1);
    expect(find.textContaining('HPHT diperbarui'), findsOneWidget);
    expect(find.textContaining('Perkiraan Otomatis'), findsOneWidget);

    // pindah ke tab kalender
    await tester.tap(find.text('Kalender'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.textContaining('Kalender Siklus'), findsOneWidget);
    expect(find.textContaining('Perkiraan haid berikutnya'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
    expect(find.textContaining('Hari ke-'), findsWidgets);

    // kembali ke beranda
    await tester.tap(find.text('Beranda'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('Halo Cantik'), findsOneWidget);
  });
}