import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../controllers/accueil_beneficiaire_controller.dart';
import '../../../styles/couleurs.dart';

// Description d'un onglet de la barre (libellé + icônes)
class _Onglet {
  const _Onglet({
    required this.label,
    required this.icone,
    required this.iconeActive,
  });

  final String label;
  final IconData icone;
  final IconData iconeActive;
}

// Les 4 onglets : l'index dans la liste = la valeur de ongletActifBeneficiaireProvider
const List<_Onglet> _onglets = [
  _Onglet(
    label: 'Accueil',
    icone: Icons.home_rounded,
    iconeActive: Icons.home_rounded,
  ),
  _Onglet(
    label: 'Mes demandes',
    icone: Icons.description_outlined,
    iconeActive: Icons.description_rounded,
  ),
  _Onglet(
    label: 'Mes dons reçus',
    icone: Icons.volunteer_activism_outlined,
    iconeActive: Icons.volunteer_activism_rounded,
  ),
  _Onglet(
    label: 'Profil',
    icone: Icons.person_outline_rounded,
    iconeActive: Icons.person_rounded,
  ),
];

// Barre de navigation inférieure courbée personnalisée
class BarreNavigationBeneficiaire extends ConsumerWidget {
  const BarreNavigationBeneficiaire({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(ongletActifBeneficiaireProvider);
    final basSafeArea = MediaQuery.of(context).padding.bottom;
    final largeurTotale = MediaQuery.of(context).size.width;
    final tabWidth = largeurTotale / _onglets.length;

    return SizedBox(
      height: 72 + basSafeArea,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Fond vert avec échancrure courbée sous l'élément actif
          CustomPaint(
            size: Size(largeurTotale, 72 + basSafeArea),
            painter: _BarNavCurveePainter(
              couleurBarre: CouleursApp.vert,
              selectedIndex: selectedIndex,
              nombreElements: _onglets.length,
            ),
          ),

          // Bouton blanc flottant circulaire sur l'onglet actif
          Positioned(
            left: tabWidth * (selectedIndex + 0.5) - 27,
            top: 2,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: CouleursApp.blanc,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _onglets[selectedIndex].iconeActive,
                  color: CouleursApp.vert,
                  size: 26,
                ),
              ),
            ),
          ),

          // Les éléments de navigation (Accueil, Mes demandes, Aides reçues, Profil)
          Positioned(
            left: 0,
            right: 0,
            bottom: basSafeArea + 4,
            child: Row(
              children: [
                for (var i = 0; i < _onglets.length; i++)
                  _ElementNav(
                    onglet: _onglets[i],
                    estSelectionne: i == selectedIndex,
                    onTap: () {
                      ref.read(ongletActifBeneficiaireProvider.notifier).state = i;
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Un onglet de la barre (icône + libellé, masqué quand il est actif)
class _ElementNav extends StatelessWidget {
  const _ElementNav({
    required this.onglet,
    required this.estSelectionne,
    required this.onTap,
  });

  final _Onglet onglet;
  final bool estSelectionne;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: 52,
          child: estSelectionne
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      onglet.icone,
                      color: CouleursApp.blanc,
                      size: 23,
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        onglet.label,
                        style: const TextStyle(
                          color: CouleursApp.blanc,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Dessinateur de la barre de navigation avec échancrure courbée
class _BarNavCurveePainter extends CustomPainter {
  final Color couleurBarre;
  final int selectedIndex;
  final int nombreElements;

  _BarNavCurveePainter({
    required this.couleurBarre,
    required this.selectedIndex,
    required this.nombreElements,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = couleurBarre
      ..style = PaintingStyle.fill;

    final path = Path();
    final tabWidth = size.width / nombreElements;
    final cX = tabWidth * (selectedIndex + 0.5);

    const rayonNotch = 36.0;
    const profondeurNotch = 38.0;

    path.moveTo(0, 14);

    // Échancrure douce autour de l'icône active
    path.lineTo(cX - rayonNotch - 14, 14);
    path.cubicTo(
      cX - rayonNotch, 14,
      cX - rayonNotch + 6, profondeurNotch,
      cX, profondeurNotch,
    );
    path.cubicTo(
      cX + rayonNotch - 6, profondeurNotch,
      cX + rayonNotch, 14,
      cX + rayonNotch + 14, 14,
    );

    path.lineTo(size.width, 14);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BarNavCurveePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.couleurBarre != couleurBarre;
  }
}
