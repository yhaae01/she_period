import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_predictions.dart';
import '../models/cycle_phase.dart';

/// Catatan harian: mood (index dari `kMoods`) & gejala (index `kSymptoms`).
class DayNote {
  const DayNote({
    this.mood,
    this.symptoms = const <int>[],
    this.text = '',
    this.quickEmoji,
  });

  final int? mood;
  final List<int> symptoms;
  final String text;
  final String? quickEmoji;

  bool get isEmpty =>
      mood == null &&
      symptoms.isEmpty &&
      text.trim().isEmpty &&
      quickEmoji == null;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mood': mood,
    'symptoms': symptoms,
    'text': text,
    'quickEmoji': quickEmoji,
  };

  factory DayNote.fromJson(Map<String, dynamic> json) => DayNote(
    mood: json['mood'] as int?,
    symptoms:
        (json['symptoms'] as List<dynamic>?)?.cast<int>() ?? const <int>[],
    text: json['text'] as String? ?? '',
    quickEmoji: json['quickEmoji'] as String?,
  );
}

/// Penyimpanan data siklus & catatan harian via `shared_preferences`.
///
/// Semua perubahan memanggil [notifyListeners] supaya UI (dashboard,
/// kalender) ikut menyegarkan diri.
class CycleRepository extends ChangeNotifier {
  CycleRepository._(this._prefs)
    : _periodStart = DateTime.now().subtract(const Duration(days: 13)),
      _cycleLength = 28,
      _periodLength = 5,
      _notificationsEnabled = true,
      _onboardingDone = false,
      _userName = '',
      _notes = <String, DayNote>{} {
    _read();
  }

  /// Muat data tersimpan (atau pakai default pertama kali dijalankan).
  static Future<CycleRepository> load() async {
    final prefs = await SharedPreferences.getInstance();
    return CycleRepository._(prefs);
  }

  static const _kPeriodStart = 'period_start';
  static const _kCycleLength = 'cycle_length';
  static const _kPeriodLength = 'period_length';
  static const _kNotes = 'day_notes';
  static const _kHistory = 'period_history';
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kOnboardingDone = 'onboarding_done';
  static const _kUserName = 'user_name';
  static const _kUserAge = 'user_age';

  /// Batas pengaturan siklus & lama haid.
  static const minCycleLength = 21;
  static const maxCycleLength = 45;
  static const minPeriodLength = 1;
  static const maxPeriodLength = 10;

  static int _clamp(int value, int min, int max) =>
      value < min ? min : (value > max ? max : value);

  final SharedPreferences _prefs;

