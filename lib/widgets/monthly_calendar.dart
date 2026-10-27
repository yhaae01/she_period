import 'package:flutter/material.dart';

import '../data/cycle_repository.dart';
import '../models/cycle_phase.dart';
import '../theme/pink_theme.dart';
import 'bounce_tap.dart';

/// Kalender bulanan bulat & lucu: menandai haid (prediksi), masa subur,
/// hari ini, dan hari yang punya catatan.
class MonthlyCalendar extends StatefulWidget {
  const MonthlyCalendar({
    super.key,
    required this.repository,
    required this.selected,
    required this.onSelected,
  });

  final CycleRepository repository;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  late DateTime _month = DateTime(widget.selected.year, widget.selected.month);

  static const _monthNames = [
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

  static const _weekdayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.repository;
    final today = repo.today;
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday - 1; // Senin = 0

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
      decoration: cuteCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              _navButton(Icons.chevron_left, () => _changeMonth(-1)),
              Expanded(
                child: Text(
                  '${_monthNames[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: PinkPalette.ink,
                  ),
                ),
              ),
              _navButton(Icons.chevron_right, () => _changeMonth(1)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final name in _weekdayNames)
                Expanded(
                  child: Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: PinkPalette.inkSoft,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            children: [
              for (var i = 0; i < leading; i++) const SizedBox(),
              for (var day = 1; day <= daysInMonth; day++)
                _dayCell(DateTime(_month.year, _month.month, day), today),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 14,
            runSpacing: 8,
            children: const [
              _LegendDot(color: PinkPalette.dustyRose, label: 'Haid'),
              _LegendDot(color: PinkPalette.blush, label: 'Prediksi haid'),
              _LegendDot(color: PinkPalette.lavender, label: 'Masa subur'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navButton(IconData icon, VoidCallback onTap) {
    return BounceTap(
      minScale: 0.8,
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: PinkPalette.softBabyPink,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: PinkPalette.deepRose),
      ),
    );
  }

  Widget _dayCell(DateTime date, DateTime today) {
    final repo = widget.repository;
    final isPeriod = repo.isPredictedPeriodDay(date);
    final isFuture = date.isAfter(today);
    final isToday = _sameDay(date, today);
    final isSelected = _sameDay(date, widget.selected);
    final phase = repo.phaseOf(date);
    final hasNote = repo.noteOf(date) != null;

    Color? bg;
    Color textColor = PinkPalette.ink;

    if (isPeriod) {
      bg = isFuture ? PinkPalette.blush : PinkPalette.dustyRose;
      textColor = isFuture ? PinkPalette.deepRose : PinkPalette.white;
    } else if (phase == CyclePhase.ovulation) {
      bg = PinkPalette.lavender;
      textColor = PinkPalette.lavenderInk;
    }

    var borderColor = Colors.transparent;
    if (isToday) borderColor = PinkPalette.rose;
    if (isSelected) borderColor = PinkPalette.deepRose;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: BounceTap(
        minScale: 0.85,
        onTap: () => widget.onSelected(date),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutBack,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg ?? PinkPalette.cream,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: PinkPalette.deepRose.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                date.day.toString(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              if (hasNote)
                const Positioned(
                  bottom: 5,
                  child: SizedBox(
                    width: 5,
                    height: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: PinkPalette.deepRose,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: PinkPalette.inkSoft,
          ),
        ),
      ],
    );
  }
}