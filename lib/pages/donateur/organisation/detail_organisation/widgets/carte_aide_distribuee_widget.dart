
import 'package:flutter/material.dart';

import '/../../../models/aide_distribuee.dart';
import '/../../../styles/couleurs.dart';
import 'details_destinataire_aide_widget.dart';
import 'preuves_distribution_widget.dart';

class CarteAideDistribueeWidget extends StatelessWidget {
  const CarteAideDistribueeWidget({
    super.key,
    required this.aide,
  });

  final AideDistribuee aide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: CouleursApp.blanc,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: CouleursApp.vert.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: CouleursApp.noir.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. PHOTO OU VIDEO : zone indépendante en haut.
          SizedBox(
            width: double.infinity,
            height: 220,
            child: ClipRect(
              child: PreuvesDistributionWidget(aide: aide),
            ),
          ),

          // 2. TITRE ET TYPE DE DEMANDE,
          //    OU NOM ET PRENOM DU BENEFICIAIRE.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: DetailsDestinataireAideWidget(aide: aide),
          ),

          // 3. DATE ET LIEU EN BAS DE LA CARD.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(
                  height: 1,
                  color: Color(0xFFEAE5DB),
                ),
                const SizedBox(height: 14),

                if (aide.dateDistribution != null &&
                    aide.dateDistribution.toString().trim().isNotEmpty)
                  _LigneInformation(
                    icone: Icons.calendar_today_outlined,
                    texte: 'Date : ${aide.dateDistribution}',
                  ),

                if ((aide.lieuDistribution ?? '').trim().isNotEmpty)
                  _LigneInformation(
                    icone: Icons.location_on_outlined,
                    texte: 'Lieu : ${aide.lieuDistribution}',
                  ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      color: CouleursApp.vert,
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Statut de distribution',
                      style: TextStyle(
                        color: CouleursApp.noir,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _texteOuValeur(aide.statut),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          color: CouleursApp.vert,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _texteOuValeur(dynamic valeur) {
    final texte = valeur?.toString().trim() ?? '';
    return texte.isEmpty ? 'Non renseigné' : texte;
  }
}

class _LigneInformation extends StatelessWidget {
  const _LigneInformation({
    required this.icone,
    required this.texte,
  });

  final IconData icone;
  final String texte;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icone,
            size: 19,
            color: CouleursApp.vert,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texte,
              style: const TextStyle(
                color: CouleursApp.noir,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
