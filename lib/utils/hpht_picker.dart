import 'package:flutter/material.dart';

/// Pop-up kalender bawaan ([showDatePicker]) untuk memilih
/// tanggal hari pertama haid terakhir (HPHT).
///
/// Mengembalikan tanggal yang dipilih, atau `null` batal.
Future<DateTime?> pickHphtDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime lastDate,
  DateTime? firstDate,
}) {
  final initial = initialDate.isAfter(lastDate) ? lastDate : initialDate;

  return showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: firstDate ?? DateTime(lastDate.year - 2, 1, 1),
    lastDate: lastDate,
    helpText: 'Pilih tanggal hari pertama haid terakhir (HPHT)',
    confirmText: 'Oke',
    cancelText: 'Batal',
  );
}