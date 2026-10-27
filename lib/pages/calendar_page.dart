import 'package:flutter/material.dart';

import '../data/cycle_repository.dart';
import '../models/cycle_phase.dart';
import '../models/log_options.dart';
import '../theme/pink_theme.dart';
import '../widgets/bounce_tap.dart';
import '../widgets/monthly_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.repository});

  final CycleRepository repository;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const _weekday = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const _month = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  late DateTime _selected = widget.repository.today;

  String _dateLabel(DateTime date) =>
      '${_weekday[date.weekday - 1]}, ${date.day} '
      '${_month[date.month - 1]} ${date.year}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _markPeriodStart() {
    final repo = widget.repository;
    repo.markPeriodStart(_selected);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Haid ditandai ${_dateLabel(_selected)} — prediksi diperbarui 💗',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final phase = repo.phaseOf(_selected);
        final cycleDay = repo.cycleDayOf(_selected);
        final nextStart = repo.nextPeriodStart;
        final note = repo.noteOf(_selected);

        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFFFF6FA),
                      PinkPalette.softBabyPink,
                      Color(0xFFF7F1FF),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kalender Siklus 📅',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PinkPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat fase, prediksi haid, dan catatanmu ya 💗',
                      style: textTheme.bodySmall?.copyWith(
                        color: PinkPalette.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCountdownCard(textTheme, nextStart),
                    const SizedBox(height: 16),
                    MonthlyCalendar(
                      repository: repo,
                      selected: _selected,
                      onSelected: (date) => setState(() => _selected = date),
                    ),
                    const SizedBox(height: 16),
                    _buildDayCard(
                      textTheme,
                      phase: phase,
                      cycleDay: cycleDay,
                      hasNote: note != null,
                      mood: note?.mood,
                      symptoms: note?.symptoms ?? const <int>[],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------- kartu hitung mundur

  Widget _buildCountdownCard(TextTheme textTheme, DateTime nextStart) {
    final repo = widget.repository;
    final daysLeft = repo.daysUntilNextPeriod;
    final isToday = _sameDay(nextStart, repo.today);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cuteCardDecoration(
        color: PinkPalette.white,
        glowColor: PinkPalette.rose,
        glowOpacity: 0.3,
      ),
      child: Row(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Haid mulai hari ini!' : '$daysLeft hari lagi',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PinkPalette.deepRose,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Perkiraan haid berikutnya: ${_dateLabel(nextStart)}',
                  style: textTheme.bodySmall?.copyWith(
                    color: PinkPalette.inkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------- kartu hari terpilih

  Widget _buildDayCard(
    TextTheme textTheme, {
    required CyclePhase phase,
    required int cycleDay,
    required bool hasNote,
    required int? mood,
    required List<int> symptoms,
  }) {
    final repo = widget.repository;
    final canMark = !_selected.isAfter(repo.today);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cuteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _dateLabel(_selected),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: PinkPalette.ink,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chip('💗', 'Hari ke-$cycleDay', textTheme),
              _chip(phase.accessory, phase.label, textTheme),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            phase.note,
            style: textTheme.bodySmall?.copyWith(
              color: PinkPalette.inkSoft,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (hasNote) _buildNote(textTheme, mood, symptoms) else
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PinkPalette.softBabyPink,
                borderRadius: BorderRadius.circular(kCuteRadius),
              ),
              child: Text(
                'Belum ada catatan di hari ini 🐰',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: PinkPalette.inkSoft,
                ),
              ),
            ),
          const SizedBox(height: 16),
          if (canMark)
            BounceTap(
              minScale: 0.95,
              onTap: _markPeriodStart,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: PinkPalette.dustyRose,
                  borderRadius: BorderRadius.circular(kCuteRadius),
                ),
                child: const Text(
                  'Tandai hari pertama haid 🩸',
                  style: TextStyle(
                    color: PinkPalette.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            Text(
              'Belum bisa menandai tanggal di masa depan 🙈',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: PinkPalette.inkSoft),
            ),
        ],
      ),
    );
  }

  Widget _buildNote(TextTheme textTheme, int? mood, List<int> symptoms) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PinkPalette.lavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kCuteRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mood != null)
            Text(
              'Mood: ${kMoods[mood].emoji} ${kMoods[mood].label}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PinkPalette.ink,
              ),
            ),
          if (symptoms.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final index in symptoms)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: PinkPalette.white,
                      borderRadius: BorderRadius.circular(kCuteRadius),
                      border: Border.all(color: PinkPalette.lavenderDeep),
                    ),
                    child: Text(
                      '${kSymptoms[index].emoji} ${kSymptoms[index].label}',
                      style: textTheme.labelSmall?.copyWith(
                        color: PinkPalette.lavenderInk,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String emoji, String label, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: PinkPalette.softBabyPink,
        borderRadius: BorderRadius.circular(kCuteRadius),
        border: Border.all(color: PinkPalette.blush),
      ),
      child: Text(
        '$emoji $label',
        style: textTheme.labelMedium?.copyWith(
          color: PinkPalette.deepRose,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}