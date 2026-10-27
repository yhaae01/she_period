import 'package:flutter/material.dart';

import 'models/cycle_phase.dart';
import 'theme/pink_theme.dart';
import 'widgets/bounce_tap.dart';
import 'widgets/cute_mascot.dart';
import 'widgets/cycle_ring.dart';

/// Opsi mood harian (emoji ekspresif).
const kMoods = <({String emoji, String label})>[
  (emoji: '😊', label: 'Senang'),
  (emoji: '🥰', label: 'Sayang'),
  (emoji: '😐', label: 'Biasa aja'),
  (emoji: '😢', label: 'Sedih'),
  (emoji: '😤', label: 'Geram'),
];

/// Opsi pencatatan gejala harian.
const kSymptoms = <({String emoji, String label})>[
  (emoji: '🩸', label: 'Kram'),
  (emoji: '🤕', label: 'Sakit kepala'),
  (emoji: '🍽️', label: 'Ngidam'),
  (emoji: '🥱', label: 'Lelah'),
  (emoji: '🌧️', label: 'Mood swing'),
  (emoji: '🌡️', label: 'Meriang'),
];

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final int _day = 14;
  final int _cycleLength = 28;
  int? _moodIndex;
  final Set<int> _symptomIndexes = <int>{};

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

  String get _todayLabel {
    final now = DateTime.now();
    return '${_weekday[now.weekday - 1]}, ${now.day} '
        '${_month[now.month - 1]} ${now.year}';
  }

  CyclePhase get _phase => CyclePhaseInfo.fromDay(_day, _cycleLength);

  void _toggleSymptom(int index) {
    setState(() {
      if (!_symptomIndexes.remove(index)) _symptomIndexes.add(index);
    });
  }

  void _saveToday() {
    final mood = _moodIndex == null ? null : kMoods[_moodIndex!];
    final symptoms =
        _symptomIndexes.map((i) => kSymptoms[i].label).join(', ');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            mood == null && symptoms.isEmpty
                ? 'Belum ada catatan nih, isi dulu ya 💗'
                : 'Tersimpan! ${mood?.emoji ?? '💗'}'
                    '${symptoms.isEmpty ? '' : ' • $symptoms'} 💗',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final phase = _phase;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // latar gradien pink lembut -> lavender
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
          // hiasan lucu di pojok layar
          const Positioned(
            top: 46,
            left: 18,
            child: Text('🌸', style: TextStyle(fontSize: 20)),
          ),
          const Positioned(
            top: 96,
            right: 26,
            child: Text('✨', style: TextStyle(fontSize: 18)),
          ),
          const Positioned(
            bottom: 40,
            left: 30,
            child: Text('💗', style: TextStyle(fontSize: 16)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(textTheme, phase),
                  const SizedBox(height: 18),
                  _buildMascotCard(textTheme, phase),
                  const SizedBox(height: 18),
                  _buildRingCard(textTheme, phase),
                  const SizedBox(height: 24),
                  _sectionTitle('Sapaan mood hari ini 💭'),
                  const SizedBox(height: 12),
                  _buildMoodPicker(textTheme),
                  const SizedBox(height: 24),
                  _sectionTitle('Lagi ngerasain apa? 🩰'),
                  const SizedBox(height: 12),
                  _buildSymptomPicker(textTheme),
                  const SizedBox(height: 18),
                  _buildHydrationTip(textTheme, phase),
                  const SizedBox(height: 20),
                  _buildSaveButton(),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Dibuat dengan 💗 untuk Cantik',
                      style: textTheme.bodySmall?.copyWith(
                        color: PinkPalette.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- header

  Widget _buildHeader(TextTheme textTheme, CyclePhase phase) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: PinkPalette.inkSoft,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                phase.greeting,
                style: textTheme.headlineSmall?.copyWith(
                  color: PinkPalette.ink,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: PinkPalette.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: PinkPalette.dustyRose.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Text('💗', style: TextStyle(fontSize: 24)),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- maskot

  Widget _buildMascotCard(TextTheme textTheme, CyclePhase phase) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: cuteCardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temanmu hari ini',
                      style: textTheme.labelSmall?.copyWith(
                        color: PinkPalette.inkSoft,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phase.label,
                      style: textTheme.titleMedium?.copyWith(
                        color: PinkPalette.deepRose,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.elasticOut,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Container(
                  key: ValueKey<CyclePhase>(phase),
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: PinkPalette.lavender,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    phase.accessory,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 165,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: const BoxDecoration(
                    color: PinkPalette.softBabyPink,
                    shape: BoxShape.circle,
                  ),
                ),
                CuteMascot(phase: phase, size: 150),
              ],
            ),
          ),
          Text(
            phase.note,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: PinkPalette.inkSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ ring card

  Widget _buildRingCard(TextTheme textTheme, CyclePhase phase) {
    final daysLeft = _cycleLength - _day + 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: cuteCardDecoration(color: PinkPalette.cream),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _pill('💗', 'Siklus $_cycleLength hari', textTheme),
              ),
              const SizedBox(width: 8),
              Expanded(child: _pill('📅', '$daysLeft hari lagi', textTheme)),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                OrbitingEmojis(
                  radius: 116,
                  emojis: const ['🌸', '💧', '🍓', '🧸'],
                ),
                CycleRing(
                  day: _day,
                  length: _cycleLength,
                  phaseLabel: phase.label,
                ),
              ],
            ),
          ),
          Text(
            'Hari ke-$_day dari $_cycleLength hari • ${phase.label}',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: PinkPalette.inkSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill(String emoji, String label, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: PinkPalette.softBabyPink,
        borderRadius: BorderRadius.circular(kCuteRadius),
        border: Border.all(color: PinkPalette.blush),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$emoji $label',
          style: textTheme.labelMedium?.copyWith(
            color: PinkPalette.deepRose,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- judul

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: PinkPalette.ink,
      ),
    );
  }

  // ---------------------------------------------------------------- mood

  Widget _buildMoodPicker(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: cuteCardDecoration(),
      child: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: [
              for (var i = 0; i < kMoods.length; i++)
                BounceTap(
                  minScale: 0.82,
                  onTap: () => setState(() => _moodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    width: 54,
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _moodIndex == i
                          ? PinkPalette.rose
                          : PinkPalette.softBabyPink,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _moodIndex == i
                            ? PinkPalette.deepRose
                            : PinkPalette.blush,
                        width: 2,
                      ),
                      boxShadow: _moodIndex == i
                          ? [
                              BoxShadow(
                                color: PinkPalette.rose
                                    .withValues(alpha: 0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      kMoods[i].emoji,
                      style: TextStyle(
                        fontSize: 24,
                        color: _moodIndex == i
                            ? PinkPalette.white
                            : null,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _moodIndex == null
                  ? 'Pilih mood kamu dulu ya 💕'
                  : 'Mood hari ini: ${kMoods[_moodIndex!].label} '
                      '${kMoods[_moodIndex!].emoji}',
              key: ValueKey<int?>(_moodIndex),
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: PinkPalette.deepRose,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- gejala

  Widget _buildSymptomPicker(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: cuteCardDecoration(),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (var i = 0; i < kSymptoms.length; i++)
            BounceTap(
              minScale: 0.88,
              onTap: () => _toggleSymptom(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _symptomIndexes.contains(i)
                      ? PinkPalette.blush
                      : PinkPalette.softBabyPink,
                  borderRadius: BorderRadius.circular(kCuteRadius),
                  border: Border.all(
                    color: _symptomIndexes.contains(i)
                        ? PinkPalette.rose
                        : PinkPalette.blush,
                  ),
                ),
                child: Text(
                  '${kSymptoms[i].emoji} ${kSymptoms[i].label}'
                      '${_symptomIndexes.contains(i) ? ' 💗' : ''}',
                  style: textTheme.labelLarge?.copyWith(
                    color: _symptomIndexes.contains(i)
                        ? PinkPalette.deepRose
                        : PinkPalette.inkSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ hidrasi

  Widget _buildHydrationTip(TextTheme textTheme, CyclePhase phase) {
    final needed = phase.needsHydration;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: cuteCardDecoration(
        color: needed ? PinkPalette.peach : PinkPalette.lavender,
        glowColor: needed ? Color(0xFFF5B48A) : PinkPalette.lavenderDeep,
        glowOpacity: 0.35,
      ),
      child: Row(
        children: [
          Text(needed ? '💧' : '🍵', style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  needed ? 'Waktunya hidrasi!' : 'Tetap hangat ya',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: PinkPalette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  needed
                      ? 'Minum air putih 8 gelas hari ini biar segar terus 💦'
                      : 'Teh hangat + pelukan bikin hari jadi lebih ringan 🍵',
                  style: textTheme.bodySmall?.copyWith(
                    color: PinkPalette.ink,
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

  // ---------------------------------------------------------------- CTA

  Widget _buildSaveButton() {
    return BounceTap(
      minScale: 0.94,
      onTap: _saveToday,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 17),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [PinkPalette.rose, PinkPalette.deepRose],
          ),
          borderRadius: BorderRadius.circular(kCuteRadius),
          boxShadow: [
            BoxShadow(
              color: PinkPalette.rose.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Text(
          'Catat Hari Ini 💗',
          style: TextStyle(
            color: PinkPalette.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}