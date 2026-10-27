/// Fase siklus yang menentukan ekspresi maskot & sapaan harian.
enum CyclePhase { period, follicular, ovulation, luteal, pms }

extension CyclePhaseInfo on CyclePhase {
  /// Nama fase yang ditampilkan sebagai chip di dashboard.
  String get label => switch (this) {
        CyclePhase.period => 'Lagi Haid',
        CyclePhase.follicular => 'Fase Folikuler',
        CyclePhase.ovulation => 'Masa Subur',
        CyclePhase.luteal => 'Fase Luteal',
        CyclePhase.pms => 'PMS Nih',
      };

  /// Aksesori lucu yang dipakai kelinci sesuai fase.
  String get accessory => switch (this) {
        CyclePhase.period => '🧸',
        CyclePhase.follicular => '🌸',
        CyclePhase.ovulation => '💧',
        CyclePhase.luteal => '🍓',
        CyclePhase.pms => '🍵',
      };

  /// Kalimat pendamping yang lembut & memotivasi.
  String get note => switch (this) {
        CyclePhase.period =>
          'Peluk dirimu sendiri hari ini ya, Sayang. Tidur yang cukup 🧸',
        CyclePhase.follicular =>
          'Energi mulai naik nih, waktu yang enak buat jalan-jalan 🌸',
        CyclePhase.ovulation =>
          'Puncak kesuburan, jangan lupa minum air putih ya 💧',
        CyclePhase.luteal =>
          'Lagi pengen camilan? Wajar kok, pilih yang manisnya alami 🍓',
        CyclePhase.pms => 'PMS boleh, nangis juga boleh. Aku ada di sini 🍵',
      };

  /// Sapaan pembuka di bagian atas dashboard.
  String get greeting => switch (this) {
        CyclePhase.period => 'Halo Cantik, hari ini gimana perasaannya? 🧸',
        CyclePhase.follicular => 'Halo Cantik, hari ini gimana perasaannya? 🌸',
        CyclePhase.ovulation => 'Halo Cantik, hari ini gimana perasaannya? ✨',
        CyclePhase.luteal => 'Halo Cantik, hari ini gimana perasaannya? 🍓',
        CyclePhase.pms => 'Halo Cantik, hari ini gimana perasaannya? 🍵',
      };

  /// Saat kelinci perlu "membawa botol minum" (hidrasi).
  bool get needsHydration =>
      this == CyclePhase.ovulation || this == CyclePhase.luteal;

  /// Saat kelinci memakai selimut (PMS / haid).
  bool get needsBlanket =>
      this == CyclePhase.period || this == CyclePhase.pms;

  /// Hari pertama haid diperkirakan `periodLength` hari setelah hari terakhir.
  static CyclePhase fromDay(int day, int cycleLength, {int periodLength = 5}) {
    if (day <= periodLength) return CyclePhase.period;

    final ovulationStart = cycleLength - 13 > periodLength
        ? cycleLength - 13
        : periodLength + 1;
    final ovulationEnd =
        ovulationStart > cycleLength - 10 ? ovulationStart : cycleLength - 10;

    if (day >= ovulationStart && day <= ovulationEnd) {
      return CyclePhase.ovulation;
    }
    if (day > ovulationEnd && day <= cycleLength - 7) {
      return CyclePhase.luteal;
    }
    if (day > cycleLength - 7) return CyclePhase.pms;

    return CyclePhase.follicular;
  }
}