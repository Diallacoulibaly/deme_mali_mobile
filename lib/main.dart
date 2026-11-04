import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/lancement/ecran_lancement.dart';
import 'styles/couleurs.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Capture les erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    debugPrint('ERREUR FLUTTER : ${details.exception}');
    debugPrintStack(stackTrace: details.stack);
  };

  // Capture les erreurs asynchrones non gérées
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('ERREUR NON CAPTURÉE : $error');
    debugPrintStack(stackTrace: stack);

    return true;
  };

  runApp(
    const ProviderScope(
      child: DemeMaliApp(),
    ),
  );
}

class DemeMaliApp extends StatelessWidget {
  const DemeMaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dèmè Mali',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('fr', 'FR'),
      theme: ThemeData(
        scaffoldBackgroundColor: CouleursApp.fond,
        colorScheme: ColorScheme.fromSeed(
          seedColor: CouleursApp.vert,
        ),
        useMaterial3: true,
      ),
      home: const EcranLancement(),
    );
  }
}