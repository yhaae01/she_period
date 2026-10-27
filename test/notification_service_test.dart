import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/services/notification_service.dart';

void main() {
  setUpAll(tzdata.initializeTimeZones);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('pemetaan zona waktu lokal dari offset perangkat', () {
    expect(
      NotificationService.localLocationFor(const Duration(hours: 7)).name,
      'Asia/Jakarta',
    );
    expect(
      NotificationService.localLocationFor(const Duration(hours: 8)).name,
      'Asia/Makassar',
    );
    expect(
      NotificationService.localLocationFor(const Duration(hours: 9)).name,
      'Asia/Jayapura',
    );
    expect(
      NotificationService.localLocationFor(Duration.zero).name,
      tz.UTC.name,
    );
    // offset yang tidak dikenal -> fallback WIB (aman, tidak crash)
    expect(
      NotificationService.localLocationFor(const Duration(hours: 10)).name,
      'Asia/Jakarta',
    );
  });

  test('init & sync aman di environment tanpa platform plugin', () async {
    final repository = await CycleRepository.load();

    // di widget test tidak ada host notification -> tidak boleh melempar
    await NotificationService.instance.init();
    expect(NotificationService.instance.isInitialized, isFalse);

    await NotificationService.instance.syncFrom(repository);
    await NotificationService.instance.cancelAll();

    // mematikan pengingat juga aman
    repository.setNotificationsEnabled(false);
    await NotificationService.instance.syncFrom(repository);
  });
}