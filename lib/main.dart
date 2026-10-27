import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'data/cycle_repository.dart';
import 'pages/splash_screen.dart';
import 'services/notification_service.dart';
import 'theme/pink_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: PinkPalette.softBabyPink,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  final repository = await CycleRepository.load();
  // siapkan pengingat (aman jika platform tidak mendukung)
  await NotificationService.instance.init();
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});

  final CycleRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShePeriod',
      debugShowCheckedModeBanner: false,
      theme: buildPinkTheme(),
      // tanggal & teks bawaan (date picker) berbahasa Indonesia
      locale: const Locale('id'),
      supportedLocales: const [Locale('id')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // splash screen -> onboarding (pertama kali) / dashboard
      home: SplashScreen(repository: repository),
    );
  }
}