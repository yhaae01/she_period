import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../data/cycle_repository.dart';
import '../utils/date_format_id.dart';

/// Pengingat otomatis: menjelang haid & awal masa subur.
///
/// Semua pemanggilan plugin dibungkus try/catch supaya aman di environment
/// tanpa plugin (web / widget test) — fitur pengingat tidak boleh membuat
/// aplikasi crash.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'she_period_reminders';
  static const _channelName = 'Pengingat ShePeriod';
  static const _channelDescription =
      'Pengingat perkiraan haid, masa subur, dan catatan harian';

  static const _periodReminderId = 1;
  static const _fertileReminderId = 2;
  static const _reminderHour = 9; // jam 09:00 waktu lokal

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Jalankan aksi plugin dengan aman di environment yang tidak
  /// mendaftarkan plugin (widget test / web / platform tak didukung).
  static Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on MissingPluginException {
      // plugin tidak tersedia di environment ini
    } on PlatformException {
      // platform menolak permintaan
    } catch (error) {
      // `LateInitializationError` (tipe internal dart) muncul saat instance
      // platform plugin belum terdaftar — terjadi di widget test.
      final text = error.toString();
      final pluginUnavailable = text.startsWith('LateInitializationError') ||
          error is UnimplementedError;
      if (pluginUnavailable) return;
      rethrow;
    }
  }

  /// Zona waktu lokal dari offset perangkat (WIB/WITA/WIT/UTC).
  /// Dipisah jadi fungsi murni supaya mudah diuji.
  static tz.Location localLocationFor(Duration offset) {
    if (offset == Duration.zero) return tz.UTC;

    final zones = <Duration, String>{
      const Duration(hours: 7): 'Asia/Jakarta',
      const Duration(hours: 8): 'Asia/Makassar',
      const Duration(hours: 9): 'Asia/Jayapura',
      const Duration(hours: 5, minutes: 30): 'Asia/Kolkata',
      const Duration(hours: 1): 'Europe/Paris',
      const Duration(hours: -5): 'America/New_York',
    };

    try {
      return tz.getLocation(zones[offset] ?? 'Asia/Jakarta');
    } catch (_) {
      // zona tidak ada di database -> fallback UTC, jangan sampai crash
      return tz.UTC;
    }
  }

  /// Inisialisasi plugin + zona waktu lokal. Aman dipanggil berulang.
  Future<void> init() async {
    if (_initialized) return;
    await _guard(() async {
      tzdata.initializeTimeZones();
      tz.setLocalLocation(localLocationFor(DateTime.now().timeZoneOffset));

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: darwin,
          macOS: darwin,
        ),
      );

      // minta izin notifikasi (Android 13+ / iOS)
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      _initialized = true;
    });
  }

  /// Sinkronkan jadwal pengingat dengan prediksi siklus terbaru.
  Future<void> syncFrom(CycleRepository repository) async {
    await _guard(() async {
      if (!_initialized) await init();
      if (!_initialized) return;

      await _plugin.cancelAll();
      if (!repository.notificationsEnabled) return;

      final predictions = repository.predictions;
      final details = const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      );

      // 1) H-3 menjelang haid berikutnya
      await _scheduleIfFuture(
        id: _periodReminderId,
        title: 'Haid tinggal 3 hari 🌙',
        body: 'Perkiraan haid ${formatDate(predictions.nextPeriodStart)}. '
            'Siapkan perlengkapannya ya, Sayang 💗',
        when: _atHour(
          predictions.nextPeriodStart.subtract(const Duration(days: 3)),
        ),
        details: details,
      );

      // 2) Hari pertama masa subur
      await _scheduleIfFuture(
        id: _fertileReminderId,
        title: 'Masa subur dimulai 🌸',
        body:
            'Hari ini sampai ${formatDayMonth(predictions.fertileWindowEnd)} '
            'adalah masa suburmu. Jangan lupa minum air putih ya 💧',
        when: _atHour(predictions.fertileWindowStart),
        details: details,
      );
    });
  }

  /// Batalkan semua pengingat (mis. saat pengingat dimatikan).
  Future<void> cancelAll() async {
    await _guard(() => _plugin.cancelAll());
  }

  static DateTime _atHour(DateTime date) =>
      DateTime(date.year, date.month, date.day, _reminderHour);

  Future<void> _scheduleIfFuture({
    required int id,
    required String title,
    required String body,
    required DateTime when,
    required NotificationDetails details,
  }) async {
    if (!when.isAfter(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}