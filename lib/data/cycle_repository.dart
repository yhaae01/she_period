import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cycle_predictions.dart';
import '../models/cycle_phase.dart';

/// Catatan harian: mood (index dari `kMoods`) & gejala (index `kSymptoms`).
class DayNote {
  const DayNote({this.mood, this.symptoms = const <int>[]});

  final int? mood;
  final List<int> symptoms;

  bool get isEmpty => mood == null && symptoms.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'mood': mood,
        'symptoms': symptoms,
      };

  factory DayNote.fromJson(Map<String, dynamic> json) => DayNote(
        mood: json['mood'] as int?,
        symptoms:
            (json['symptoms'] as List<dynamic>?)?.cast<int>() ?? const <int>[],
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

  final SharedPreferences _prefs;

  DateTime _periodStart;
  int _cycleLength;
  int _periodLength;
  final Map<String, DayNote> _notes;

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
          _notes[entry.key] =
              DayNote.fromJson(entry.value as Map<String, dynamic>);
        }
      } on FormatException {
        // data rusak -> mulai bersih, jangan crash
        _notes.clear();
      }
    }
  }

  /// Semua nilai ditulis sinkron ke cache [SharedPreferences]
  /// supaya pembacaan ulang langsung konsisten.
  void _persist() {
    _prefs.setString(_kNotes,
        jsonEncode(_notes.map((key, value) => MapEntry(key, value.toJson()))));
    _prefs.setString(_kPeriodStart, _periodStart.toIso8601String());
    _prefs.setInt(_kCycleLength, _cycleLength);
    _prefs.setInt(_kPeriodLength, _periodLength);
  }

  // ------------------------------------------------------------- getters

  DateTime get periodStart => _periodStart;
  int get cycleLength => _cycleLength;
  int get periodLength => _periodLength;
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
    if (note.isEmpty) {
      _notes.remove(dateKey(date));
    } else {
      _notes[dateKey(date)] = note;
    }
    _persist();
    notifyListeners();
  }

  /// Tandai [date] sebagai hari pertama haid (menggeser prediksi siklus).
  void markPeriodStart(DateTime date) {
    final day = _onlyDate(date);
    if (day.isAfter(today)) return;
    _periodStart = day;
    _persist();
    notifyListeners();
  }
}