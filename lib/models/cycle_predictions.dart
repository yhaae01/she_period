/// Logika perhitungan siklus haid (HPHT-based) murni [DateTime].
///
/// Semua tanggal dibulatkan ke awal hari (tanpa jam) supaya aman
/// dibandingkan dan ditampilkan.
class CyclePredictions {
  const CyclePredictions({
    required this.hpht,
    required this.cycleLength,
    required this.periodLength,
  });

  /// Hari Pertama Haid Terakhir (tanggal yang dipilih pengguna).
  final DateTime hpht;

  /// Rata-rata panjang siklus (mis. 28 atau 30 hari).
  final int cycleLength;

  /// Rata-rata lama haid dalam hari (mis. 5 hari).
  final int periodLength;

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// HPHT dibulatkan ke awal hari.
  DateTime get startDate => _dateOnly(hpht);

  /// Hari ke-N siklus untuk tanggal [date] (1 = hari pertama haid).
  int cycleDayOf(DateTime date) {
    final diff = _dateOnly(date).difference(startDate).inDays;
    return ((diff % cycleLength) + cycleLength) % cycleLength + 1;
  }

  /// Perkiraan **tanggal selesai haid** = HPHT + (lama haid - 1),
  /// karena HPHT dihitung sebagai hari pertama.
  ///
  /// Contoh: HPHT 27 Okt, lama haid 5 hari -> selesai 31 Okt.
  DateTime get periodEndDate =>
      startDate.add(Duration(days: periodLength - 1));

  /// Perkiraan **tanggal haid berikutnya** = HPHT + panjang siklus
  /// (mis. +28 atau 30 hari) — biasanya jatuh di bulan depan.
  DateTime get nextPeriodStart => startDate.add(Duration(days: cycleLength));

  /// Perkiraan haid **bulan setelahnya** (siklus kedua setelah HPHT).
  DateTime get followingPeriodStart =>
      startDate.add(Duration(days: cycleLength * 2));

  /// Tanggal haid siklus ke-[cycleIndex] setelah HPHT (1 = berikutnya).
  DateTime cycleStartAfter(int cycleIndex) =>
      startDate.add(Duration(days: cycleLength * cycleIndex));

  /// Perkiraan **hari ovulasi**: 14 hari sebelum haid berikutnya
  /// (fase luteal rata-rata 14 hari).
  DateTime get ovulationDay =>
      nextPeriodStart.subtract(const Duration(days: 14));

  /// Awal **masa subur**: 5 hari sebelum ovulasi
  /// (sperma dapat bertahan sampai 5 hari).
  DateTime get fertileWindowStart =>
      ovulationDay.subtract(const Duration(days: 5));

  /// Akhir **masa subur**: 1 hari setelah ovulasi (sel telur hidup ~24 jam).
  DateTime get fertileWindowEnd => ovulationDay.add(const Duration(days: 1));

  /// Apakah [date] jatuh di masa subur (siklus ini)?
  bool isFertileDay(DateTime date) {
    final d = _dateOnly(date);
    return !d.isBefore(fertileWindowStart) && !d.isAfter(fertileWindowEnd);
  }

  /// Apakah [date] jatuh di perkiraan haid (siklus ini)?
  bool isPeriodDay(DateTime date) {
    final d = _dateOnly(date);
    return !d.isBefore(startDate) && !d.isAfter(periodEndDate);
  }

  /// Berapa hari lagi sejak [today] menuju haid berikutnya (0 = hari ini).
  int daysUntilNextPeriod(DateTime today) {
    final diff = nextPeriodStart.difference(_dateOnly(today)).inDays;
    return diff < 0 ? 0 : diff;
  }
}