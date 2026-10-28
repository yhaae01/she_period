import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/home_shell.dart';
import 'package:she_period/main.dart';
import 'package:she_period/pages/onboarding_page.dart';
import 'package:she_period/pages/splash_screen.dart';
import 'package:she_period/utils/date_format_id.dart';
import 'package:she_period/widgets/cute_mascot.dart';

void main() {
  testWidgets('Pertama kali dibuka: splash -> onboarding -> dashboard', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repository = await CycleRepository.load();

    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MyApp(repository: repository));

    // splash screen tampil dengan loading pink
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('ShePeriod'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(repository.onboardingDone, isFalse);

    // setelah ~2,5 detik -> halaman onboarding (belum pernah setup)
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.textContaining('Kenalan dulu'), findsOneWidget);

    // isi form: nama & usia
    await tester.enterText(find.byKey(const Key('onboard-name')), 'Putri');
    await tester.enterText(find.byKey(const Key('onboard-age')), '26');
    await tester.pump(const Duration(milliseconds: 250));

    // panjang siklus bisa disesuaikan (28 -> 29)
    await tester.ensureVisible(find.byKey(const Key('onboard-cycle-plus')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('onboard-cycle-plus')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('29 hari'), findsOneWidget);

    // HPHT lewat date picker bawaan (default = hari ini)
    await tester.ensureVisible(find.byKey(const Key('onboard-hpht')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('onboard-hpht')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Oke'), findsOneWidget);
    await tester.tap(find.text('Oke'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('HPHT:'), findsOneWidget);

    // tanpa nama -> ditolak dengan snackbar
    await tester.ensureVisible(find.byKey(const Key('onboard-submit')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.enterText(find.byKey(const Key('onboard-name')), '');
    await tester.tap(find.byKey(const Key('onboard-submit')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Isi namamu dulu'), findsOneWidget);
    expect(repository.onboardingDone, isFalse);

    // isi nama lagi lalu submit -> masuk dashboard
    await tester.enterText(find.byKey(const Key('onboard-name')), 'Putri');
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.byKey(const Key('onboard-submit')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(HomeShell), findsOneWidget);
    expect(find.textContaining('Halo Cantik'), findsOneWidget);

    // data terkunci di SharedPreferences
    expect(repository.onboardingDone, isTrue);
    expect(repository.userName, 'Putri');
    expect(repository.userAge, 26);
    expect(repository.cycleLength, 29);
    expect(repository.periodStart, repository.today);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('onboarding_done'), isTrue);
    expect(prefs.getString('user_name'), 'Putri');
    expect(prefs.getInt('user_age'), 26);

    // aplikasi dibuka ulang -> langsung dashboard, tanpa onboarding lagi
    final again = await CycleRepository.load();
    expect(again.onboardingDone, isTrue);
  });

  testWidgets('Dashboard: sapaan, ring, catatan, lalu pindah ke kalender', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'onboarding_done': true});
    final repository = await CycleRepository.load();

    // ukuran layar seperti ponsel
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MyApp(repository: repository));

    // splash screen dulu, lalu (onboarding sudah selesai) ke dashboard
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pump(const Duration(milliseconds: 500));

    // sapaan harian, maskot, & lingkaran siklus
    expect(find.textContaining('Halo Cantik'), findsOneWidget);
    expect(find.textContaining('hari ini gimana perasaannya'), findsOneWidget);
    expect(find.text('dari 28 hari'), findsOneWidget);
    expect(find.textContaining('Siklus 28 hari'), findsOneWidget);
    expect(find.textContaining('Temanmu hari ini'), findsOneWidget);
    expect(find.text('Catat Hari Ini 💗'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('dashboard-mascot')));
    await tester.tap(find.byKey(const Key('dashboard-mascot')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const Key('mascot-message')), findsOneWidget);
    final firstMascotMessage = tester
        .widget<Text>(find.byKey(const Key('mascot-message')))
        .data;
    expect(firstMascotMessage, isNotEmpty);
    await tester.tap(find.byKey(const Key('dashboard-mascot')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<Text>(find.byKey(const Key('mascot-message'))).data,
      isNot(firstMascotMessage),
    );

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

    // tambahkan catatan bebas dan pilih gejala kram
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(
      find.byType(TextField).last,
      'Kram ringan, minum air hangat',
    );
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
    expect(
      repository.noteOf(repository.today)?.text,
      'Kram ringan, minum air hangat',
    );
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
    expect(find.text('Kram ringan, minum air hangat'), findsOneWidget);

    // pilih tanggal kalender dan simpan catatan bebas beserta emoji cepat
    final selectedDate = repository.today.subtract(const Duration(days: 1));
    final selectedDayCell = find.text('${selectedDate.day}').first;
    await tester.ensureVisible(selectedDayCell);
    await tester.tap(selectedDayCell);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Catatan '), findsNothing);
    await tester.ensureVisible(find.text('Tulis catatan harian'));
    await tester.tap(find.text('Tulis catatan harian'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Catatan '), findsOneWidget);
    await tester.enterText(
      find.byType(TextField).last,
      'Sedikit lelah hari ini',
    );
    await tester.ensureVisible(find.text('🥱'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('🥱'));
    await tester.ensureVisible(find.text('Simpan 💗'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tap(find.text('Simpan 💗'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(repository.noteOf(selectedDate)?.text, 'Sedikit lelah hari ini');
    expect(repository.noteOf(selectedDate)?.quickEmoji, '🥱');
    expect(find.text('Sedikit lelah hari ini'), findsWidgets);

    // tanggal masa depan tidak membuka editor dan memberi penjelasan
    final futureDate = repository.today.add(const Duration(days: 2));
    final futureDayCell = find.text('${futureDate.day}').first;
    await tester.ensureVisible(futureDayCell);
    await tester.tap(futureDayCell);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Tulis catatan harian'), findsOneWidget);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(find.textContaining('Catatan harian bisa ditulis'), findsOneWidget);

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
