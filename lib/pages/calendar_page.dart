import 'package:flutter/material.dart';

import '../data/cycle_repository.dart';
import '../models/cycle_phase.dart';
import '../models/log_options.dart';
import '../theme/pink_theme.dart';
import '../utils/date_format_id.dart';
import '../widgets/bounce_tap.dart';
import '../widgets/monthly_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, required this.repository});

  final CycleRepository repository;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selected = widget.repository.today;

  String _dateLabel(DateTime date) => formatFullDate(date);

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _showNoteDialog(DateTime date) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DayNoteSheet(repository: widget.repository, date: date),
  );

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
                      note: note,
                    ),
                    const SizedBox(height: 16),
                    _buildHistoryCard(textTheme),
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
    required DayNote? note,
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
          if (note != null)
            _buildNote(textTheme, note)
          else
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
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _showNoteDialog(_selected),
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(note == null ? 'Tulis catatan harian' : 'Edit catatan'),
            style: OutlinedButton.styleFrom(
              foregroundColor: PinkPalette.deepRose,
              side: const BorderSide(color: PinkPalette.blush),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kCuteRadius),
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

  Widget _buildNote(TextTheme textTheme, DayNote note) {
    final mood = note.mood;
    final symptoms = note.symptoms;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PinkPalette.lavender.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(kCuteRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.quickEmoji != null)
            Text(
              'Mood cepat: ${note.quickEmoji}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PinkPalette.deepRose,
              ),
            ),
          if (mood != null)
            Text(
              'Mood: ${kMoods[mood].emoji} ${kMoods[mood].label}',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PinkPalette.ink,
              ),
            ),
          if (note.text.isNotEmpty) ...[
            if (note.quickEmoji != null || mood != null)
              const SizedBox(height: 8),
            Text(
              note.text,
              style: textTheme.bodyMedium?.copyWith(
                color: PinkPalette.ink,
                height: 1.4,
              ),
            ),
          ],
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

  // ------------------------------------------------------- riwayat haid

  void _setHpht(DateTime date) {
    final repo = widget.repository;
    repo.markPeriodStart(date);
    setState(() => _selected = date);
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('HPHT dipindah ke ${formatFullDate(date)} 💗')),
      );
  }

  Widget _buildHistoryCard(TextTheme textTheme) {
    final repo = widget.repository;
    final items = repo.history.take(8).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cuteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Riwayat Haid 🩸',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: PinkPalette.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ketuk salah satu untuk menjadikan HPHT baru 📅',
            style: textTheme.bodySmall?.copyWith(color: PinkPalette.inkSoft),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _historyTile(textTheme, items[i], repo.periodStart),
          ],
        ],
      ),
    );
  }

  Widget _historyTile(TextTheme textTheme, DateTime date, DateTime active) {
    final isActive = _sameDay(date, active);

    return BounceTap(
      minScale: 0.97,
      onTap: () => _setHpht(date),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? PinkPalette.blush : PinkPalette.softBabyPink,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? PinkPalette.rose : PinkPalette.blush,
          ),
        ),
        child: Row(
          children: [
            Text(isActive ? '📍' : '🩸', style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatFullDate(date),
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PinkPalette.ink,
                ),
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: PinkPalette.rose,
                  borderRadius: BorderRadius.circular(kCuteRadius),
                ),
                child: const Text(
                  'HPHT aktif',
                  style: TextStyle(
                    color: PinkPalette.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
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

class _DayNoteSheet extends StatefulWidget {
  const _DayNoteSheet({required this.repository, required this.date});

  final CycleRepository repository;
  final DateTime date;

  @override
  State<_DayNoteSheet> createState() => _DayNoteSheetState();
}

class _DayNoteSheetState extends State<_DayNoteSheet> {
  static const _quickEmojis = ['😊', '🥱', '🍫', '⚡'];

  late final DayNote? _existing = widget.repository.noteOf(widget.date);
  late final TextEditingController _controller = TextEditingController(
    text: _existing?.text ?? '',
  );
  late String? _selectedEmoji = _existing?.quickEmoji;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        decoration: const BoxDecoration(
          color: PinkPalette.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: PinkPalette.blush,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Catatan ${formatFullDate(widget.date)} 📝',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PinkPalette.ink,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  maxLines: 4,
                  minLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Ceritakan harimu... 💗',
                    filled: true,
                    fillColor: PinkPalette.softBabyPink,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kCuteRadius),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Pilih mood cepat',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: PinkPalette.inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: [
                    for (final emoji in _quickEmojis)
                      ChoiceChip(
                        label: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        selected: _selectedEmoji == emoji,
                        selectedColor: PinkPalette.blush,
                        backgroundColor: PinkPalette.softBabyPink,
                        onSelected: (_) => setState(() {
                          _selectedEmoji = _selectedEmoji == emoji
                              ? null
                              : emoji;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: PinkPalette.dustyRose,
                    foregroundColor: PinkPalette.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kCuteRadius),
                    ),
                  ),
                  onPressed: () {
                    widget.repository.setNote(
                      widget.date,
                      DayNote(
                        mood: _existing?.mood,
                        symptoms: _existing?.symptoms ?? const <int>[],
                        text: _controller.text.trim(),
                        quickEmoji: _selectedEmoji,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Simpan 💗',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
