import 'package:flutter_test/flutter_test.dart';

import 'package:she_period/models/cycle_predictions.dart';
import 'package:she_period/utils/date_format_id.dart';

void main() {
  group('CyclePredictions (siklus 28 hari, haid 5 hari)', () {
    // HPHT: Selasa, 27 Oktober 2026
    final p = CyclePredictions(
      hpht: DateTime(2026, 10, 27),
      cycleLength: 28,
      periodLength: 5,
    );

    test('tanggal selesai haid', () {
      expect(p.startDate, DateTime(2026, 10, 27));
      // 5 hari haid: 27, 28, 29, 30, 31 Oktober
      expect(p.periodEndDate, DateTime(2026, 10, 31));
      expect(p.isPeriodDay(DateTime(2026, 10, 31)), isTrue);
      expect(p.isPeriodDay(DateTime(2026, 11, 1)), isFalse);
    });

    test('prediksi haid berikutnya & bulan depan', () {
      // +28 hari dari HPHT -> 24 November 2026 (bulan depan)
      expect(p.nextPeriodStart, DateTime(2026, 11, 24));
      // +56 hari -> siklus kedua
      expect(p.followingPeriodStart, DateTime(2026, 12, 22));
      expect(p.cycleStartAfter(1), DateTime(2026, 11, 24));
      expect(p.cycleStartAfter(2), DateTime(2026, 12, 22));
      expect(p.daysUntilNextPeriod(DateTime(2026, 11, 1)), 23);
      expect(p.daysUntilNextPeriod(DateTime(2026, 11, 24)), 0);
      // lewat dari prediksi -> 0 (tidak negatif)
      expect(p.daysUntilNextPeriod(DateTime(2026, 12, 1)), 0);
    });

    test('ovulasi & masa subur', () {
      // ovulasi = 14 hari sebelum haid berikutnya
      expect(p.ovulationDay, DateTime(2026, 11, 10));
      // jendela subur: 5 hari sebelum sampai 1 hari sesudah ovulasi
      expect(p.fertileWindowStart, DateTime(2026, 11, 5));
      expect(p.fertileWindowEnd, DateTime(2026, 11, 11));

      expect(p.isFertileDay(DateTime(2026, 11, 5)), isTrue);
      expect(p.isFertileDay(DateTime(2026, 11, 11)), isTrue);
      expect(p.isFertileDay(DateTime(2026, 11, 4)), isFalse);
      expect(p.isFertileDay(DateTime(2026, 11, 12)), isFalse);
    });

    test('hari ke-N siklus', () {
      expect(p.cycleDayOf(DateTime(2026, 10, 27)), 1);
      expect(p.cycleDayOf(DateTime(2026, 11, 1)), 6);
      expect(p.cycleDayOf(DateTime(2026, 11, 24)), 1);
      // tanggal sebelum HPHT tetap wrap ke siklus sebelumnya
      expect(p.cycleDayOf(DateTime(2026, 10, 26)), 28);
    });

    test('siklus 30 hari menggeser semua prediksi', () {
      final p30 = CyclePredictions(
        hpht: DateTime(2026, 10, 27),
        cycleLength: 30,
        periodLength: 5,
      );
      expect(p30.nextPeriodStart, DateTime(2026, 11, 26));
      expect(p30.ovulationDay, DateTime(2026, 11, 12));
      expect(p30.fertileWindowStart, DateTime(2026, 11, 7));
      expect(p30.periodEndDate, DateTime(2026, 10, 31));
    });
  });

  group('format tanggal Indonesia', () {
    test('format penuh', () {
      expect(formatFullDate(DateTime(2026, 10, 27)), 'Selasa, 27 Oktober 2026');
      expect(formatDate(DateTime(2026, 11, 24)), '24 November 2026');
      expect(formatDayMonth(DateTime(2026, 12, 22)), '22 Desember');
    });

    test('rentang tanggal', () {
      expect(
        formatDateRange(DateTime(2026, 11, 5), DateTime(2026, 11, 11)),
        '5–11 November 2026',
      );
      expect(
        formatDateRange(DateTime(2026, 10, 30), DateTime(2026, 11, 5)),
        '30 Oktober – 5 November 2026',
      );
    });
  });
}