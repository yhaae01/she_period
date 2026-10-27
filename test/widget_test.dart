import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/main.dart';
import 'package:she_period/utils/date_format_id.dart';
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

    // pindah ke tab kalender
    await tester.tap(find.text('Kalender'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.textContaining('Kalender Siklus'), findsOneWidget);
    expect(find.textContaining('Perkiraan haid berikutnya'), findsOneWidget);
    expect(find.text('Sen'), findsOneWidget);
    expect(find.textContaining('Hari ke-'), findsWidgets);
    expect(find.textContaining('Riwayat Haid'), findsOneWidget);
    expect(find.textContaining('HPHT aktif'), findsOneWidget);

    // tab Atur: kustomisasi panjang siklus & lama haid
    await tester.tap(find.text('Atur'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('Pengaturan'), findsOneWidget);
    expect(repository.cycleLength, 28);
    expect(repository.periodLength, 5);

    await tester.ensureVisible(find.byKey(const Key('cycle-length-plus')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('cycle-length-plus')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.cycleLength, 29);

    await tester.ensureVisible(find.byKey(const Key('period-length-minus')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('period-length-minus')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.periodLength, 4);

    // preview prediksi ikut menyesuaikan
    final nextStart = repository.predictions.nextPeriodStart;
    expect(find.textContaining(formatDate(nextStart)), findsWidgets);

    // sakelar pengingat bisa dimatikan/dinyalakan
    expect(repository.notificationsEnabled, isTrue);
    await tester.ensureVisible(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.notificationsEnabled, isFalse);
    await tester.tap(find.byType(Switch));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.notificationsEnabled, isTrue);

    // tombol reset ke default
    await tester.ensureVisible(find.textContaining('Kembalikan default'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.textContaining('Kembalikan default'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(repository.cycleLength, 28);
    expect(repository.periodLength, 5);

    // kembali ke beranda
    await tester.tap(find.text('Beranda'));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.textContaining('Halo Cantik'), findsOneWidget);
  });
}