
import 'package:flutter/material.dart';

import '../../styles/couleurs.dart';
import '../accueil/accueil.dart';
import 'widgets/nom_anime.dart';

class EcranLancement extends StatefulWidget {
  const EcranLancement({super.key});

  @override
  State<EcranLancement> createState() => _EcranLancementState();
}

class _EcranLancementState extends State<EcranLancement>
    with TickerProviderStateMixin {
  final String nomApplication = 'Dèmè Mali';

  String nomAffiche = '';

  bool nomVisible = true;
  bool logoVisible = false;

  late final AnimationController controleurTaille;
  late final Animation<double> tailleLogo;

  late final AnimationController controleurPosition;
  late final Animation<double> positionLogo;

  late final AnimationController controleurAccueil;
  late final Animation<double> opaciteAccueil;

  @override
  void initState() {
    super.initState();

    // Animation de la taille du logo.
    controleurTaille = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    tailleLogo = Tween<double>(
      begin: 35,
      end: 120,
    ).animate(
      CurvedAnimation(
        parent: controleurTaille,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animation du déplacement du logo.
    controleurPosition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    positionLogo = CurvedAnimation(
      parent: controleurPosition,
      curve: Curves.easeInOutCubic,
    );

    // Apparition progressive de la page d'accueil.
    controleurAccueil = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    opaciteAccueil = CurvedAnimation(
      parent: controleurAccueil,
      curve: Curves.easeIn,
    );

    lancerAnimation();
  }

  Future<void> lancerAnimation() async {
    // 1. Écriture du nom lettre par lettre.
    for (int i = 1; i <= nomApplication.length; i++) {
      if (!mounted) return;

      setState(() {
        nomAffiche = nomApplication.substring(0, i);
      });

      await Future.delayed(
        const Duration(milliseconds: 130),
      );
    }

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    // 2. Faire apparaître le logo.
    setState(() {
      logoVisible = true;
    });

    // 3. Agrandir progressivement le logo.
    await controleurTaille.forward();

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) return;

    // 4. Faire disparaître le nom.
    setState(() {
      nomVisible = false;
    });

    // 5. Faire apparaître l'accueil.
    controleurAccueil.forward();

    // 6. Déplacer le logo agrandi vers le haut.
    await controleurPosition.forward();
  }

  @override
  void dispose() {
    controleurTaille.dispose();
    controleurPosition.dispose();
    controleurAccueil.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tailleEcran = MediaQuery.of(context).size;
    final zoneSureHaut = MediaQuery.of(context).padding.top;

    final double positionDepart = tailleEcran.height * 0.25;
    final double positionFinale = zoneSureHaut + 12;

    return Scaffold(
      backgroundColor: CouleursApp.fond,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Page d'accueil sans deuxième logo.
          FadeTransition(
            opacity: opaciteAccueil,
            child: const AccueilPage(
              afficherLogo: false,
            ),
          ),

          // Nom de l'application.
          if (nomVisible)
            Positioned(
              top: tailleEcran.height * 0.43,
              left: 0,
              right: 0,
              child: Center(
                child: NomAnime(
                  texte: nomAffiche,
                ),
              ),
            ),

          // Un seul logo animé : agrandissement puis déplacement.
          if (logoVisible)
            AnimatedBuilder(
              animation: Listenable.merge([
                controleurTaille,
                controleurPosition,
              ]),
              builder: (context, child) {
                final double taille = tailleLogo.value;

                final double haut = positionDepart +
                    (positionFinale - positionDepart) *
                        positionLogo.value;

                return Positioned(
                  top: haut,
                  left: (tailleEcran.width - taille) / 2,
                  width: taille,
                  height: taille,
                  child: Image.asset(
                    'assets/images/logo_acceuil.png',
                    width: taille,
                    height: taille,
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
