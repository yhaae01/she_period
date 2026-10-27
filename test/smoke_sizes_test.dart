import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:she_period/main.dart';

void main() {
  for (final size in const [Size(320, 570), Size(412, 915)]) {
    testWidgets('tanpa overflow di ${size.width}x${size.height}',
        (WidgetTester tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 400));

      // gulir sampai bawah untuk memicu layout semua bagian
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1200));
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.takeException(), isNull);
      expect(find.text('Catat Hari Ini 💗'), findsOneWidget);
    });
  }
}