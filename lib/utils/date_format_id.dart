/// Format tanggal berbahasa Indonesia (tanpa package `intl`).
const idWeekdayNames = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const idWeekdayShort = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

const idMonthNames = [
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

/// "Kamis, 29 Oktober 2026"
String formatFullDate(DateTime date) =>
    '${idWeekdayNames[date.weekday - 1]}, ${date.day} '
    '${idMonthNames[date.month - 1]} ${date.year}';

/// "29 Oktober 2026"
String formatDate(DateTime date) =>
    '${date.day} ${idMonthNames[date.month - 1]} ${date.year}';

/// "29 Oktober"
String formatDayMonth(DateTime date) =>
    '${date.day} ${idMonthNames[date.month - 1]}';

/// Rentang tanggal: "3–8 November 2026" atau "30 Oktober – 5 November 2026"
String formatDateRange(DateTime start, DateTime end) {
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–${end.day} ${idMonthNames[end.month - 1]} ${end.year}';
  }
  if (start.year == end.year) {
    return '${formatDayMonth(start)} – ${formatDayMonth(end)} ${end.year}';
  }
  return '${formatDate(start)} – ${formatDate(end)}';
}