  DateTime _periodStart;
  int _cycleLength;
  int _periodLength;
  bool _notificationsEnabled;
  bool _onboardingDone;
  String _userName;
  int? _userAge;
  final Map<String, DayNote> _notes;
  final List<DateTime> _history = <DateTime>[];

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static DateTime _onlyDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _read() {
    // default: hari pertama haid 13 hari lalu (dibulatkan ke awal hari)
    _periodStart = _onlyDate(_periodStart);

    final start = _prefs.getString(_kPeriodStart);
    if (start != null) {
      final parsed = DateTime.tryParse(start);
      if (parsed != null) _periodStart = _onlyDate(parsed);
    }
    _cycleLength = _prefs.getInt(_kCycleLength) ?? _cycleLength;
    _periodLength = _prefs.getInt(_kPeriodLength) ?? _periodLength;

    final raw = _prefs.getString(_kNotes);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          _notes[entry.key] = DayNote.fromJson(
            entry.value as Map<String, dynamic>,
          );
        }
      } on FormatException {
        // data rusak -> mulai bersih, jangan crash
        _notes.clear();
      }
    }
    // Catatan baru disimpan terpisah per tanggal. Baca juga format agregat lama
    // agar data pengguna dari versi sebelumnya tetap tersedia.
    for (final key in _prefs.getKeys().where(
      (key) => key.startsWith('note_'),
    )) {
      final date = key.substring('note_'.length);
      final noteJson = _prefs.getString(key);
      if (noteJson == null) continue;
      try {
        _notes[date] = DayNote.fromJson(
          jsonDecode(noteJson) as Map<String, dynamic>,
        );
      } on FormatException {
        // Abaikan satu catatan rusak tanpa mengganggu catatan lain.
      }
    }

    _notificationsEnabled = _prefs.getBool(_kNotificationsEnabled) ?? true;

    // status onboarding & profil
    _onboardingDone = _prefs.getBool(_kOnboardingDone) ?? false;
    _userName = _prefs.getString(_kUserName) ?? '';
    _userAge = _prefs.getInt(_kUserAge);

    // riwayat HPHT
    _history.clear();
    final rawHistory = _prefs.getString(_kHistory);
    if (rawHistory != null && rawHistory.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawHistory) as List<dynamic>;
        _history.addAll(
          decoded.map((e) => _onlyDate(DateTime.parse(e as String))),
        );
      } on FormatException {
        _history.clear();
      }
    }
    if (!_history.contains(_periodStart)) _history.add(_periodStart);
    _sortHistory();
  }

  void _sortHistory() {
    _history.sort((a, b) => b.compareTo(a));
    if (_history.length > 36) {
      _history.removeRange(36, _history.length);
    }
  }

  /// Semua nilai ditulis sinkron ke cache [SharedPreferences]
  /// supaya pembacaan ulang langsung konsisten.
  void _persist() {
    _prefs.setString(
      _kNotes,
      jsonEncode(_notes.map((key, value) => MapEntry(key, value.toJson()))),
    );
    _prefs.setString(_kPeriodStart, _periodStart.toIso8601String());
    _prefs.setInt(_kCycleLength, _cycleLength);
    _prefs.setInt(_kPeriodLength, _periodLength);
    _prefs.setString(
      _kHistory,
      jsonEncode(_history.map((d) => d.toIso8601String()).toList()),
    );
    _prefs.setBool(_kNotificationsEnabled, _notificationsEnabled);
  }

  // ------------------------------------------------------------- getters

  DateTime get periodStart => _periodStart;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
  bool get notificationsEnabled => _notificationsEnabled;

  /// Apakah pengguna sudah menyelesaikan layar Onboarding.
  bool get onboardingDone => _onboardingDone;

  /// Nama pengguna (dari layar Onboarding).
  String get userName => _userName;

  /// Usia pengguna (dari layar Onboarding).
  int? get userAge => _userAge;

  /// Riwayat HPHT (tanggal hari pertama haid), terbaru di depan.
  List<DateTime> get history => List.unmodifiable(_history);

  /// Ubah panjang siklus (rata-rata), mis. 28 atau 30 hari.
  void setCycleLength(int value) {
    final next = _clamp(value, minCycleLength, maxCycleLength);
    if (next == _cycleLength) return;
    _cycleLength = next;
    _persist();
    notifyListeners();
  }

  /// Ubah lama haid, mis. 5 hari.
  void setPeriodLength(int value) {
    final next = _clamp(value, minPeriodLength, maxPeriodLength);
    if (next == _periodLength) return;
    _periodLength = next;
    _persist();
    notifyListeners();
  }

  /// Selesaikan Onboarding: kunci data diri + HPHT + panjang siklus
  /// ke SharedPreferences, lalu tandai setup selesai.
  void completeOnboarding({
    required String name,
    required int age,
    required DateTime hpht,
    required int cycleLength,
  }) {
    _onboardingDone = true;
    _userName = name.trim();
    _userAge = age;
    _prefs.setBool(_kOnboardingDone, true);
    _prefs.setString(_kUserName, _userName);
    _prefs.setInt(_kUserAge, age);
    markPeriodStart(hpht);
    setCycleLength(cycleLength);
    notifyListeners();
  }

  /// Kembalikan ke default: siklus 28 hari, haid 5 hari.
  void resetCycleSettings() {
    setCycleLength(28);
    setPeriodLength(5);
  }

  /// Nyalakan / matikan pengingat.
  void setNotificationsEnabled(bool enabled) {
    if (enabled == _notificationsEnabled) return;
    _notificationsEnabled = enabled;
    _persist();
    notifyListeners();
  }

  DateTime get today => _onlyDate(DateTime.now());

  /// Hari ke berapa siklus untuk tanggal [date] (1 = hari pertama haid).
  int cycleDayOf(DateTime date) {
    final diff = _onlyDate(date).difference(_periodStart).inDays;
    final normalized = ((diff % _cycleLength) + _cycleLength) % _cycleLength;
    return normalized + 1;
  }

  /// Fase siklus untuk tanggal [date].
  CyclePhase phaseOf(DateTime date) => CyclePhaseInfo.fromDay(
    cycleDayOf(date),
    _cycleLength,
    periodLength: _periodLength,
  );

  /// Perkiraan hari haid untuk tanggal [date].
  bool isPredictedPeriodDay(DateTime date) => cycleDayOf(date) <= _periodLength;

  /// Tanggal perkiraan haid berikutnya (>= hari ini).
  DateTime get nextPeriodStart {
    final now = today;
    var start = _periodStart;
    while (start.isBefore(now)) {
      start = start.add(Duration(days: _cycleLength));
    }
    return start;
  }

  /// Semua perhitungan prediksi siklus (selesai haid, ovulasi,
  /// masa subur, haid berikutnya) dari HPHT yang tersimpan.
  CyclePredictions get predictions => CyclePredictions(
    hpht: _periodStart,
    cycleLength: _cycleLength,
    periodLength: _periodLength,
  );

  /// Berapa hari lagi haid berikutnya (0 = hari ini).
  int get daysUntilNextPeriod => nextPeriodStart.difference(today).inDays;

  // ---------------------------------------------------------------- notes

  DayNote? noteOf(DateTime date) => _notes[dateKey(date)];

  void setNote(DateTime date, DayNote note) {
    final key = dateKey(date);
    if (note.isEmpty) {
      _notes.remove(key);
      _prefs.remove('note_$key');
    } else {
      _notes[key] = note;
      _prefs.setString('note_$key', jsonEncode(note.toJson()));
    }
    _persist();
    notifyListeners();
  }

  /// Tandai [date] sebagai hari pertama haid (menggeser prediksi siklus)
  /// dan mencatatnya ke riwayat.
  void markPeriodStart(DateTime date) {
    final day = _onlyDate(date);
    if (day.isAfter(today)) return;
    _periodStart = day;
    if (!_history.contains(day)) _history.add(day);
    _sortHistory();
    _persist();
    notifyListeners();
  }
}
