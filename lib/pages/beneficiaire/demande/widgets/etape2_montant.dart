import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../styles/couleurs.dart';

class Etape2Montant extends StatefulWidget {
  const Etape2Montant({
    super.key,
    required this.montantController,
    required this.onRetour,
    required this.onContinuer,
  });

  final TextEditingController montantController;
  final VoidCallback onRetour;
  final VoidCallback onContinuer;

  @override
  State<Etape2Montant> createState() => _Etape2MontantState();
}

class _Etape2MontantState extends State<Etape2Montant> {
  String _formaterMontant(String brut) {
    final sansEspaces = brut.replaceAll(RegExp(r'\D'), '');
    if (sansEspaces.isEmpty) return '0 FCFA';
    final nombre = int.tryParse(sansEspaces) ?? 0;
    if (nombre == 0) return '0 FCFA';
    final regex = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formate =
        nombre.toString().replaceAllMapped(regex, (m) => '${m[1]} ');
    return '$formate FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Carte principale blanche
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: CouleursApp.blanc,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MONTANT DE LA DEMANDE
              const Text(
                'MONTANT DE LA DEMANDE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: CouleursApp.noir,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'INDIQUEZ LE MONTANT TOTAL NÉCESSAIRE POUR\nRÉPONDRE À VOTRE BESOIN.',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withValues(alpha: 0.45),
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 18),

              // Cadre avec bordure verte et affichage interactif du montant "0 FCFA"
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.montantController,
                builder: (context, value, _) {
                  final texteAffiche = _formaterMontant(value.text);
                  return Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: CouleursApp.blanc,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CouleursApp.vert, width: 1.5),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Texte formaté toujours centré et auto-adaptatif sans débordement
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              texteAffiche,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: texteAffiche.length > 15 ? 24 : 30,
                                fontWeight: FontWeight.w900,
                                color: CouleursApp.noir,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Champ de saisie invisible superposé pour recevoir les frappes
                        Positioned.fill(
                          child: TextField(
                            controller: widget.montantController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(14),
                            ],
                            cursorColor: CouleursApp.vert,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              // Note explicative
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CouleursApp.vert.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: CouleursApp.vert,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ce montant servira d\'objectif pour votre demande et sera visible par les donateurs.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.65),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Boutons Retour et Continuer
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: widget.onRetour,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: CouleursApp.blanc,
                    foregroundColor: CouleursApp.noir,
                    side: BorderSide(
                      color: Colors.black.withValues(alpha: 0.15),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Retour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: widget.onContinuer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CouleursApp.vert,
                    foregroundColor: CouleursApp.blanc,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
