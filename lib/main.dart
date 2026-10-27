import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';

import 'data/cycle_repository.dart';
import 'home_shell.dart';
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
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.repository});

  final CycleRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'She Period',
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
      home: HomeShell(repository: repository),
    );
  }
}