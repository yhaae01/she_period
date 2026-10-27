import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cycle_repository.dart';
import '../home_shell.dart';
import '../theme/pink_theme.dart';
import '../utils/date_format_id.dart';
import '../widgets/bounce_tap.dart';

/// Form konfigurasi awal (hanya sekali saat pertama dibuka):
/// nama, usia, HPHT, dan rata-rata panjang siklus.
/// Data dikunci ke SharedPreferences lewat
/// [CycleRepository.completeOnboarding].
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.repository});

  final CycleRepository repository;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  DateTime? _hpht;
  int _cycleLength = 28;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickHpht() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _hpht ?? now,
      firstDate: DateTime(now.year - 2, now.month, now.day),
      lastDate: now,
      helpText: 'Tanggal hari pertama haid terakhir (HPHT)',
      cancelText: 'Batal',
      confirmText: 'Oke',
    );
    if (picked != null && mounted) {
      setState(() => _hpht = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _adjustCycle(int delta) {
    setState(() {
      _cycleLength = (_cycleLength + delta)
          .clamp(CycleRepository.minCycleLength, CycleRepository.maxCycleLength);
    });
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: PinkPalette.deepRose,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
  }

  void _submit() {
    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty) {
      _snack('Isi namamu dulu ya 🙈');
      return;
    }
    if (age == null || age < 1 || age > 99) {
      _snack('Usia antara 1–99 tahun ya 😊');
      return;
    }
    if (_hpht == null) {
      _snack('Pilih tanggal HPHT dulu 📅');
      return;
    }

    widget.repository.completeOnboarding(
      name: name,
      age: age,
      hpht: _hpht!,
      cycleLength: _cycleLength,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => HomeShell(repository: widget.repository),
      ),
    );
  }

  InputDecoration _decoration(String label, String hint,
          {IconData? icon, String? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: icon == null
            ? null
            : Icon(icon, color: PinkPalette.dustyRose, size: 22),
        filled: true,
        fillColor: PinkPalette.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: PinkPalette.dustyRose, width: 1.6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final hpht = _hpht;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              PinkPalette.blush,
              PinkPalette.softBabyPink,
              PinkPalette.cream,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ------------------------------------------- kepala
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/app_icon.png',
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          width: 92,
                          height: 92,
                          color: PinkPalette.white,
                          alignment: Alignment.center,
                          child:
                              const Text('🐰', style: TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Halo! Kenalan dulu 🐰',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: PinkPalette.deepRose,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Isi data awal ini sekali saja, supaya prediksi\nsiklusmu tepat untukmu 💗',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.5, color: PinkPalette.ink),
                  ),
                  const SizedBox(height: 22),

                  // ------------------------------------------- nama
                  TextField(
                    key: const Key('onboard-name'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _decoration(
                      'Namamu',
                      'mis. Putri',
                      icon: Icons.favorite_outline,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ------------------------------------------- usia
                  TextField(
                    key: const Key('onboard-age'),
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: _decoration(
                      'Usia',
                      'mis. 26',
                      icon: Icons.cake_outlined,
                      suffix: 'tahun',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ------------------------------------------- HPHT
                  Text(
                    'Tanggal hari pertama haid terakhir (HPHT)',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: PinkPalette.ink.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 8),
                  BounceTap(
                    onTap: _pickHpht,
                    child: Container(
                      key: const Key('onboard-hpht'),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: PinkPalette.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: hpht == null
                              ? PinkPalette.dustyRose.withValues(alpha: 0.5)
                              : PinkPalette.dustyRose,
                          width: 1.4,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: PinkPalette.rose, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              hpht == null
                                  ? 'Pilih tanggal 📅'
                                  : 'HPHT: ${formatDate(hpht)}',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: hpht == null
                                    ? PinkPalette.inkSoft
                                    : PinkPalette.deepRose,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down,
                              color: PinkPalette.dustyRose),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ------------------------------------------- panjang siklus
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: PinkPalette.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.loop, color: PinkPalette.rose,
                            size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Rata-rata siklus',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: PinkPalette.ink,
                            ),
                          ),
                        ),
                        _RoundStepButton(
                          icon: Icons.remove,
                          color: PinkPalette.lavenderDeep,
                          onTap: () => _adjustCycle(-1),
                        ),
                        SizedBox(
                          width: 74,
                          child: Text(
                            '$_cycleLength hari',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: PinkPalette.deepRose,
                            ),
                          ),
                        ),
                        _RoundStepButton(
                          icon: Icons.add,
                          color: PinkPalette.rose,
                          onTap: () => _adjustCycle(1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Bisa diubah kapan saja di tab Atur ⚙️',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: PinkPalette.inkSoft),
                  ),
                  const SizedBox(height: 24),

                  // ------------------------------------------- tombol mulai
                  BounceTap(
                    onTap: _submit,
                    child: Container(
                      key: const Key('onboard-submit'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [PinkPalette.rose, PinkPalette.deepRose],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: PinkPalette.deepRose.withValues(alpha: 0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Mulai menggunakan ShePeriod 🌸',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: PinkPalette.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tombol bulat −/+ untuk stepper siklus.
class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPlus = icon == Icons.add;
    return BounceTap(
      onTap: onTap,
      child: Container(
        key: Key(isPlus ? 'onboard-cycle-plus' : 'onboard-cycle-minus'),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: color),
      ),
    );
  }
}