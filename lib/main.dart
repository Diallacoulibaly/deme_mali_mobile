
import 'package:flutter/material.dart';

import 'pages/lancement/ecran_lancement.dart';
import 'styles/couleurs.dart';

void main() {
  runApp(const DemeMaliApp());
}

class DemeMaliApp extends StatelessWidget {
  const DemeMaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dèmè Mali',
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
