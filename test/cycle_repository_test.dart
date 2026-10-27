import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/models/cycle_phase.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('siklus default: hari ke-14, fase folikuler, prediksi 28 hari',
      () async {
    final repo = await CycleRepository.load();
    final today = repo.today;

    expect(repo.cycleLength, 28);
    expect(repo.periodLength, 5);
    expect(repo.periodStart, today.subtract(const Duration(days: 13)));
    expect(repo.cycleDayOf(today), 14);
    expect(repo.phaseOf(today), CyclePhase.follicular);
    expect(repo.daysUntilNextPeriod, 15);
    expect(repo.isPredictedPeriodDay(today), isFalse);
    // tanggal masa depan tetap bisa diprediksi
    expect(repo.cycleDayOf(today.add(const Duration(days: 8))), 22);
    expect(repo.phaseOf(today.add(const Duration(days: 8))),
        CyclePhase.pms);
  });

  test('catatan harian tersimpan dan terbaca lagi', () async {
    final repo = await CycleRepository.load();
    final today = repo.today;

    expect(repo.noteOf(today), isNull);

    repo.setNote(today, const DayNote(mood: 3, symptoms: [0, 2]));

    // baca ulang dari penyimpanan yang sama
    final reloaded = await CycleRepository.load();
    final note = reloaded.noteOf(today);
    expect(note, isNotNull);
    expect(note!.mood, 3);
    expect(note.symptoms, [0, 2]);

    // catatan kosong dihapus
    reloaded.setNote(today, const DayNote());
    expect(reloaded.noteOf(today), isNull);
  });

  test('menandai hari pertama haid menggeser prediksi', () async {
    final repo = await CycleRepository.load();
    final today = repo.today;

    repo.markPeriodStart(today);

    expect(repo.periodStart, today);
    expect(repo.cycleDayOf(today), 1);
    expect(repo.phaseOf(today), CyclePhase.period);
    expect(repo.isPredictedPeriodDay(today), isTrue);
    expect(repo.daysUntilNextPeriod, 0);

    // tanggal di masa depan diabaikan
    repo.markPeriodStart(today.add(const Duration(days: 3)));
    expect(repo.periodStart, today);
  });

  test('menandai siklus lebih pendek dari 28 tetap konsisten', () async {
    final repo = await CycleRepository.load();
    repo.markPeriodStart(repo.today.subtract(const Duration(days: 2)));

    expect(repo.cycleDayOf(repo.today), 3);
    expect(repo.phaseOf(repo.today), CyclePhase.period);
    expect(repo.phaseOf(repo.today.add(const Duration(days: 4))),
        CyclePhase.follicular);
  });
}