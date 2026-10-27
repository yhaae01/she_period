import 'package:flutter/material.dart';

import '../data/cycle_repository.dart';
import '../models/cycle_predictions.dart';
import '../services/notification_service.dart';
import '../theme/pink_theme.dart';
import '../utils/date_format_id.dart';
import '../widgets/bounce_tap.dart';

/// Pengaturan siklus: panjang siklus & lama haid bisa dikustomisasi,
/// plus sakelar pengingat.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.repository});

  final CycleRepository repository;

  void _toggleReminder(BuildContext context, bool enabled) {
    repository.setNotificationsEnabled(enabled);
    if (enabled) {
      NotificationService.instance.syncFrom(repository);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Pengingat menyala 🔔 kami ingatkan 3 hari sebelum haid',
            ),
          ),
        );
    } else {
      NotificationService.instance.cancelAll();
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('Pengingat dimatikan 💤')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListenableBuilder(
      listenable: repository,
      builder: (context, _) {
        final prediction = repository.predictions;

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
                      'Pengaturan ⚙️',
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PinkPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Siklusmu bisa dikustomisasi sesuai tubuhmu 💗',
                      style: textTheme.bodySmall?.copyWith(
                        color: PinkPalette.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCycleCard(context, textTheme, prediction),
                    const SizedBox(height: 16),
                    _buildReminderCard(context, textTheme),
                    const SizedBox(height: 16),
                    _buildResetCard(textTheme),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------ kartu siklus custom

  Widget _buildCycleCard(
    BuildContext context,
    TextTheme textTheme,
    CyclePredictions prediction,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cuteCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Siklus & Haid 🌡️',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: PinkPalette.ink,
            ),
          ),
          const SizedBox(height: 14),
          _StepperRow(
            emoji: '🌙',
            label: 'Panjang siklus',
            value: repository.cycleLength,
            unit: 'hari',
            minusKey: const Key('cycle-length-minus'),
            plusKey: const Key('cycle-length-plus'),
            min: CycleRepository.minCycleLength,
            max: CycleRepository.maxCycleLength,
            onChanged: repository.setCycleLength,
          ),
          const Divider(height: 26, color: PinkPalette.blush),
          _StepperRow(
            emoji: '🩸',
            label: 'Lama haid',
            value: repository.periodLength,
            unit: 'hari',
            minusKey: const Key('period-length-minus'),
            plusKey: const Key('period-length-plus'),
            min: CycleRepository.minPeriodLength,
            max: CycleRepository.maxPeriodLength,
            onChanged: repository.setPeriodLength,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PinkPalette.softBabyPink,
              borderRadius: BorderRadius.circular(kCuteRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _previewRow(
                  textTheme,
                  'Haid sekarang',
                  '${formatDate(prediction.startDate)} – '
                      '${formatDate(prediction.periodEndDate)}',
                ),
                const SizedBox(height: 6),
                _previewRow(
                  textTheme,
                  'Prediksi haid berikutnya',
                  '${formatDate(prediction.nextPeriodStart)} '
                      '(${prediction.cycleLength} hari lagi)',
                ),
                const SizedBox(height: 6),
                _previewRow(
                  textTheme,
                  'Masa subur',
                  formatDateRange(
                    prediction.fertileWindowStart,
                    prediction.fertileWindowEnd,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _previewRow(TextTheme textTheme, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(color: PinkPalette.inkSoft),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodySmall?.copyWith(
              color: PinkPalette.deepRose,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------- kartu pengingat

  Widget _buildReminderCard(BuildContext context, TextTheme textTheme) {
    final enabled = repository.notificationsEnabled;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cuteCardDecoration(
        color: PinkPalette.cream,
        glowColor: PinkPalette.lavenderDeep,
        glowOpacity: 0.3,
      ),
      child: Row(
        children: [
          Text(enabled ? '🔔' : '💤', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengingat haid & masa subur',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PinkPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? 'Kami ingatkan 3 hari sebelum haid & saat masa subur'
                      : 'Pengingat sedang dimatikan',
                  style: textTheme.bodySmall?.copyWith(
                    color: PinkPalette.inkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: enabled,
            activeThumbColor: PinkPalette.white,
            activeTrackColor: PinkPalette.rose,
            inactiveThumbColor: PinkPalette.white,
            inactiveTrackColor: PinkPalette.blush,
            onChanged: (value) => _toggleReminder(context, value),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ reset default

  Widget _buildResetCard(TextTheme textTheme) {
    return BounceTap(
      minScale: 0.96,
      onTap: repository.resetCycleSettings,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: PinkPalette.white,
          borderRadius: BorderRadius.circular(kCuteRadius),
          border: Border.all(color: PinkPalette.blush),
        ),
        child: Text(
          'Kembalikan default (28 & 5 hari) 🐰',
          style: textTheme.titleSmall?.copyWith(
            color: PinkPalette.deepRose,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

/// Baris tombol minus/plus untuk angka pengaturan.
class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.emoji,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.minusKey,
    required this.plusKey,
  });

  final String emoji;
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final Key minusKey;
  final Key plusKey;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PinkPalette.ink,
                ),
              ),
              Text(
                '$min – $max $unit',
                style: textTheme.labelSmall?.copyWith(
                  color: PinkPalette.inkSoft,
                ),
              ),
            ],
          ),
        ),
        _stepButton(
          key: minusKey,
          icon: Icons.remove,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 54,
          child: Column(
            children: [
              Text(
                '$value',
                style: textTheme.titleLarge?.copyWith(
                  color: PinkPalette.deepRose,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                unit,
                style: textTheme.labelSmall?.copyWith(
                  color: PinkPalette.inkSoft,
                ),
              ),
            ],
          ),
        ),
        _stepButton(
          key: plusKey,
          icon: Icons.add,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }

  Widget _stepButton({
    required Key key,
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return BounceTap(
      key: key,
      minScale: 0.8,
      onTap: enabled ? onTap : null,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? PinkPalette.blush : PinkPalette.softBabyPink,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? PinkPalette.deepRose : PinkPalette.inkSoft,
        ),
      ),
    );
  }
}