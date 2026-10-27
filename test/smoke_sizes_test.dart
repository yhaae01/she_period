import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:she_period/data/cycle_repository.dart';
import 'package:she_period/main.dart';

void main() {
  for (final size in const [Size(320, 570), Size(412, 915)]) {
    testWidgets('tanpa overflow di ${size.width}x${size.height}',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final repository = await CycleRepository.load();

      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MyApp(repository: repository));
      await tester.pump(const Duration(milliseconds: 400));

      // gulir dashboard sampai bawah untuk memicu layout semua bagiannya
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -1200),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.text('Catat Hari Ini 💗'), findsOneWidget);

      // buka kalender & pastikan tanpa overflow
      await tester.tap(find.text('Kalender'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Kalender Siklus'), findsOneWidget);
    });
  }
}